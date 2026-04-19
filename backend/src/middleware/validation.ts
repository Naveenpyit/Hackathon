import { SignupRequest, SigninRequest } from "../types/auth.ts";

export const validateEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

export const validatePassword = (password: string): { valid: boolean; message: string } => {
  if (password.length < 8) {
    return { valid: false, message: "Password must be at least 8 characters long" };
  }
  if (!/[A-Z]/.test(password)) {
    return { valid: false, message: "Password must contain at least one uppercase letter" };
  }
  if (!/[a-z]/.test(password)) {
    return { valid: false, message: "Password must contain at least one lowercase letter" };
  }
  if (!/[0-9]/.test(password)) {
    return { valid: false, message: "Password must contain at least one number" };
  }
  return { valid: true, message: "Password is valid" };
};

export const validateSignupRequest = (data: unknown): { valid: boolean; message: string; data?: SignupRequest } => {
  const request = data as Record<string, unknown>;

  // Extract fields (accept snake_case directly)
  const email = request.email as string;
  const password = request.password as string;
  const userName = request.user_name as string;
  const designationId = request.designation_id as number | undefined;
  const status = request.status as string | undefined;
  const shiftTime = request.shift_time as string | undefined;

  // Check required fields
  if (!email || typeof email !== "string") {
    return { valid: false, message: "Email is required and must be a string" };
  }

  if (!password || typeof password !== "string") {
    return { valid: false, message: "Password is required and must be a string" };
  }

  // Designation ID is optional (nullable in DB)
  if (designationId !== undefined && typeof designationId !== "number") {
    return { valid: false, message: "Designation ID must be a number if provided" };
  }

  // Status and shift_time are optional (have defaults in DB)
  if (status !== undefined && typeof status !== "string") {
    return { valid: false, message: "Status must be a string if provided" };
  }

  if (shiftTime !== undefined && typeof shiftTime !== "string") {
    return { valid: false, message: "Shift time must be a string if provided" };
  }

  if (!userName || typeof userName !== "string") {
    return { valid: false, message: "User name is required and must be a string" };
  }

  // Validate email format
  if (!validateEmail(email)) {
    return { valid: false, message: "Invalid email format" };
  }

  // Validate password strength
  const passwordValidation = validatePassword(password);
  if (!passwordValidation.valid) {
    return { valid: false, message: passwordValidation.message };
  }

  const signupRequest: SignupRequest = {
    email: email,
    password: password,
    user_name: userName,
    designation_id: designationId,
    status: status,
    shift_time: shiftTime,
  };

  return { valid: true, message: "Request is valid", data: signupRequest };
};

export const validateSigninRequest = (data: unknown): { valid: boolean; message: string; data?: SigninRequest } => {
  const request = data as Record<string, unknown>;

  if (!request.email || typeof request.email !== "string") {
    return { valid: false, message: "Email is required and must be a string" };
  }

  if (!request.password || typeof request.password !== "string") {
    return { valid: false, message: "Password is required and must be a string" };
  }

  if (!validateEmail(request.email)) {
    return { valid: false, message: "Invalid email format" };
  }

  const signinRequest: SigninRequest = {
    email: request.email,
    password: request.password,
  };

  return { valid: true, message: "Request is valid", data: signinRequest };
};
