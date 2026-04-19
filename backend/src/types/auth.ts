// Auth Request/Response Types
export interface SignupRequest {
  email: string;
  password: string;
  user_name: string;
  designation_id?: number; // Optional, nullable in DB
  status?: string; // Optional, has default in DB
  shift_time?: string; // Optional, has default in DB
}

export interface SigninRequest {
  email: string;
  password: string;
}

export interface SignupResponse {
  status: number;
  message: string;
  data: {
    id: string;
    user_id: string;
    email: string;
    designation_id: number | null;
    status: string;
    shift_time: string;
    user_name: string;
    created_at: string;
  } | null;
}

export interface SigninResponse {
  status: number;
  message: string;
  data: {
    access_token: string;
    refresh_token: string;
  } | null;
}

export interface ApiResponse {
  status: number;
  message: string;
  data: unknown;
}

export interface UserDetails {
  id: string;
  user_id: string;
  email?: string;
  designation_id: number | null;
  designation?: {
    id: number;
    name: string;
  } | null;
  status: string;
  shift_time: string;
  user_name: string;
  created_at?: string;
}

// Designation type
export interface Designation {
  id: number;
  name: string;
  created_at?: string;
}
