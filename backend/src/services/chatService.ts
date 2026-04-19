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