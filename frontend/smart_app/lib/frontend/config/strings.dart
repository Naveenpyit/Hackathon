/// String constants for the Smart App
class AppStrings {
  // Welcome Screen
  static const String welcomeTitle = 'Welcome to Smart App';
  static const String welcomeSubtitle =
      'Connect, collaborate, and communicate seamlessly with your team';
  static const String featureMessaging = 'Instant Messaging';
  static const String featureMessagingDesc =
      'Send messages and media instantly';
  static const String featureCollaboration = 'Team Collaboration';
  static const String featureCollaborationDesc =
      'Work together with your team in real-time';
  static const String featureSecurity = 'Secure & Private';
  static const String featureSecurityDesc =
      'Your conversations are encrypted and safe';
  static const String getStarted = 'Get Started';
  static const String noAccount = "Don't have an account? ";
  static const String createAccount = 'Create Account';

  // Sign In Screen
  static const String signIn = 'Sign In';
  static const String signInSubtitle = 'Welcome back! Sign in to your account';
  static const String email = 'Email Address';
  static const String emailHint = 'Enter your email';
  static const String password = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String forgotPassword = 'Forgot Password?';

  // Sign Up Screen
  static const String signUpTitle = 'Create Account';
  static const String signUpSubtitle = 'Join us and start collaborating';
  static const String fullName = 'Full Name';
  static const String fullNameHint = 'Enter your full name';
  static const String confirmPassword = 'Confirm Password';
  static const String confirmPasswordHint = 'Confirm your password';
  static const String agreeTerms = 'I agree to the ';
  static const String termsConditions = 'Terms & Conditions';
  static const String and = ' and ';
  static const String privacyPolicy = 'Privacy Policy';
  static const String haveAccount = 'Already have an account? ';

  // Forgot Password Screen
  static const String resetPassword = 'Reset Password';
  static const String resetPasswordDesc =
      'Enter your email address and we\'ll send you a link to reset your password';
  static const String sendResetLink = 'Send Reset Link';
  static const String checkEmail = 'Check Your Email';
  static const String emailSentDesc =
      'We\'ve sent a password reset link to';
  static const String backToSignIn = 'Back to Sign In';

  // Email Verification Screen
  static const String verifyEmail = 'Verify Your Email';
  static const String verifyEmailDesc =
      'We\'ve sent a verification code to your email address. Enter it below to verify your account.';
  static const String verifyButton = 'Verify Email';
  static const String didntReceive = "Didn't receive code? ";
  static const String resend = 'Resend';
  static const String emailVerified = 'Email Verified!';
  static const String emailVerifiedDesc =
      'Your account has been verified successfully. Redirecting to chats...';
  static const String enterAllDigits = 'Please enter all 6 digits';

  // Chats Screen
  static const String chatsTitle = 'Chats';
  static const String search = 'Search conversations...';
  static const String group = 'GROUP';
  static const String openingChat = 'Opening chat with ';
  static const String teamsComingSoon = 'Teams - Coming soon';
  static const String calendarComingSoon = 'Calendar - Coming soon';
  static const String profileComingSoon = 'Profile - Coming soon';

  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordUppercase =
      'Password must contain at least one uppercase letter';
  static const String passwordLowercase =
      'Password must contain at least one lowercase letter';
  static const String passwordNumber =
      'Password must contain at least one number';
  static const String passwordMismatch = 'Passwords do not match';
  static const String confirmPasswordRequired = 'Please confirm your password';
  static const String nameRequired = 'Full name is required';
  static const String nameTooShort = 'Name must be at least 3 characters';
  static const String agreeTermsRequired = 'Please agree to terms and conditions';
  static const String verificationSent = 'Verification code sent to your email';
}
