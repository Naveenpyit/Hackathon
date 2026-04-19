// Test script for the updated auth API

const API_BASE_URL = "http://localhost:8002/api";

// Test signup with new fields
async function testSignup() {
  console.log("Testing signup with new fields...");
  
  const signupData = {
    email: "test@example.com",
    password: "Test123!@#",
    user_name: "johndoe"
    // designation_id, status and shift_time are all optional
  };

  try {
    const response = await fetch(`${API_BASE_URL}/auth/signup`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(signupData),
    });

    const result = await response.json();
    console.log("Signup response:", result);
    return result;
  } catch (error) {
    console.error("Signup error:", error);
  }
}

// Test signin
async function testSignin() {
  console.log("\nTesting signin...");
  
  const signinData = {
    email: "test@example.com",
    password: "Test123!@#",
  };

  try {
    const response = await fetch(`${API_BASE_URL}/auth/signin`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(signinData),
    });

    const result = await response.json();
    console.log("Signin response:", result);
    return result;
  } catch (error) {
    console.error("Signin error:", error);
  }
}

// Run tests
async function runTests() {
  console.log("Starting API tests...\n");
  
  // Test signup
  await testSignup();
  
  // Wait a bit before signin
  await new Promise(resolve => setTimeout(resolve, 1000));
  
  // Test signin
  await testSignin();
  
  console.log("\nTests completed!");
}

// Execute if running directly
if (import.meta.main) {
  runTests();
}