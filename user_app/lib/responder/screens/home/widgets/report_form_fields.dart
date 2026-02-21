import 'package:flutter/material.dart';
import '../../../constants/app_strings.dart';

/// Description text field – optional, multi-line free text.
///
/// Accepts a [TextEditingController] so the parent (form sheet) owns
/// the controller lifecycle and can read the value on submit.
class ReportDescriptionField extends StatelessWidget {
  const ReportDescriptionField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _MultiLineField(
      controller: controller,
      hintText: AppStrings.reportDescriptionHint,
      maxLines: 3,
    );
  }
}

/// Injury notes field – optional, multi-line free text.
///
/// Accepts a [TextEditingController] so the parent owns the lifecycle.
class ReportInjuryField extends StatelessWidget {
  const ReportInjuryField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _MultiLineField(
      controller: controller,
      hintText: AppStrings.reportInjuryHint,
      maxLines: 3,
    );
  }
}

// ── Shared private widget ─────────────────────────────────────────────────────

class _MultiLineField extends StatelessWidget {
  const _MultiLineField({
    required this.controller,
    required this.hintText,
    required this.maxLines,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
