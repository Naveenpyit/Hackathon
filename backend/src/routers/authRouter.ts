import { Router } from "oak";
import { authController } from "../controllers/authControllers.ts";
import { requireAuth } from "../middleware/auth.ts";

const router = new Router();

// Auth routes
router.post("/api/auth/signup", authController.signup);
router.post("/api/auth/signin", authController.signin);
router.get("/api/auth/me", requireAuth, authController.getCurrentUser);

// Email confirmation bypass endpoint (for development)
router.get("/api/auth/confirm", async (ctx) => {
  const token = ctx.request.url.searchParams.get("token");
  const type = ctx.request.url.searchParams.get("type");
  
  if (token && type === "signup") {
    // This would normally verify the token
    ctx.response.body = { message: "Email confirmed" };
  } else {
    ctx.response.status = 400;
    ctx.response.body = { error: "Invalid confirmation link" };
  }
});

export default router;
