import { Context } from "oak";
import { supabase } from "../config/supabase.ts";

// Auth middleware: validates Authorization Bearer token from request header
export const requireAuth = async (ctx: Context, next: () => Promise<unknown>) => {
  try {
    const authHeader = ctx.request.headers.get("Authorization") || "";
    const match = authHeader.match(/^Bearer\s+(.+)$/i);

    if (!match) {
      ctx.response.status = 401;
      ctx.response.body = { status: 0, message: "Authorization token missing" };
      return;
    }

    const token = match[1];

    // Use Supabase client to get user from token
    // supabase.auth.getUser requires passing access token in headers via client
    // The SDK doesn't expose a straight verify function here, so we'll call the
    // auth API endpoint through the client by setting the auth header temporarily.
    const prev = (supabase as any).auth.session; // defensive - not used but keep shape

    // Accept development tokens of the form: dev-token-<userId>-<timestamp>
    const devMatch = token.match(/^dev-token-([^-]+)-\d+$/);
    if (devMatch) {
      const userId = devMatch[1];
      ctx.state.userId = userId;
      ctx.state.user = { id: userId } as unknown;
      await next();
      return;
    }

    const { data, error } = await supabase.auth.getUser(token);

    if (error || !data?.user) {
      ctx.response.status = 401;
      ctx.response.body = { status: 0, message: "Invalid or expired token" };
      return;
    }

    // Attach user information to context state for downstream handlers
    ctx.state.userId = data.user.id;
    ctx.state.user = data.user;

    await next();
  } catch (err) {
    console.error("Auth middleware error:", err);
    ctx.response.status = 500;
    ctx.response.body = { status: 0, message: "Internal server error" };
  }
};
