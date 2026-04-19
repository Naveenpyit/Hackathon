import { Router } from "oak";
import { userController } from "../controllers/userController.ts";

const router = new Router();

// GET /api/users/search?q=<query> — search users by name or email
router.get("/api/users/search", userController.searchUsers);

// GET /api/users — list all users
router.get("/api/users", userController.getAllUsers);

export default router;
