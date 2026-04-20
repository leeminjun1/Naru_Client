import 'package:flutter/material.dart';
import 'home_delivery_page.dart';

class HomePickupPage extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const HomePickupPage({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return HomeDeliveryPage(
      selectedIndex: selectedIndex,
      onTabChanged: onTabChanged,
    );
  }
}
