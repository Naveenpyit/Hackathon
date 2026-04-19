import 'package:flutter/material.dart';
import 'frontend/config/theme.dart';
import 'frontend/presentation/screens/welcome_screen.dart';
import 'frontend/presentation/screens/signin_screen.dart';
import 'frontend/presentation/screens/signup_screen.dart';
import 'frontend/presentation/screens/forgot_password_screen.dart';
import 'frontend/presentation/screens/email_verification_screen.dart';
import 'frontend/presentation/screens/chats_screen.dart';
import 'frontend/presentation/widgets/connection_status_bar.dart';
import 'frontend/core/routes/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppTheme.setSystemUI();
  runApp(const SmartApp());
}

class SmartApp extends StatefulWidget {
  const SmartApp({Key? key}) : super(key: key);

  @override
  State<SmartApp> createState() => _SmartAppState();
}

class _SmartAppState extends State<SmartApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart App',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const WelcomeScreen(),
      // Wraps every route with:
      //   1. A gradient banner behind the OS status bar (matches Get Started btn)
      //   2. The connection status banner (visible only when offline)
      //   3. The actual app content
      builder: (context, child) {
        final statusBarHeight = MediaQuery.of(context).padding.top;
        return Column(
          children: [
            // Gradient strip that fills the OS status bar area
            Container(
              height: statusBarHeight,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
            ),
            const ConnectionStatusBar(),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        );
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/welcome':
            return SlidePageRoute(
              page: const WelcomeScreen(),
              direction: SlideDirection.rightToLeft,
            );
          case '/signin':
            return SlidePageRoute(
              page: const SignInScreen(),
              direction: SlideDirection.rightToLeft,
            );
          case '/signup':
            return SlidePageRoute(
              page: const SignUpScreen(),
              direction: SlideDirection.rightToLeft,
            );
          case '/forgot_password':
            return SlidePageRoute(
              page: const ForgotPasswordScreen(),
              direction: SlideDirection.rightToLeft,
            );
          case '/email_verification':
            return SlidePageRoute(
              page: const EmailVerificationScreen(),
              direction: SlideDirection.rightToLeft,
            );
          case '/chats':
            return SlidePageRoute(
              page: const ChatsScreen(),
              direction: SlideDirection.rightToLeft,
            );
          default:
            return SlidePageRoute(
              page: const WelcomeScreen(),
              direction: SlideDirection.rightToLeft,
            );
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
