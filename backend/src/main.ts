import { Application } from "oak";
import { authRouter, designationRouter, userRouter, chatRouter } from "./routers/routers.ts";
import { handleChatConnection, handleChatMessage, handleDisconnect } from "./controllers/chatControllers.ts";

const app = new Application();

// CORS middleware
app.use(async (ctx, next) => {
  ctx.response.headers.set("Access-Control-Allow-Origin", "*");
  ctx.response.headers.set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  ctx.response.headers.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (ctx.request.method === "OPTIONS") {
    ctx.response.status = 200;
    return;
  }

  await next();
});

// Error handling middleware
app.use(async (ctx, next) => {
  try {
    await next();
  } catch (error) {
    console.error("Unhandled error:", error);
    ctx.response.status = 500;
    ctx.response.body = {
      status: 0,
      message: "Internal server error",
      data: null,
    };
  }
});

// WebSocket upgrade handling
app.use(async (ctx, next) => {
  if (ctx.request.url.pathname === "/ws/chat" && ctx.request.method === "GET") {
    if (!ctx.isUpgradable) {
      ctx.response.status = 426;
      ctx.response.body = { status: 0, message: "WebSocket upgrade required" };
      return;
    }

    // Extract token from query param: /ws/chat?token=<jwt>
    const token = ctx.request.url.searchParams.get("token") || undefined;

    ctx.response.headers.set("Sec-WebSocket-Protocol", "json");
    
    const ws = await ctx.upgrade();

    ws.onopen = async () => {
      await handleChatConnection(ws, token);
    };

    ws.onmessage = async (event) => {
      if (event.data) {
        await handleChatMessage(ws, event.data.toString());
      }
    };

    ws.onclose = () => {
      handleDisconnect(ws);
    };

    ws.onerror = (error) => {
      console.error("WebSocket error:", error);
      handleDisconnect(ws);
    };

    return;
  }

  await next();
});

// Routes
app.use(authRouter.routes());
app.use(authRouter.allowedMethods());
app.use(designationRouter.routes());
app.use(designationRouter.allowedMethods());
app.use(userRouter.routes());
app.use(userRouter.allowedMethods());
app.use(chatRouter.routes());
app.use(chatRouter.allowedMethods());

// Health check endpoint
app.use((ctx) => {
  if (ctx.request.url.pathname === "/health") {
    ctx.response.status = 200;
    ctx.response.body = { status: "OK", message: "Server is running" };
    return;
  }
});

// 404 handler
app.use((ctx) => {
  ctx.response.status = 404;
  ctx.response.body = {
    status: 0,
    message: "Route not found",
    data: null,
  };
});

// Start server
const port = 8000;
console.log(`🚀 Server running on http://localhost:${port}`);
console.log(`📝 Health check: http://localhost:${port}/health`);
console.log(`\n✅ Available endpoints:`);
console.log(`   POST   /api/auth/signup   - Register new user`);
console.log(`   POST   /api/auth/signin   - Login user`);
console.log(`   POST   /api/auth/refresh  - Refresh access token`);
console.log(`   GET    /api/auth/me       - Get current user (requires auth token)`);
console.log(`   WS     /ws/chat          - WebSocket chat (requires token)`);

await app.listen({ port });
