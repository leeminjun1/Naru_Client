import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../cart/presentation/pages/cart_list_page.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../../data/models/order_history_model.dart';
import '../widgets/order_thumbnail.dart';

class CompletedOrdersPage extends StatefulWidget {
  const CompletedOrdersPage({super.key});

  @override
  State<CompletedOrdersPage> createState() => _CompletedOrdersPageState();
}

class _CompletedOrdersPageState extends State<CompletedOrdersPage> {
  String _selectedCategory = 'ALL';

  static const _categories = [
    'ALL',
    'Korean',
    'Street',
    'BBQ',
    'Chicken',
    'Asian'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, provider, _) {
        final orders = provider.completed;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final selected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.brandOrange
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.brandOrange
                              : const Color(0xFFD0D0D0),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color:
                              selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : orders.isEmpty
                      ? const Center(
                          child: Text(
                            'No completed orders',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: orders.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFEEEEEE),
                            indent: 20,
                            endIndent: 20,
                          ),
                          itemBuilder: (context, i) {
                            final order = orders[i];
                            final showDate = i == 0 ||
                                orders[i - 1].formattedDate !=
                                    order.formattedDate;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showDate)
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        20, i == 0 ? 16 : 20, 20, 8),
                                    child: Text(
                                      order.formattedDate,
                                      style: const TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                _CompletedOrderRow(order: order),
                              ],
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}

class _CompletedOrderRow extends StatelessWidget {
  final OrderHistoryModel order;
  const _CompletedOrderRow({required this.order});

  static String _formatPrice(int price) => CurrencyFormatter.formatKrw(price);

  void _reorder(BuildContext context) {
    final cart = context.read<CartProvider>();
    final items = order.items.isNotEmpty
        ? order.items
        : [
            OrderHistoryItemModel(
              name: order.itemSummary,
              imageUrl: order.displayImageUrl,
              quantity: 1,
              unitPrice: order.totalAmount,
            ),
          ];

    if (!cart.canAddStore(
      storeId: order.storeId,
      storeName: order.storeName,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your cart contains items from another store. Clear it first.',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 14),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    for (final item in items) {
      final quantity = item.quantity <= 0 ? 1 : item.quantity;
      final unitPrice = item.unitPrice > 0
          ? item.unitPrice
          : (order.totalAmount / quantity).round();

      cart.addItem(
        menuId: item.menuId,
        storeId: order.storeId,
        storeName: order.storeName,
        storeImagePath: order.displayStoreImageUrl,
        menuName: item.name,
        imagePath: item.imageUrl ??
            order.displayStoreImageUrl ??
            'assets/images/food_jokbal.png',
        selectedSize: item.selectedSize ?? 'Menu price',
        selectedJokbal: item.selectedJokbal ?? 'No extra',
        selectedDrink: item.selectedDrink ?? 'No drink',
        unitPrice: unitPrice,
        quantity: quantity,
      );
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    messenger.hideCurrentSnackBar();
    final controller = messenger.showSnackBar(
      SnackBar(
        content: Text(
          '${items.length} item${items.length == 1 ? '' : 's'} added to cart',
          style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14),
        ),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: AppColors.brandOrange,
          onPressed: () {
            messenger.hideCurrentSnackBar();
            navigator.push(
              MaterialPageRoute(builder: (_) => const CartListPage()),
            );
          },
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Future<void>.delayed(const Duration(seconds: 3), controller.close);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          OrderThumbnail(imageUrl: order.displayStoreImageUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.displayStatus,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(order.totalAmount),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _reorder(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.brandOrange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Reorder',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
