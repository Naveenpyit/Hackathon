import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/strings.dart';
import '../../core/utils/validation_utils.dart';
import '../widgets/index.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendReset() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _emailSent = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  if (!_emailSent) ...[
                    Text(
                      AppStrings.resetPassword,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      AppStrings.resetPasswordDesc,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.mail_outline,
                            size: 50,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: CustomTextField(
                        controller: _emailController,
                        label: AppStrings.email,
                        hint: AppStrings.emailHint,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: ValidationUtils.validateEmail,
                      ),
                    ),
                    const SizedBox(height: 40),
                    PrimaryButton(
                      onPressed: _handleSendReset,
                      label: AppStrings.sendResetLink,
                      isLoading: _isLoading,
                    ),
                  ] else ...[
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check_circle,
                                size: 60,
                                color: AppTheme.successColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            AppStrings.checkEmail,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          Text(
                            '${AppStrings.emailSentDesc}\n${_emailController.text}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.textSecondary,
                                  height: 1.5,
                                ),
                          ),
                          const SizedBox(height: 60),
                          PrimaryButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signin');
                            },
                            label: AppStrings.backToSignIn,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
