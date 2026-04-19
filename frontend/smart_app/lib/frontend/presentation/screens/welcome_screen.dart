import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/strings.dart';
import '../../core/utils/responsive_design.dart';
import '../widgets/smart_app_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _float;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic),
        );
    _float = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _pulse = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _heroController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = ResponsiveDesign.isTablet(context);
    final isPortrait = ResponsiveDesign.isPortrait(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          _buildBgDecor(size),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ResponsiveContainer(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet
                          ? AppTheme.spacingXL
                          : AppTheme.spacingL,
                      vertical: AppTheme.spacingL,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: isPortrait
                              ? size.height * 0.06
                              : AppTheme.spacingL,
                        ),
                        _buildLogo(isTablet, isPortrait),
                        SizedBox(
                          height: isPortrait
                              ? size.height * 0.04
                              : AppTheme.spacingM,
                        ),
                        _buildHeroText(context, isTablet),
                        SizedBox(
                          height: isPortrait
                              ? size.height * 0.05
                              : AppTheme.spacingL,
                        ),
                        _buildFeaturesSection(context, isPortrait, isTablet),
                        SizedBox(
                          height: isPortrait
                              ? size.height * 0.05
                              : AppTheme.spacingL,
                        ),
                        _buildButtons(context),
                        SizedBox(
                          height: isPortrait
                              ? size.height * 0.04
                              : AppTheme.spacingM,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBgDecor(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -80,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Transform.scale(
              scale: _pulse.value,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withAlpha(22),
                      AppTheme.primaryColor.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: size.height * 0.2,
          left: -60,
          child: AnimatedBuilder(
            animation: _floatController,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _float.value),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentColor.withAlpha(18),
                      AppTheme.accentColor.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        ..._sparkles(size),
      ],
    );
  }

  List<Widget> _sparkles(Size size) {
    final positions = [
      [0.12, 0.14],
      [0.85, 0.10],
      [0.04, 0.50],
      [0.93, 0.37],
      [0.70, 0.22],
      [0.28, 0.76],
    ];
    return positions.asMap().entries.map((e) {
      final i = e.key;
      final p = e.value;
      return Positioned(
        left: size.width * p[0],
        top: size.height * p[1],
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (_, __) => Opacity(
            opacity:
                (0.2 + 0.3 * math.sin(_floatController.value * math.pi + i))
                    .abs(),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: i.isEven
                    ? AppTheme.primaryColor.withAlpha(130)
                    : AppTheme.accentColor.withAlpha(130),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLogo(bool isTablet, bool isPortrait) {
    final sz = isPortrait ? (isTablet ? 100.0 : 88.0) : 68.0;
    return Hero(
      tag: 'logo',
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _float.value * 0.5),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Transform.scale(
                  scale: _pulse.value,
                  child: Container(
                    width: sz + 58,
                    height: sz + 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular((sz + 58) * 0.22),
                      border: Border.all(
                        color: AppTheme.primaryColor.withAlpha(28),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: sz + 28,
                height: sz + 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular((sz + 28) * 0.22),
                  border: Border.all(
                    color: AppTheme.primaryColor.withAlpha(55),
                    width: 1.5,
                  ),
                ),
              ),
              SmartAppLogo(size: sz, withShadow: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroText(BuildContext context, bool isTablet) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            AppStrings.welcomeTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontSize: isTablet ? AppTheme.fontSize3XL * 1.3 : null,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Text(
          AppStrings.welcomeSubtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: isTablet ? AppTheme.fontSizeL : null,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(
    BuildContext context,
    bool isPortrait,
    bool isTablet,
  ) {
    final features = [
      _Feat(
        Icons.flash_on_rounded,
        AppStrings.featureMessaging,
        AppStrings.featureMessagingDesc,
        AppTheme.primaryColor,
      ),
      _Feat(
        Icons.groups_2_rounded,
        AppStrings.featureCollaboration,
        AppStrings.featureCollaborationDesc,
        AppTheme.accentColor,
      ),
      _Feat(
        Icons.shield_rounded,
        AppStrings.featureSecurity,
        AppStrings.featureSecurityDesc,
        AppTheme.successColor,
      ),
    ];

    if (isTablet && !isPortrait) {
      return Row(
        children: features
            .map(
              (f) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                  ),
                  child: _FeatureCard(feat: f),
                ),
              ),
            )
            .toList(),
      );
    }
    return Column(
      children: features
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
              child: _FeatureCard(feat: f),
            ),
          )
          .toList(),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: const [
              BoxShadow(
                color: Color(0x506C63FF),
                blurRadius: 18,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              onTap: () => Navigator.pushNamed(context, '/signin'),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.getStarted,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTheme.fontSizeXL,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingS),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: AppTheme.primaryColor, width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              onTap: () => Navigator.pushNamed(context, '/signup'),
              child: Center(
                child: Text(
                  AppStrings.createAccount,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Feat {
  final IconData icon;
  final String title, description;
  final Color color;
  const _Feat(this.icon, this.title, this.description, this.color);
}

class _FeatureCard extends StatelessWidget {
  final _Feat feat;
  const _FeatureCard({required this.feat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: feat.color.withAlpha(16),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: feat.color.withAlpha(22),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(feat.icon, color: feat.color, size: 26),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feat.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  feat.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
