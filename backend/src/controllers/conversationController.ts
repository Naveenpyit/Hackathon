import { Context } from "oak";
import { ChatService } from "../services/chatService.ts";
import { ApiResponse } from "../types/auth.ts";

export const conversationController = {
  // POST /api/conversations — Create or find a 1-on-1 conversation
  async createConversation(ctx: Context) {
    try {
      const userId = (ctx.state as Record<string, unknown>).userId as string;
      if (!userId) {
        ctx.response.status = 401;
        ctx.response.body = { status: 0, message: "Unauthorized", data: null } as ApiResponse;
        return;
      }

      const body = ctx.request.body({ type: "json" });
      const requestData = await body.value;
      const participantId = requestData?.participant_id as string;

      if (!participantId) {
        ctx.response.status = 400;
        ctx.response.body = { status: 0, message: "participant_id is required", data: null } as ApiResponse;
        return;
      }

      if (participantId === userId) {
        ctx.response.status = 400;
        ctx.response.body = { status: 0, message: "Cannot create conversation with yourself", data: null } as ApiResponse;
        return;
      }

      // Check if a 1-on-1 conversation already exists
      const existing = await ChatService.findOneOnOneConversation(userId, participantId);
      if (existing) {
        ctx.response.status = 200;
        ctx.response.body = {
          status: 1,
          message: "Existing conversation found",
          data: existing,
        } as ApiResponse;
        return;
      }

      // Create new conversation
      const conversation = await ChatService.createConversation();
      await ChatService.addParticipant(conversation.id, userId);
      await ChatService.addParticipant(conversation.id, participantId);

      // Return full conversation with participants
      const full = await ChatService.getConversationWithDetails(conversation.id);

      ctx.response.status = 201;
      ctx.response.body = {
        status: 1,
        message: "Conversation created successfully",
        data: full || conversation,
      } as ApiResponse;
    } catch (error) {
      console.error("Create conversation error:", error);
      ctx.response.status = 500;
      ctx.response.body = { status: 0, message: "An unexpected error occurred", data: null } as ApiResponse;
    }
  },

  // GET /api/conversations — Get user's conversations with last message
  async getConversations(ctx: Context) {
    try {
      const userId = (ctx.state as Record<string, unknown>).userId as string;
      if (!userId) {
        ctx.response.status = 401;
        ctx.response.body = { status: 0, message: "Unauthorized", data: null } as ApiResponse;
        return;
      }

      const conversations = await ChatService.getConversationsWithDetails(userId);

      ctx.response.status = 200;
      ctx.response.body = {
        status: 1,
        message: "Conversations fetched successfully",
        data: conversations,
      } as ApiResponse;
    } catch (error) {
      console.error("Get conversations error:", error);
      ctx.response.status = 500;
      ctx.response.body = { status: 0, message: "An unexpected error occurred", data: null } as ApiResponse;
    }
  },

  // GET /api/conversations/:id/messages — Get messages for a conversation
  async getMessages(ctx: Context) {
    try {
      const userId = (ctx.state as Record<string, unknown>).userId as string;
      if (!userId) {
        ctx.response.status = 401;
        ctx.response.body = { status: 0, message: "Unauthorized", data: null } as ApiResponse;
        return;
      }

      const conversationId = (ctx as any).params?.id;
      if (!conversationId) {
        ctx.response.status = 400;
        ctx.response.body = { status: 0, message: "Conversation ID is required", data: null } as ApiResponse;
        return;
      }

      // Verify user is participant
      const isParticipant = await ChatService.isParticipant(conversationId, userId);
      if (!isParticipant) {
        ctx.response.status = 403;
        ctx.response.body = { status: 0, message: "Not a participant in this conversation", data: null } as ApiResponse;
        return;
      }

      const limit = parseInt(ctx.request.url.searchParams.get("limit") || "50");
      const offset = parseInt(ctx.request.url.searchParams.get("offset") || "0");

      const messages = await ChatService.getMessages(conversationId, limit, offset);

      ctx.response.status = 200;
      ctx.response.body = {
        status: 1,
        message: "Messages fetched successfully",
        data: messages,
      } as ApiResponse;
    } catch (error) {
      console.error("Get messages error:", error);
      ctx.response.status = 500;
      ctx.response.body = { status: 0, message: "An unexpected error occurred", data: null } as ApiResponse;
    }
  },
};
