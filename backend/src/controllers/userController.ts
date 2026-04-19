import { Context } from "oak";
import { userService } from "../services/userService.ts";
import { ApiResponse } from "../types/auth.ts";

export const userController = {
  // GET /api/users — list all users
  async getAllUsers(ctx: Context) {
    try {
      const result = await userService.getAllUsers();

      if (!result.success) {
        ctx.response.status = 500;
        ctx.response.body = {
          status: 0,
          message: "Failed to fetch users",
          data: null,
        } as ApiResponse;
        return;
      }

      ctx.response.status = 200;
      ctx.response.body = {
        status: 1,
        message: "Users fetched successfully",
        data: result.data,
      } as ApiResponse;
    } catch (error) {
      console.error("Get all users error:", error);
      ctx.response.status = 500;
      ctx.response.body = {
        status: 0,
        message: "An unexpected error occurred",
        data: null,
      } as ApiResponse;
    }
  },

  // GET /api/users/search?q=<query> — search users
  async searchUsers(ctx: Context) {
    try {
      const query = ctx.request.url.searchParams.get("q") || "";

      if (!query.trim()) {
        // If no query, return all users
        const result = await userService.getAllUsers();
        ctx.response.status = 200;
        ctx.response.body = {
          status: 1,
          message: "Users fetched successfully",
          data: result.data || [],
        } as ApiResponse;
        return;
      }

      const result = await userService.searchUsers(query.trim());

      if (!result.success) {
        ctx.response.status = 500;
        ctx.response.body = {
          status: 0,
          message: "Failed to search users",
          data: null,
        } as ApiResponse;
        return;
      }

      ctx.response.status = 200;
      ctx.response.body = {
        status: 1,
        message: "Search results",
        data: result.data,
      } as ApiResponse;
    } catch (error) {
      console.error("Search users error:", error);
      ctx.response.status = 500;
      ctx.response.body = {
        status: 0,
        message: "An unexpected error occurred",
        data: null,
      } as ApiResponse;
    }
  },
};
