import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/safety_tip_model.dart';

/// A single safety tip card – completely stateless and display-only.
class SafetyTipCardWidget extends StatelessWidget {
  const SafetyTipCardWidget({
    super.key,
    required this.tip,
  });

  final SafetyTipModel tip;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: _CategoryIconBadge(icon: tip.icon),
        title: Text(
          tip.title,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            tip.description,
            style: textTheme.bodyMedium,
          ),
        ),
        trailing: _CategoryChip(category: tip.category),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _CategoryIconBadge extends StatelessWidget {
  const _CategoryIconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.primary, size: 24),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final SafetyTipCategory category;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        category.label,
        style: const TextStyle(fontSize: 11, color: AppColors.textOnPrimary),
      ),
      backgroundColor: AppColors.primary,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
