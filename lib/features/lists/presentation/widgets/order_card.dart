import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class OrderCard extends StatelessWidget {
  final String date;
  final String status;
  final String storeName;
  final String queueInfo;
  final String? imageUrl;

  const OrderCard({
    super.key,
    required this.date,
    required this.status,
    required this.storeName,
    required this.queueInfo,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(date, style: AppTextStyles.captionMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderDark),
                color: AppColors.bgLight,
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(imageUrl!, fit: BoxFit.cover),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(status,
                      style: AppTextStyles.captionMedium.copyWith(
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(storeName,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(queueInfo,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentOrange)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
