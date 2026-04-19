import { supabase } from "../config/supabase.ts";
import { UserDetails } from "../types/auth.ts";

export const userService = {
  // Search users by name or email
  async searchUsers(query: string): Promise<{ success: boolean; data?: UserDetails[]; error?: string }> {
    try {
      const { data, error } = await supabase
        .from("user_details")
        .select(`
          *,
          designation:designation(id, name)
        `)
        .or(`user_name.ilike.%${query}%,email.ilike.%${query}%`)
        .order("user_name", { ascending: true })
        .limit(50);

      if (error) {
        console.error("Search users error:", error);
        return { success: false, error: "SEARCH_ERROR" };
      }

      const users: UserDetails[] = (data || []).map((u: any) => ({
        id: u.id,
        user_id: u.user_id,
        email: u.email,
        user_name: u.user_name,
        designation_id: u.designation_id ?? u.designation?.id ?? null,
        designation: u.designation,
        status: u.status,
        shift_time: u.shift_time,
        created_at: u.created_at,
      }));

      return { success: true, data: users };
    } catch (error) {
      console.error("Search users error:", error);
      return { success: false, error: "INTERNAL_ERROR" };
    }
  },

  // Get all users
  async getAllUsers(): Promise<{ success: boolean; data?: UserDetails[]; error?: string }> {
    try {
      const { data, error } = await supabase
        .from("user_details")
        .select(`
          *,
          designation:designation(id, name)
        `)
        .order("user_name", { ascending: true });

      if (error) {
        console.error("Get all users error:", error);
        return { success: false, error: "FETCH_ERROR" };
      }

      const users: UserDetails[] = (data || []).map((u: any) => ({
        id: u.id,
        user_id: u.user_id,
        email: u.email,
        user_name: u.user_name,
        designation_id: u.designation_id ?? u.designation?.id ?? null,
        designation: u.designation,
        status: u.status,
        shift_time: u.shift_time,
        created_at: u.created_at,
      }));

      return { success: true, data: users };
    } catch (error) {
      console.error("Get all users error:", error);
      return { success: false, error: "INTERNAL_ERROR" };
    }
  },
};
