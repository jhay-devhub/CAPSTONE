import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/help_report_model.dart';

/// Displays a 2-column grid of emergency type cards.
///
/// Responsibilities:
///   - Renders one [_EmergencyTypeCard] per [EmergencyType] value.
///   - Highlights the currently [selectedType].
///   - Shows a dispatch banner below the grid once a type is chosen.
///   - Shows a validation error when [showValidationError] is true.
///
/// All selection logic stays outside this widget; changes are reported
/// via [onTypeSelected].
class EmergencyTypeSelector extends StatelessWidget {
  const EmergencyTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    this.showValidationError = false,
  });

  final EmergencyType? selectedType;
  final ValueChanged<EmergencyType> onTypeSelected;
  final bool showValidationError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid of type cards
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
          ),
          itemCount: EmergencyType.values.length,
          itemBuilder: (_, index) {
            final type = EmergencyType.values[index];
            return _EmergencyTypeCard(
              type: type,
              isSelected: type == selectedType,
              onTap: () => onTypeSelected(type),
            );
          },
        ),

        // Validation error
        if (showValidationError) ...[
          const SizedBox(height: 6),
          Text(
            AppStrings.reportTypeRequired,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],

        // Dispatch banner – shown once a type is selected
        if (selectedType != null) ...[
          const SizedBox(height: 12),
          _DispatchBanner(emergencyType: selectedType!),
        ],
      ],
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

/// Single tappable card representing one [EmergencyType].
class _EmergencyTypeCard extends StatelessWidget {
  const _EmergencyTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final EmergencyType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedBg = AppColors.primary.withAlpha(220);
    final unselectedBg = AppColors.primary.withAlpha(18);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: isSelected ? selectedBg : unselectedBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(
                type.icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Banner shown below the grid to inform the user which vehicle will
/// be dispatched based on the selected emergency type.
class _DispatchBanner extends StatelessWidget {
  const _DispatchBanner({required this.emergencyType});

  final EmergencyType emergencyType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_shipping,
            size: 18,
            color: AppColors.accent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              emergencyType.vehicleDispatchNote,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
