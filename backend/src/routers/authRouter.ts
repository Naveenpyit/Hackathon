import { Router } from "oak";
import { authController } from "../controllers/authControllers.ts";

const router = new Router();

// Auth routes
router.post("/api/auth/signup", authController.signup);
router.post("/api/auth/signin", authController.signin);
router.get("/api/auth/me", authController.getCurrentUser);

export default router;
