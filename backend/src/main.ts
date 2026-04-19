import { Application } from "oak";
import { authRouter, designationRouter } from "./routers/routers.ts";

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

// Routes
app.use(authRouter.routes());
app.use(authRouter.allowedMethods());
app.use(designationRouter.routes());
app.use(designationRouter.allowedMethods());

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

await app.listen({ port });
