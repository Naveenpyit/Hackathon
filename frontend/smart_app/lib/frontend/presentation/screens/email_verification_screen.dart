import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/strings.dart';
import '../widgets/index.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends State<EmailVerificationScreen> {
  final _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final _codeFocusNodes =
      List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isVerified = false;

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _codeFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getVerificationCode() {
    return _codeControllers.map((c) => c.text).join();
  }

  void _handleVerifyEmail() {
    final code = _getVerificationCode();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.enterAllDigits)),
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
          _isVerified = true;
        });

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            // ignore: use_build_context_synchronously
            Navigator.pushReplacementNamed(context, '/chats');
          }
        });
      }
    });
  }

  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty && value.length == 1) {
      if (index < 5) {
        _codeFocusNodes[index + 1].requestFocus();
      } else {
        _codeFocusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _codeFocusNodes[index - 1].requestFocus();
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  if (!_isVerified) ...[
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.verified_user_outlined,
                          size: 60,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      AppStrings.verifyEmail,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      AppStrings.verifyEmailDesc,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                        (index) => SizedBox(
                          width: 50,
                          height: 60,
                          child: TextField(
                            controller: _codeControllers[index],
                            focusNode: _codeFocusNodes[index],
                            onChanged: (value) =>
                                _onCodeChanged(value, index),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium),
                                borderSide: const BorderSide(
                                    color: AppTheme.neutral30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    PrimaryButton(
                      onPressed: _handleVerifyEmail,
                      label: AppStrings.verifyButton,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.didntReceive,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(AppStrings.verificationSent),
                              ),
                            );
                          },
                          child: Text(
                            AppStrings.resend,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 100),
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
                      AppStrings.emailVerified,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      AppStrings.emailVerifiedDesc,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 40),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
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
