import { supabase } from "../config/supabase.ts";
import type { ChatMessage, Conversation, ConversationParticipant, UserSession } from "../types/chat.ts";

export class ChatService {
  static async createMessage(
    conversationId: string,
    senderId: string,
    content: string,
    messageType: string = "text"
  ): Promise<ChatMessage> {
    const { data, error } = await supabase
      .from("messages")
      .insert({
        conversation_id: conversationId,
        sender_id: senderId,
        content,
        message_type: messageType,
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async getMessages(
    conversationId: string,
    limit: number = 50,
    offset: number = 0
  ): Promise<ChatMessage[]> {
    const { data, error } = await supabase
      .from("messages")
      .select("*")
      .eq("conversation_id", conversationId)
      .order("created_at", { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) throw error;
    return data || [];
  }

  static async markMessageAsRead(messageId: string): Promise<void> {
    const { error } = await supabase
      .from("messages")
      .update({ is_read: true })
      .eq("id", messageId);

    if (error) throw error;
  }

  static async markConversationAsRead(conversationId: string, userId: string): Promise<void> {
    const { error } = await supabase
      .from("messages")
      .update({ is_read: true })
      .eq("conversation_id", conversationId)
      .neq("sender_id", userId);

    if (error) throw error;
  }

  static async createConversation(): Promise<Conversation> {
    const { data, error } = await supabase
      .from("conversations")
      .insert({})
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async getConversation(conversationId: string): Promise<Conversation | null> {
    const { data, error } = await supabase
      .from("conversations")
      .select("*")
      .eq("id", conversationId)
      .single();

    if (error) return null;
    return data;
  }

  static async addParticipant(
    conversationId: string,
    userId: string
  ): Promise<ConversationParticipant> {
    const { data, error } = await supabase
      .from("conversation_participants")
      .insert({
        conversation_id: conversationId,
        user_id: userId,
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async getParticipants(conversationId: string): Promise<ConversationParticipant[]> {
    const { data, error } = await supabase
      .from("conversation_participants")
      .select("*")
      .eq("conversation_id", conversationId);

    if (error) throw error;
    return data || [];
  }

  static async getUserConversations(userId: string): Promise<Conversation[]> {
    const { data: participants, error } = await supabase
      .from("conversation_participants")
      .select("conversation_id")
      .eq("user_id", userId);

    if (error) throw error;
    if (!participants || participants.length === 0) return [];

    const conversationIds = participants.map((p) => p.conversation_id);
    const { data: conversations, error: convError } = await supabase
      .from("conversations")
      .select("*")
      .in("id", conversationIds);

    if (convError) throw convError;
    return conversations || [];
  }

  static async isParticipant(conversationId: string, userId: string): Promise<boolean> {
    const { data, error } = await supabase
      .from("conversation_participants")
      .select("id")
      .eq("conversation_id", conversationId)
      .eq("user_id", userId)
      .single();

    return !error && !!data;
  }

  static async findOneOnOneConversation(userId1: string, userId2: string): Promise<Conversation | null> {
    // Find conversations where both users are participants
    const { data: conv1, error: err1 } = await supabase
      .from("conversation_participants")
      .select("conversation_id")
      .eq("user_id", userId1);

    if (err1 || !conv1) return null;

    const { data: conv2, error: err2 } = await supabase
      .from("conversation_participants")
      .select("conversation_id")
      .eq("user_id", userId2)
      .in("conversation_id", conv1.map(p => p.conversation_id));

    if (err2 || !conv2 || conv2.length === 0) return null;

    // Of the matching conversations, find one that has exactly 2 participants (1-on-1)
    for (const conv of conv2) {
      const { count, error: countErr } = await supabase
        .from("conversation_participants")
        .select("*", { count: 'exact', head: true })
        .eq("conversation_id", conv.conversation_id);

      if (!countErr && count === 2) {
        return this.getConversation(conv.conversation_id);
      }
    }

    return null;
  }

  static async getConversationWithDetails(conversationId: string): Promise<any | null> {
    const { data, error } = await supabase
      .from("conversations")
      .select(`
        *,
        participants:conversation_participants(
          user:user_details(*)
        ),
        last_message:messages(*)
      `)
      .eq("id", conversationId)
      .order("created_at", { foreignTable: "messages", ascending: false })
      .limit(1, { foreignTable: "messages" })
      .single();

    if (error) return null;
    return data;
  }

  static async getConversationsWithDetails(userId: string): Promise<any[]> {
    const { data: participants, error } = await supabase
      .from("conversation_participants")
      .select("conversation_id")
      .eq("user_id", userId);

    if (error || !participants) return [];

    const conversationIds = participants.map(p => p.conversation_id);
    if (conversationIds.length === 0) return [];

    const { data, error: convError } = await supabase
      .from("conversations")
      .select(`
        *,
        participants:conversation_participants(
          user:user_details(*)
        ),
        messages(*)
      `)
      .in("id", conversationIds)
      .order("created_at", { foreignTable: "messages", ascending: false });

    if (convError) return [];
    
    // Map to include only the last message
    return (data || []).map(conv => ({
      ...conv,
      last_message: conv.messages && conv.messages.length > 0 ? conv.messages[0] : null,
      messages: undefined
    }));
  }

  static async createUserSession(
    userId: string,
    socketId: string
  ): Promise<UserSession> {
    const { data, error } = await supabase
      .from("user_sessions")
      .insert({
        user_id: userId,
        socket_id: socketId,
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async getUserSession(socketId: string): Promise<UserSession | null> {
    const { data, error } = await supabase
      .from("user_sessions")
      .select("*")
      .eq("socket_id", socketId)
      .is("disconnected_at", null)
      .single();

    if (error) return null;
    return data;
  }

  static async updateUserSessionDisconnect(socketId: string): Promise<void> {
    const { error } = await supabase
      .from("user_sessions")
      .update({ disconnected_at: new Date().toISOString() })
      .eq("socket_id", socketId);

    if (error) throw error;
  }

  static async getOnlineUsers(): Promise<string[]> {
    const { data, error } = await supabase
      .from("user_sessions")
      .select("user_id")
      .is("disconnected_at", null);

    if (error) throw error;
    return data?.map((s) => s.user_id) || [];
  }
}