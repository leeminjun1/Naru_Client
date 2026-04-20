import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class SelectLocationPage extends StatelessWidget {
  const SelectLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        title: Text('Select Location', style: AppTextStyles.h3),
      ),
      body: const Center(
        child: Icon(Icons.location_on_outlined, size: 80, color: AppColors.inactive),
      ),
    );
  }
}
