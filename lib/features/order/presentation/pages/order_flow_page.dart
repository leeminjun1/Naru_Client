import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../widgets/order_step_indicator.dart';

class OrderFlowPage extends StatefulWidget {
  const OrderFlowPage({super.key});

  @override
  State<OrderFlowPage> createState() => _OrderFlowPageState();
}

class _OrderFlowPageState extends State<OrderFlowPage> {
  int _step = 0;

  static const List<_MenuItem> _priceOptions = [
    _MenuItem('Small (2–3 servings)', '₩38,000'),
    _MenuItem('Medium (3–4 servings)', '₩48,000'),
    _MenuItem('Large (4–5 servings)', '₩58,000'),
  ];

  static const List<_MenuItem> _jokbalOptions = [
    _MenuItem('Jokbal', '+ ₩0'),
    _MenuItem('Medium (3–4 servings)', '+ ₩3,000'),
    _MenuItem('Large (4–5 servings)', '+ ₩3,000'),
  ];

  static const List<_MenuItem> _drinkOptions = [
    _MenuItem('CokaCola 500ml', '+ ₩0'),
    _MenuItem('Sprite 500ml', '+ ₩0'),
    _MenuItem('Fanta', '+ ₩1,000'),
  ];

  int _selectedPrice = 0;
  int _selectedJokbal = 0;
  int _selectedDrink = 0;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          // Hero image
          Stack(
            children: [
              Container(
                height: 280,
                width: double.infinity,
                color: const Color(0xFFD4C8B8),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: OrderStepIndicator(
                      currentStep: _step, totalSteps: 5),
                ),
              ),
            ],
          ),
          // Content sheet
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.bgLight,
                        borderRadius: BorderRadius.circular(21),
                      ),
                      child: Text('Top 1',
                          style: AppTextStyles.caption.copyWith(
                              color: const Color(0xFF787E81))),
                    ),
                    const SizedBox(height: 8),
                    Text('Half [Jok, Bo Set]', style: AppTextStyles.h1),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: Colors.amber),
                        Text(' 3.2',
                            style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        Text(' (132)',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.textMuted)),
                        const Icon(Icons.chevron_right,
                            size: 16, color: AppColors.textMuted),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cold Makguksu + Tuna Mayo Rice Balls + Fresh Wrap Vegetables + Drink + Dried Radish Side Dish Set',
                      style: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted),
                    ),
                    _divider(),
                    _Section(
                      title: 'Price',
                      options: _priceOptions,
                      selected: _selectedPrice,
                      onChanged: (i) => setState(() => _selectedPrice = i),
                    ),
                    _divider(),
                    _Section(
                      title: 'Choose Jokbal',
                      options: _jokbalOptions,
                      selected: _selectedJokbal,
                      onChanged: (i) => setState(() => _selectedJokbal = i),
                    ),
                    _divider(),
                    _Section(
                      title: 'Choose Drink',
                      options: _drinkOptions,
                      selected: _selectedDrink,
                      onChanged: (i) => setState(() => _selectedDrink = i),
                    ),
                    _divider(),
                    // Quantity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('quantity', style: AppTextStyles.h3),
                        Container(
                          height: 46,
                          width: 161,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (_quantity > 1) {
                                    setState(() => _quantity--);
                                  }
                                },
                                child: const Icon(Icons.remove, size: 24),
                              ),
                              Text('$_quantity', style: AppTextStyles.body),
                              GestureDetector(
                                onTap: () => setState(() => _quantity++),
                                child: const Icon(Icons.add, size: 24),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom order bar
      bottomNavigationBar: Container(
        height: 119,
        decoration: const BoxDecoration(
          color: AppColors.bgWhite,
          border: Border(top: BorderSide(color: AppColors.separator)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Minimum Order',
                    style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF343638))),
                const SizedBox(height: 2),
                Text('₩ 15,000',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF343638))),
              ],
            ),
            const SizedBox(width: 22),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 47,
                  decoration: BoxDecoration(
                    color: AppColors.orderButton,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text('Order ₩38,000',
                      style: AppTextStyles.button),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        height: 10,
        margin: const EdgeInsets.symmetric(vertical: 16),
        color: AppColors.bgLight,
      );
}

class _Section extends StatelessWidget {
  final String title;
  final List<_MenuItem> options;
  final int selected;
  final ValueChanged<int> onChanged;

  const _Section({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        const SizedBox(height: 12),
        ...List.generate(options.length, (i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: active
                                ? AppColors.primary
                                : AppColors.border,
                            width: active ? 5 : 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(options[i].label,
                          style: AppTextStyles.body.copyWith(fontSize: 16)),
                    ],
                  ),
                  Text(options[i].price,
                      style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _MenuItem {
  final String label;
  final String price;
  const _MenuItem(this.label, this.price);
}
