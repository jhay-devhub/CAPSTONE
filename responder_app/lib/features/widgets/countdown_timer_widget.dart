// features/widgets/countdown_timer_widget.dart
// LB-Sentry | Animated Countdown Timer

import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

class CountdownTimerWidget extends StatelessWidget {
  final int seconds;
  final double size;

  const CountdownTimerWidget({
    super.key,
    required this.seconds,
    this.size = 80,
  });

  Color get _color {
    if (seconds > 30) return AppColors.resolved;
    if (seconds > 15) return AppColors.arrived;
    return AppColors.primary;
  }

  double get _progress => seconds / 60.0;

  String get _formatted {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 6,
              color: Colors.grey.shade100,
            ),
          ),
          // Animated progress
          SizedBox(
            width: size,
            height: size,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: CircularProgressIndicator(
                key: ValueKey(_progress),
                value: _progress,
                strokeWidth: 6,
                color: _color,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          // Time text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.bold,
                  color: _color,
                ),
                child: Text(_formatted),
              ),
              Text(
                'left',
                style: TextStyle(
                  fontSize: size * 0.13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
