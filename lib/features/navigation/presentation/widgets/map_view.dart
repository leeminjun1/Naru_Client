import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD4E2C8),
      child: const Center(
        child: Icon(Icons.map_outlined, size: 80, color: AppColors.inactive),
      ),
    );
  }
}
