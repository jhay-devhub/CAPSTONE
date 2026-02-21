import 'package:flutter/material.dart';
import '../../../constants/app_strings.dart';

/// Displays the greeting header and subtitle on the Home screen.
/// Text is right-aligned to match the overall right-shifted layout.
class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          AppStrings.homeGreeting,
          style: textTheme.headlineLarge,
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.homeSubtitle,
          style: textTheme.bodyMedium,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
