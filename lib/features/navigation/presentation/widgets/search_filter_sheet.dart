import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class SearchFilterSheet extends StatelessWidget {
  const SearchFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Filter', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Text('Transport', style: AppTextStyles.title),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['Walk', 'Transit', 'Drive'].map((t) => Chip(
              label: Text(t, style: AppTextStyles.caption),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
