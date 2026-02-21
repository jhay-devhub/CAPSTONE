import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';

/// Large pulsing HELP button displayed at the centre of the Home screen.
/// Delegates the tap action up via [onPressed] – no logic lives here.
class HelpButtonWidget extends StatefulWidget {
  const HelpButtonWidget({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });

  final VoidCallback onPressed;
  final bool isEnabled;

  @override
  State<HelpButtonWidget> createState() => _HelpButtonWidgetState();
}

class _HelpButtonWidgetState extends State<HelpButtonWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isEnabled ? _pulseAnimation.value : 1.0,
          child: child,
        );
      },
      child: _HelpButtonCore(
        onPressed: widget.isEnabled ? widget.onPressed : null,
      ),
    );
  }
}

/// The visual core of the HELP button – separated so [AnimatedBuilder]
/// does not rebuild the full subtree on every animation tick.
class _HelpButtonCore extends StatelessWidget {
  const _HelpButtonCore({this.onPressed});

  final VoidCallback? onPressed;

  static const double _buttonSize = 180.0;
  static const double _shadowBlur = 40.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: _buttonSize,
        height: _buttonSize,
        decoration: BoxDecoration(
          color: onPressed != null
              ? AppColors.helpButton
              : AppColors.navUnselected,
          shape: BoxShape.circle,
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: AppColors.helpButtonShadow,
                    blurRadius: _shadowBlur,
                    spreadRadius: 10,
                  ),
                ]
              : null,
        ),
        child: const Center(
          child: Text(
            AppStrings.helpButtonLabel,
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }
}
