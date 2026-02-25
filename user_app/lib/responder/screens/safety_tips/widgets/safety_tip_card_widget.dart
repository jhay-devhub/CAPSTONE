import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/safety_tip_model.dart';

/// An expandable safety tip card. Tap to show/hide step-by-step instructions.
class SafetyTipCardWidget extends StatefulWidget {
  const SafetyTipCardWidget({
    super.key,
    required this.tip,
  });

  final SafetyTipModel tip;

  @override
  State<SafetyTipCardWidget> createState() => _SafetyTipCardWidgetState();
}

class _SafetyTipCardWidgetState extends State<SafetyTipCardWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final categoryColor = widget.tip.category.color;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: _isExpanded ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: _isExpanded
            ? BorderSide(color: categoryColor.withAlpha(80), width: 1.5)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.tip.steps.isNotEmpty ? _toggleExpanded : null,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Row(
                  children: [
                    // Category icon badge
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: categoryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.tip.icon,
                        color: categoryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title + description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.tip.title,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.tip.description,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Expand icon
                    if (widget.tip.steps.isNotEmpty)
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),

              // ── Expandable steps ──────────────────────────────────────
              if (_isExpanded && widget.tip.steps.isNotEmpty) ...[
                Divider(
                  height: 1,
                  color: categoryColor.withAlpha(30),
                ),
                Container(
                  width: double.infinity,
                  color: categoryColor.withAlpha(8),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Steps to follow:',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: categoryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(
                        widget.tip.steps.length,
                        (index) => _StepRow(
                          stepNumber: index + 1,
                          text: widget.tip.steps[index],
                          color: categoryColor,
                          isLast: index == widget.tip.steps.length - 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A single numbered step row inside the expanded card.
class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.stepNumber,
    required this.text,
    required this.color,
    required this.isLast,
  });

  final int stepNumber;
  final String text;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$stepNumber',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Step text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
