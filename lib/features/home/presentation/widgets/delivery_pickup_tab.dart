import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class DeliveryPickupTab extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const DeliveryPickupTab({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 0),
      decoration: const BoxDecoration(color: AppColors.bgWhite),
      child: Row(
        children: [
          _Tab(
            label: 'Delivery',
            active: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          const SizedBox(width: 20),
          _Tab(
            label: 'Pickup',
            active: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: active ? AppColors.primary : AppColors.inactive,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: label.length * 8.0,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ],
      ),
    );
  }
}
