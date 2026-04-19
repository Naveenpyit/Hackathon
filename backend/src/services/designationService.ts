import { supabase } from "../config/supabase.ts";
import { Designation } from "../types/auth.ts";

export const designationService = {
  // Get all designations
  async getAll(): Promise<{ success: boolean; data?: Designation[]; error?: string }> {
    try {
      const { data, error } = await supabase
        .from("designation")
        .select("*")
        .order("id", { ascending: true });

      if (error) {
        return { success: false, error: error.message };
      }

      return { success: true, data: data || [] };
    } catch (error) {
      console.error("Get designations error:", error);
      return { success: false, error: "INTERNAL_ERROR" };
    }
  },

  // Get designation by ID
  async getById(id: number): Promise<{ success: boolean; data?: Designation; error?: string }> {
    try {
      const { data, error } = await supabase
        .from("designation")
        .select("*")
        .eq("id", id)
        .single();

      if (error || !data) {
        return { success: false, error: "DESIGNATION_NOT_FOUND" };
      }

      return { success: true, data };
    } catch (error) {
      console.error("Get designation by ID error:", error);
      return { success: false, error: "INTERNAL_ERROR" };
    }
  },

  // Create new designation (admin only)
  async create(name: string): Promise<{ success: boolean; data?: Designation; error?: string }> {
    try {
      const { data, error } = await supabase
        .from("designation")
        .insert({ name })
        .select()
        .single();

      if (error || !data) {
        return { success: false, error: error?.message || "CREATE_FAILED" };
      }

      return { success: true, data };
    } catch (error) {
      console.error("Create designation error:", error);
      return { success: false, error: "INTERNAL_ERROR" };
    }
  },
};