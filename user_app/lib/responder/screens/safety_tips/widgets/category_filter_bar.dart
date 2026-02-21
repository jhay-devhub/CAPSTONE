import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/safety_tip_model.dart';

/// Horizontal chip bar that lets users filter safety tips by category.
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final SafetyTipCategory? selectedCategory;
  final ValueChanged<SafetyTipCategory?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
          ),
          ...SafetyTipCategory.values.map(
            (category) => _FilterChip(
              label: category.label,
              isSelected: selectedCategory == category,
              onTap: () => onCategorySelected(
                selectedCategory == category ? null : category,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        checkmarkColor: AppColors.textOnPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
    );
  }
}
