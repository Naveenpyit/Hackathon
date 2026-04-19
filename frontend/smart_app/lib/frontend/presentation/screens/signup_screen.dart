import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/strings.dart';
import '../../core/utils/validation_utils.dart';
import '../../core/utils/responsive_design.dart';
import '../widgets/index.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _agreeToTerms = false;
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.agreeTermsRequired)),
        );
        return;
      }

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
        title: AppStrings.signUpTitle,
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
                    Text(
                      'Create Your Account',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: isTablet
                                ? AppTheme.fontSize3XL * 1.2
                                : null,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      AppStrings.signUpSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: isTablet ? AppTheme.fontSizeL : null,
                          ),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildAnimatedTextField(
                            delay: 0,
                            child: CustomTextField(
                              controller: _nameController,
                              label: AppStrings.fullName,
                              hint: AppStrings.fullNameHint,
                              prefixIcon: Icons.person_outline,
                              validator: ValidationUtils.validateFullName,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingL),
                          _buildAnimatedTextField(
                            delay: 100,
                            child: CustomTextField(
                              controller: _emailController,
                              label: AppStrings.email,
                              hint: AppStrings.emailHint,
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: ValidationUtils.validateEmail,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingL),
                          _buildAnimatedTextField(
                            delay: 200,
                            child: CustomTextField(
                              controller: _passwordController,
                              label: AppStrings.password,
                              hint: AppStrings.passwordHint,
                              prefixIcon: Icons.lock_outlined,
                              isPassword: true,
                              validator:
                                  ValidationUtils.validatePassword,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingL),
                          _buildAnimatedTextField(
                            delay: 300,
                            child: CustomTextField(
                              controller: _confirmPasswordController,
                              label: AppStrings.confirmPassword,
                              hint: AppStrings.confirmPasswordHint,
                              prefixIcon: Icons.lock_outlined,
                              isPassword: true,
                              validator: (value) {
                                return ValidationUtils
                                    .validateConfirmPassword(
                                  _passwordController.text,
                                  value,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingL),
                          _buildAnimatedTextField(
                            delay: 400,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToTerms = value ?? false;
                                    });
                                  },
                                  activeColor:
                                      AppTheme.primaryColor,
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                      children: [
                                        const TextSpan(
                                            text:
                                                AppStrings
                                                    .agreeTerms),
                                        TextSpan(
                                          text: AppStrings
                                              .termsConditions,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppTheme
                                                    .primaryColor,
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                              ),
                                        ),
                                        const TextSpan(
                                            text: AppStrings.and),
                                        TextSpan(
                                          text: AppStrings
                                              .privacyPolicy,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppTheme
                                                    .primaryColor,
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    PrimaryButton(
                      onPressed: _handleSignUp,
                      label: AppStrings.createAccount,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppTheme.spacingL),
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
                            const TextSpan(
                                text: AppStrings.haveAccount),
                            TextSpan(
                              text: AppStrings.signIn,
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
                                      context, '/signin');
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
            delay / 500,
            (delay + 200) / 500,
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
              delay / 500,
              (delay + 200) / 500,
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
