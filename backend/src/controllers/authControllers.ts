import { Context } from "oak";
import { authService } from "../services/authServices.ts";
import { validateSignupRequest, validateSigninRequest } from "../middleware/validation.ts";
import { SignupResponse, SigninResponse, ApiResponse } from "../types/auth.ts";

export const authController = {
  // Signup handler
  async signup(ctx: Context) {
    try {
      // Parse request body
      const body = ctx.request.body({ type: "json" });
      const requestData = await body.value;
      console.log('~~~~~data~~~~',requestData)

      // Validate request
      const validation = validateSignupRequest(requestData);
      console.log('~~~validation~~~~~',validation)
      if (!validation.valid) {
        ctx.response.status = 400;
        ctx.response.body = {
          status: 0,
          message: validation.message,
          data: null,
        } as ApiResponse;
        return;
      }

      // Call auth service
      const result = await authService.signup(validation.data!);

      if (!result.success) {
        ctx.response.status = 400;
        ctx.response.body = {
          status: 0,
          message: result.message,
          data: null,
        } as ApiResponse;
        return;
      }

      ctx.response.status = 201;
      ctx.response.body = {
        status: 1,
        message: result.message,
        data: result.data,
      } as SignupResponse;
    } catch (error) {
      console.error("Signup controller error:", error);
      ctx.response.status = 500;
      ctx.response.body = {
        status: 0,
        message: "An unexpected error occurred",
        data: null,
      } as ApiResponse;
    }
  },

  // Signin handler
  async signin(ctx: Context) {
    try {
      // Parse request body
      const body = ctx.request.body({ type: "json" });
      const requestData = await body.value;

      // Validate request
      const validation = validateSigninRequest(requestData);
      if (!validation.valid) {
        ctx.response.status = 400;
        ctx.response.body = {
          status: 0,
          message: validation.message,
          data: null,
        } as ApiResponse;
        return;
      }

      // Call auth service
      const result = await authService.signin(validation.data!);

      if (!result.success) {
        ctx.response.status = 401;
        ctx.response.body = {
          status: 0,
          message: result.message,
          data: null,
        } as ApiResponse;
        return;
      }

      ctx.response.status = 200;
      ctx.response.body = {
        status: 1,
        message: result.message,
        data: result.data,
      } as SigninResponse;
    } catch (error) {
      console.error("Signin controller error:", error);
      ctx.response.status = 500;
      ctx.response.body = {
        status: 0,
        message: "An unexpected error occurred",
        data: null,
      } as ApiResponse;
    }
  },

  // Get current user handler (requires auth token)
  async getCurrentUser(ctx: Context) {
    try {
      // Extract user ID from auth context (from middleware)
      const userId = (ctx.state as Record<string, unknown>).userId as string;

      if (!userId) {
        ctx.response.status = 401;
        ctx.response.body = {
          status: 0,
          message: "Unauthorized",
          data: null,
        } as ApiResponse;
        return;
      }

      const result = await authService.getUserById(userId);

      if (!result.success) {
        ctx.response.status = 404;
        ctx.response.body = {
          status: 0,
          message: "User not found",
          data: null,
        } as ApiResponse;
        return;
      }

      ctx.response.status = 200;
      ctx.response.body = {
        status: 1,
        message: "User details fetched successfully",
        data: result.data,
      } as ApiResponse;
    } catch (error) {
      console.error("Get current user error:", error);
      ctx.response.status = 500;
      ctx.response.body = {
        status: 0,
        message: "An unexpected error occurred",
        data: null,
      } as ApiResponse;
    }
  },
};
