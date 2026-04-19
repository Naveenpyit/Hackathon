export interface ChatMessage {
  id: string;
  conversation_id: string;
  sender_id: string;
  content: string;
  message_type: string;
  is_read: boolean;
  created_at: string;
}

export interface Conversation {
  id: string;
  created_at: string;
  updated_at: string;
}

export interface ConversationParticipant {
  id: string;
  conversation_id: string;
  user_id: string;
  joined_at: string;
}

export interface UserSession {
  id: string;
  user_id: string;
  socket_id: string;
  connected_at: string;
  disconnected_at: string | null;
}

export interface ChatEvent {
  type: ChatEventType;
  payload: ChatEventPayload;
}

export type ChatEventType = 
  | "connection:auth"
  | "connection:accepted"
  | "connection:rejected"
  | "connection:pending"
  | "message:new"
  | "message:read"
  | "conversation:created"
  | "conversation:joined"
  | "typing:start"
  | "typing:stop"
  | "user:online"
  | "user:offline"
  | "error";

export interface ChatEventPayload {
  data?: unknown;
  error?: string;
  message?: string;
}

export interface SendMessagePayload {
  conversation_id: string;
  content: string;
  message_type?: string;
}

export interface TypingPayload {
  conversation_id: string;
  user_id: string;
  is_typing: boolean;
}

export interface ReadMessagePayload {
  message_id: string;
  conversation_id: string;
  user_id: string;
}

export interface CreateConversationPayload {
  participant_ids: string[];
}

export interface JoinConversationPayload {
  conversation_id: string;
  user_id: string;
}

export interface AuthConnectionPayload {
  token: string;
}