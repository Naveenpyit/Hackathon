import { Router } from "oak";
import { conversationController } from "../controllers/conversationController.ts";
import { requireAuth } from "../middleware/auth.ts";

const router = new Router();

// POST /api/conversations — Create or find 1-on-1 conversation (requires auth)
router.post("/api/conversations", requireAuth, conversationController.createConversation);

// GET /api/conversations — Get user's conversations with details (requires auth)
router.get("/api/conversations", requireAuth, conversationController.getConversations);

// GET /api/conversations/:id/messages — Get messages for a conversation (requires auth)
router.get("/api/conversations/:id/messages", requireAuth, conversationController.getMessages);

export default router;
