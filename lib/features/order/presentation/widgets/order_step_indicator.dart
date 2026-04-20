import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OrderStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OrderStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final active = i <= currentStep;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 4 : 0),
            color: active ? AppColors.primary : AppColors.border,
          ),
        );
      }),
    );
  }
}
