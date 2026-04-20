import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';

class NaruBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const NaruBottomNavBar({super.key, required this.currentIndex});

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_outlined, label: 'Home', route: AppRouter.home),
    _NavItem(
        icon: Icons.location_on_outlined,
        label: 'Navigation',
        route: AppRouter.navigation),
    _NavItem(
        icon: Icons.favorite_border,
        label: 'Likes',
        route: AppRouter.favorites),
    _NavItem(
        icon: Icons.list_alt_outlined, label: 'Lists', route: AppRouter.lists),
    _NavItem(icon: Icons.person_outline, label: 'My', route: AppRouter.myPage),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        border: const Border(top: BorderSide(color: AppColors.separator)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 14.4,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final active = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!active) {
                  Navigator.pushReplacementNamed(context, item.route);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 24,
                    color: active ? AppColors.dark : AppColors.inactive,
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.label,
                          maxLines: 1,
                          softWrap: false,
                          style: AppTextStyles.caption.copyWith(
                            color: active ? AppColors.dark : AppColors.inactive,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(
      {required this.icon, required this.label, required this.route});
}
