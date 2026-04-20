import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/order_card.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      itemCount: 2,
      separatorBuilder: (_, __) => Column(
        children: const [
          SizedBox(height: 20),
          Divider(color: AppColors.border, height: 1),
          SizedBox(height: 20),
        ],
      ),
      itemBuilder: (_, i) => OrderCard(
        date: i == 0 ? '4.5 SUN' : '3.2 SUN',
        status: 'Upcoming',
        storeName: i == 0
            ? 'Hongik University Rice Noodles'
            : 'A Twosome Place',
        queueInfo: i == 0
            ? 'Queue Number 317 | 2 guests'
            : 'Queue Number 245 | 7 guests',
      ),
    );
  }
}
