import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// A row of four summary stat cards shown at the top of the dashboard.
/// Replace each [value] with live data when wiring up real data sources.
class StatCardsRow extends StatelessWidget {
  const StatCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatCard(
          icon: Icons.emergency_outlined,
          label: 'Total Emergency',
          value: '—',
          color: AppColors.primary,
        ),
        const SizedBox(width: 16),
        StatCard(
          icon: Icons.report_problem_outlined,
          label: 'Active',
          value: '—',
          color: const Color.fromARGB(255, 255, 0, 0),
        ),
        const SizedBox(width: 16),
        StatCard(
          icon: Icons.report_problem_outlined,
          label: 'Pending',
          value: '—',
          color: AppColors.warning,
        ),
        const SizedBox(width: 16),
        StatCard(
          icon: Icons.check_circle_outline,
          label: 'Resolved',
          value: '—',
          color: const Color.fromARGB(255, 21, 255, 0),
        ),
      ],
    );
  }
}

// ── Individual stat card ───────────────────────────────────────────────────────

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
