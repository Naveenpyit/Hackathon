import { supabase, supabaseAdmin } from "../config/supabase.ts";
import { UserDetails } from "../types/auth.ts";

export const userService = {
  // Get all users — merges user_details + auth.users (email) + designation
  async getAllUsers(): Promise<{ success: boolean; data?: UserDetails[]; error?: string }> {
    try {
      // 1. Fetch user_details rows
      const { data: userRows, error: userError } = await supabase
        .from("user_details")
        .select("id, user_id, user_name, designation, status, shift_time, created_at")
        .order("user_name", { ascending: true });

      if (userError) {
        console.error("Get all users error:", userError);
        return { success: false, error: "FETCH_ERROR" };
      }

      // 2. Fetch designation table
      const { data: designationRows } = await supabase
        .from("designation")
        .select("id, name");

      const designationMap = new Map<number, { id: number; name: string }>(
        (designationRows || []).map((d: { id: number; name: string }) => [d.id, d])
      );

      // 3. Fetch emails from auth.users via admin client
      let emailMap = new Map<string, string>(); // user_id -> email
      if (supabaseAdmin) {
        const { data: authList } = await supabaseAdmin.auth.admin.listUsers({ perPage: 1000 });
        if (authList?.users) {
          for (const u of authList.users) {
            if (u.email) emailMap.set(u.id, u.email);
          }
        }
      }

      // 4. Merge
      const users: UserDetails[] = (userRows || []).map((u: any) => ({
        id: u.id,
        user_id: u.user_id,
        user_name: u.user_name,
        email: emailMap.get(u.user_id) ?? null,
        designation_id: u.designation ?? null,
        designation: u.designation != null ? (designationMap.get(u.designation) ?? null) : null,
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

  // Search users by name
  async searchUsers(query: string): Promise<{ success: boolean; data?: UserDetails[]; error?: string }> {
    try {
      // 1. Fetch matching user_details rows
      const { data: userRows, error: userError } = await supabase
        .from("user_details")
        .select("id, user_id, user_name, designation, status, shift_time, created_at")
        .ilike("user_name", `%${query}%`)
        .order("user_name", { ascending: true })
        .limit(50);

      if (userError) {
        console.error("Search users error:", userError);
        return { success: false, error: "SEARCH_ERROR" };
      }

      // 2. Fetch designation table
      const { data: designationRows } = await supabase
        .from("designation")
        .select("id, name");

      const designationMap = new Map<number, { id: number; name: string }>(
        (designationRows || []).map((d: { id: number; name: string }) => [d.id, d])
      );

      // 3. Fetch emails from auth.users via admin client
      let emailMap = new Map<string, string>();
      if (supabaseAdmin) {
        const { data: authList } = await supabaseAdmin.auth.admin.listUsers({ perPage: 1000 });
        if (authList?.users) {
          for (const u of authList.users) {
            if (u.email) emailMap.set(u.id, u.email);
          }
        }
      }

      // 4. Merge
      const users: UserDetails[] = (userRows || []).map((u: any) => ({
        id: u.id,
        user_id: u.user_id,
        user_name: u.user_name,
        email: emailMap.get(u.user_id) ?? null,
        designation_id: u.designation ?? null,
        designation: u.designation != null ? (designationMap.get(u.designation) ?? null) : null,
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
};
