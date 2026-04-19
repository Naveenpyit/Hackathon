import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/strings.dart';
import '../../core/utils/validation_utils.dart';
import '../../core/utils/responsive_design.dart';
import '../widgets/index.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pushReplacementNamed(context, '/email_verification');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveDesign.isTablet(context);
    final isPortrait = ResponsiveDesign.isPortrait(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.signIn,
        showGradient: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            child: SlideTransition(
              position: _slideAnimation,
              child: ResponsiveContainer(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? AppTheme.spacingXL : AppTheme.spacingL,
                  vertical: AppTheme.spacingL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: isTablet
                                ? AppTheme.fontSize3XL * 1.2
                                : null,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      AppStrings.signInSubtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: isTablet ? AppTheme.fontSizeL : null,
                          ),
                    ),
                    SizedBox(
                      height: isPortrait
                          ? AppTheme.spacingXL
                          : AppTheme.spacingL,
                    ),
                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email Field
                          _buildAnimatedTextField(
                            delay: 0,
                            child: CustomTextField(
                              label: AppStrings.email,
                              hint: AppStrings.emailHint,
                              controller: _emailController,
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: ValidationUtils.validateEmail,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingL),
                          // Password Field
                          _buildAnimatedTextField(
                            delay: 100,
                            child: CustomTextField(
                              label: AppStrings.password,
                              hint: AppStrings.passwordHint,
                              controller: _passwordController,
                              prefixIcon: Icons.lock_outlined,
                              isPassword: true,
                              validator:
                                  ValidationUtils.validatePassword,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, '/forgot_password');
                        },
                        child: Text(
                          AppStrings.forgotPassword,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Sign In Button
                    PrimaryButton(
                      onPressed: _handleSignIn,
                      label: AppStrings.signIn,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    // Sign Up Link
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                          children: [
                            const TextSpan(text: AppStrings.noAccount),
                            TextSpan(
                              text: AppStrings.createAccount,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                    decoration:
                                        TextDecoration.underline,
                                  ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(
                                      context, '/signup');
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height:
                          MediaQuery.of(context).size.height * 0.05,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required int delay,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            delay / 300,
            (delay + 200) / 300,
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              delay / 300,
              (delay + 200) / 300,
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
