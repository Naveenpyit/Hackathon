import { Context } from "oak";
import { designationService } from "../services/designationService.ts";
import { ApiResponse } from "../types/auth.ts";

export const designationController = {
  // Get all designations
  async getAll(ctx: Context) {
    try {
      const result = await designationService.getAll();

      if (!result.success) {
        ctx.response.status = 500;
        ctx.response.body = {
          status: 0,
          message: "Failed to fetch designations",
          data: null,
        } as ApiResponse;
        return;
      }

      ctx.response.status = 200;
      ctx.response.body = {
        status: 1,
        message: "Designations fetched successfully",
        data: result.data,
      } as ApiResponse;
    } catch (error) {
      console.error("Get designations controller error:", error);
      ctx.response.status = 500;
      ctx.response.body = {
        status: 0,
        message: "An unexpected error occurred",
        data: null,
      } as ApiResponse;
    }
  },
};