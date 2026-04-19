import { supabase } from "../config/supabase.ts";
import { SignupRequest, SigninRequest, UserDetails } from "../types/auth.ts";

export const authService = {
  // Signup service
  async signup(request: SignupRequest): Promise<{ success: boolean; message: string; data?: UserDetails; error?: string }> {
    try {
      // Check if user already exists
      const { data: existingUser, error: checkError } = await supabase
        .from("user_details")
        .select("email")
        .eq("email", request.email)
        .single();

      if (existingUser) {
        return { success: false, message: "Email already exists", error: "DUPLICATE_EMAIL" };
      }

      // Create user in auth.users
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email: request.email,
        password: request.password,
      });

      if (authError || !authData?.user) {
        return { 
          success: false, 
          message: authError?.message || "Failed to create user", 
          error: "AUTH_ERROR" 
        };
      }

      const userId = authData.user.id;

      // Insert user details into user_details table
      const insertData: any = {
        user_id: userId,
        user_name: request.user_name,
        status: request.status || 'active', // Use default if not provided
        shift_time: request.shift_time || '9.30 to 6.30', // Use default if not provided
      };

      // Only add designation if provided
      if (request.designation_id !== undefined) {
        insertData.designation = request.designation_id;
      }

      const { data: userDetails, error: insertError } = await supabase
        .from("user_details")
        .insert(insertData)
        .select()
        .single();

      if (insertError || !userDetails) {
        // Delete the auth user if details insertion fails
        await supabase.auth.admin.deleteUser(userId);
        return { 
          success: false, 
          message: "Failed to save user details", 
          error: "INSERT_ERROR" 
        };
      }

      return {
        success: true,
        message: "User created successfully",
        data: {
          id: userDetails.id,
          user_id: userDetails.user_id,
          email: request.email,
          designation_id: userDetails.designation,
          status: userDetails.status,
          shift_time: userDetails.shift_time,
          user_name: userDetails.user_name,
          created_at: new Date().toISOString(),
        },
      };
    } catch (error) {
      console.error("Signup error:", error);
      return { 
        success: false, 
        message: "An unexpected error occurred", 
        error: "INTERNAL_ERROR" 
      };
    }
  },

  // Signin service
  async signin(request: SigninRequest): Promise<{ 
    success: boolean; 
    message: string; 
    data?: { access_token: string; refresh_token: string; user: UserDetails }; 
    error?: string 
  }> {
    try {
      // Authenticate with Supabase Auth
      const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
        email: request.email,
        password: request.password,
      });

      if (authError || !authData?.user || !authData?.session) {
        return { 
          success: false, 
          message: authError?.message || "Invalid email or password", 
          error: "AUTH_ERROR" 
        };
      }

      // Fetch user details with designation
      const { data: userDetails, error: fetchError } = await supabase
        .from("user_details")
        .select(`
          *,
          designation:designation(id, name)
        `)
        .eq("user_id", authData.user.id)
        .single();

      if (fetchError || !userDetails) {
        return { 
          success: false, 
          message: "User details not found", 
          error: "USER_NOT_FOUND" 
        };
      }

      return {
        success: true,
        message: "Login Successfully",
        data: {
          access_token: authData.session.access_token,
          refresh_token: authData.session.refresh_token,
          user: {
            id: userDetails.id,
            email: authData.user.email!,
            designation: userDetails.designation,
            status: userDetails.status,
            shift_time: userDetails.shift_time,
            user_name: userDetails.user_name,
          },
        },
      };
    } catch (error) {
      console.error("Signin error:", error);
      return { 
        success: false, 
        message: "An unexpected error occurred", 
        error: "INTERNAL_ERROR" 
      };
    }
  },

  // Get user by ID
  async getUserById(userId: string): Promise<{ success: boolean; data?: UserDetails; error?: string }> {
    try {
      const { data: userDetails, error } = await supabase
        .from("user_details")
        .select(`
          *,
          designation:designation(id, name)
        `)
        .eq("id", userId)
        .single();

      if (error || !userDetails) {
        return { success: false, error: "USER_NOT_FOUND" };
      }

      return {
        success: true,
        data: {
          id: userDetails.id,
          user_id: userDetails.user_id,
          designation_id: userDetails.designation,
          designation: userDetails.designation,
          status: userDetails.status,
          shift_time: userDetails.shift_time,
          user_name: userDetails.user_name,
          created_at: userDetails.created_at,
        },
      };
    } catch (error) {
      console.error("Get user error:", error);
      return { success: false, error: "INTERNAL_ERROR" };
    }
  },
};
