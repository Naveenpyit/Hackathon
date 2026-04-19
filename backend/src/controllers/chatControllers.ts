import { ChatService } from "../services/chatService.ts";
import { verifyToken } from "../services/websocket.ts";
import type {
  ChatEvent,
  ChatEventType,
  SendMessagePayload,
  TypingPayload,
  ReadMessagePayload,
  CreateConversationPayload,
  JoinConversationPayload,
} from "../types/chat.ts";

interface WSUser {
  id: string;
  socket: WebSocket;
}

const connectedUsers = new Map<string, WSUser>();
const socketToUser = new Map<WebSocket, string>();

function createEvent(type: ChatEventType, payload: unknown): string {
  return JSON.stringify({ type, payload: { data: payload } });
}

function sendEvent(socket: WebSocket, type: ChatEventType, payload: unknown): void {
  if (socket.readyState === WebSocket.OPEN) {
    socket.send(createEvent(type, payload));
  }
}

function broadcastToConversation(
  conversationId: string,
  excludeSocket: WebSocket | null,
  event: string
): void {
  for (const [, wsUser] of connectedUsers) {
    if (wsUser.socket !== excludeSocket) {
      wsUser.socket.send(event);
    }
  }
}

export async function handleChatConnection(socket: WebSocket, token?: string): Promise<void> {
  // If token is provided via query param, authenticate immediately
  if (token) {
    const user = await verifyToken(token);
    if (!user) {
      sendEvent(socket, "connection:rejected", { error: "Invalid token" });
      socket.close(4001, "Invalid token");
      return;
    }

    socketToUser.set(socket, user.userId);
    connectedUsers.set(user.userId, { id: user.userId, socket });
    await ChatService.createUserSession(user.userId, crypto.randomUUID());
    sendEvent(socket, "connection:accepted", { user_id: user.userId });
    console.log(`User ${user.userId} connected via WebSocket (query token)`);
    return;
  }

  // No token in query — send a prompt and wait for connection:auth event
  sendEvent(socket, "connection:pending", { message: "Send connection:auth with your token" });
  console.log("WebSocket connected, waiting for authentication...");
}

export async function handleChatMessage(socket: WebSocket, data: string): Promise<void> {
  const userId = socketToUser.get(socket);
  if (!userId) {
    sendEvent(socket, "error", { error: "Not authenticated" });
    return;
  }

  let event: ChatEvent;
  try {
    event = JSON.parse(data);
  } catch {
    sendEvent(socket, "error", { error: "Invalid JSON format" });
    return;
  }

  switch (event.type) {
    case "message:new":
      await handleNewMessage(socket, userId, event.payload as SendMessagePayload);
      break;
    case "message:read":
      await handleReadMessage(socket, userId, event.payload as ReadMessagePayload);
      break;
    case "typing:start":
    case "typing:stop":
      await handleTyping(socket, userId, event.payload as TypingPayload);
      break;
    case "conversation:created":
      await handleCreateConversation(socket, userId, event.payload as CreateConversationPayload);
      break;
    case "conversation:joined":
      await handleJoinConversation(socket, userId, event.payload as JoinConversationPayload);
      break;
    case "connection:auth":
      await handleAuth(socket, event.payload as { token: string });
      break;
    default:
      sendEvent(socket, "error", { error: `Unknown event type: ${event.type}` });
  }
}

async function handleAuth(socket: WebSocket, payload: { token: string }): Promise<void> {
  const { token } = payload;
  const user = await verifyToken(token);

  if (!user) {
    sendEvent(socket, "connection:rejected", { error: "Invalid token" });
    socket.close(4001, "Invalid token");
    return;
  }

  socketToUser.set(socket, user.userId);
  connectedUsers.set(user.userId, { id: user.userId, socket });
  await ChatService.createUserSession(user.userId, crypto.randomUUID());
  
  sendEvent(socket, "connection:accepted", { user_id: user.userId });
  console.log(`User ${user.userId} authenticated`);
}

async function handleNewMessage(
  socket: WebSocket,
  userId: string,
  payload: SendMessagePayload
): Promise<void> {
  const { conversation_id, content, message_type = "text" } = payload;

  const isParticipant = await ChatService.isParticipant(conversation_id, userId);
  if (!isParticipant) {
    sendEvent(socket, "error", { error: "Not a participant in this conversation" });
    return;
  }

  const message = await ChatService.createMessage(conversation_id, userId, content, message_type);
  const event = createEvent("message:new", message);

  broadcastToConversation(conversation_id, socket, event);
  sendEvent(socket, "message:new", message);
}

async function handleReadMessage(
  socket: WebSocket,
  userId: string,
  payload: ReadMessagePayload
): Promise<void> {
  const { message_id, conversation_id } = payload;

  const isParticipant = await ChatService.isParticipant(conversation_id, userId);
  if (!isParticipant) {
    sendEvent(socket, "error", { error: "Not a participant" });
    return;
  }

  await ChatService.markMessageAsRead(message_id);
  const event = createEvent("message:read", { message_id, user_id: userId });

  broadcastToConversation(conversation_id, socket, event);
}

async function handleTyping(
  socket: WebSocket,
  userId: string,
  payload: TypingPayload
): Promise<void> {
  const { conversation_id, is_typing } = payload;

  const isParticipant = await ChatService.isParticipant(conversation_id, userId);
  if (!isParticipant) {
    return;
  }

  const event = createEvent(is_typing ? "typing:start" : "typing:stop", {
    conversation_id,
    user_id: userId,
  });

  broadcastToConversation(conversation_id, socket, event);
}

async function handleCreateConversation(
  socket: WebSocket,
  userId: string,
  payload: CreateConversationPayload
): Promise<void> {
  const { participant_ids } = payload;

  const conversation = await ChatService.createConversation();
  await ChatService.addParticipant(conversation.id, userId);

  for (const participantId of participant_ids) {
    if (participantId !== userId) {
      await ChatService.addParticipant(conversation.id, participantId);
    }
  }

  sendEvent(socket, "conversation:created", { conversation });
}

async function handleJoinConversation(
  socket: WebSocket,
  userId: string,
  payload: JoinConversationPayload
): Promise<void> {
  const { conversation_id } = payload;

  const conversation = await ChatService.getConversation(conversation_id);
  if (!conversation) {
    sendEvent(socket, "error", { error: "Conversation not found" });
    return;
  }

  await ChatService.addParticipant(conversation_id, userId);

  const event = createEvent("conversation:joined", {
    conversation_id,
    user_id: userId,
  });

  broadcastToConversation(conversation_id, socket, event);
}

export function handleDisconnect(socket: WebSocket): void {
  const userId = socketToUser.get(socket);
  if (userId) {
    connectedUsers.delete(userId);
    socketToUser.delete(socket);
    console.log(`User ${userId} disconnected`);
  }
}

export function getConnectedUserIds(): string[] {
  return Array.from(connectedUsers.keys());
}