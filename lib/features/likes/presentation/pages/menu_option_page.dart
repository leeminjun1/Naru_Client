import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../cart/presentation/pages/cart_list_page.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import 'cart_page.dart';

class MenuOptionPage extends StatefulWidget {
  final int? menuId;
  final int? storeId;
  final String? storeName;
  final String? storeImagePath;
  final int? basePrice;
  final String rank;
  final String menuName;
  final String description;
  final String imagePath;
  final bool initialIsPickup;

  const MenuOptionPage({
    super.key,
    this.menuId,
    this.storeId,
    this.storeName,
    this.storeImagePath,
    this.basePrice,
    required this.rank,
    required this.menuName,
    required this.description,
    required this.imagePath,
    this.initialIsPickup = false,
  });

  @override
  State<MenuOptionPage> createState() => _MenuOptionPageState();
}

class _MenuOptionPageState extends State<MenuOptionPage> {
  int _selectedSize = 0;
  int _selectedDrink = 0;
  int _quantity = 1;
  Timer? _cartSnackBarTimer;

  @override
  void dispose() {
    _cartSnackBarTimer?.cancel();
    super.dispose();
  }

  static const _sizes = [
    _Option('Small (2–3 servings)', '₩38,000', 38000),
    _Option('Medium (3–4 servings)', '₩48,000', 48000),
    _Option('Large (4–5 servings)', '₩58,000', 58000),
  ];

  List<_Option> get _priceOptions {
    final basePrice = widget.basePrice;
    if (basePrice == null || basePrice <= 0) return _sizes;
    return [
      _Option('Menu price', CurrencyFormatter.formatKrw(basePrice), basePrice),
    ];
  }

  static const _drinks = [
    _Option('CokaCola 500ml', '+ ₩0', 0),
    _Option('Sprite 500ml', '+ ₩0', 0),
    _Option('Fanta', '+ ₩1,000', 1000),
  ];

  static const _cafeAddOns = [
    _Option('No extra', '+ ₩0', 0),
    _Option('Extra shot', '+ ₩500', 500),
    _Option('Oat milk', '+ ₩700', 700),
  ];

  bool get _isCafeMenu {
    final value =
        '${widget.storeName ?? ''} ${widget.menuName} ${widget.imagePath}'
            .toLowerCase();
    return value.contains('ediya') ||
        value.contains('coffee') ||
        value.contains('cafe') ||
        value.contains('americano') ||
        value.contains('latte') ||
        value.contains('ade') ||
        value.contains('tea');
  }

  List<_Option> get _tertiaryOptions => _isCafeMenu ? _cafeAddOns : _drinks;

  String get _tertiaryTitle => _isCafeMenu ? 'Add option' : 'Choose Drink';

  int get _totalPrice {
    final priceOptions = _priceOptions;
    final selectedSize =
        _selectedSize >= priceOptions.length ? 0 : _selectedSize;
    final base = priceOptions[selectedSize].price;
    final tertiaryAdd = _tertiaryOptions[_selectedDrink].price;
    return (base + tertiaryAdd) * _quantity;
  }

  String get _orderLabel {
    return 'Order Now ${CurrencyFormatter.formatKrw(_totalPrice)}';
  }

  void _addToCart() {
    final priceOptions = _priceOptions;
    final selectedSize =
        _selectedSize >= priceOptions.length ? 0 : _selectedSize;
    final unitPrice = priceOptions[selectedSize].price +
        _tertiaryOptions[_selectedDrink].price;

    final added = context.read<CartProvider>().addItem(
          menuId: widget.menuId,
          storeId: widget.storeId,
          storeName: widget.storeName,
          storeImagePath: widget.storeImagePath,
          menuName: widget.menuName,
          imagePath: widget.imagePath,
          selectedSize: priceOptions[selectedSize].label,
          selectedJokbal: 'No extra',
          selectedDrink: _tertiaryOptions[_selectedDrink].label,
          unitPrice: unitPrice,
          quantity: _quantity,
        );

    if (!added) {
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

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    _cartSnackBarTimer?.cancel();
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text(
          'Added to cart',
          style: TextStyle(fontFamily: 'Pretendard', fontSize: 14),
        ),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: AppColors.brandOrange,
          onPressed: () {
            _cartSnackBarTimer?.cancel();
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
    _cartSnackBarTimer = Timer(
      const Duration(seconds: 3),
      messenger.hideCurrentSnackBar,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RankBadge(label: widget.rank),
                        const SizedBox(height: 8),
                        Text(
                          widget.menuName,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Row(
                          children: [
                            Icon(Icons.star_rounded,
                                color: Color(0xFFFFC107), size: 15),
                            SizedBox(width: 3),
                            Text(
                              '3.2',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(width: 2),
                            Text(
                              '(132)',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.chevron_right,
                                size: 16, color: AppColors.textSecondary),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.description,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 20),
                        _OptionSection(
                          title: 'Price',
                          options: _priceOptions,
                          selectedIndex: _selectedSize,
                          onChanged: (i) => setState(() => _selectedSize = i),
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 20),
                        _OptionSection(
                          title: _tertiaryTitle,
                          options: _tertiaryOptions,
                          selectedIndex: _selectedDrink,
                          onChanged: (i) => setState(() => _selectedDrink = i),
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 20),
                        _QuantityRow(
                          quantity: _quantity,
                          onDecrement: () {
                            if (_quantity > 1) setState(() => _quantity--);
                          },
                          onIncrement: () => setState(() => _quantity++),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _BottomBar(
            orderLabel: _orderLabel,
            onCart: _addToCart,
            onOrder: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CartPage(
                  menuName: widget.menuName,
                  selectedSize: _priceOptions[
                          _selectedSize >= _priceOptions.length
                              ? 0
                              : _selectedSize]
                      .label,
                  selectedJokbal: 'No extra',
                  selectedDrink: _tertiaryOptions[_selectedDrink].label,
                  totalPrice: _totalPrice,
                  quantity: _quantity,
                  menuImagePath: widget.imagePath,
                  menuId: widget.menuId,
                  storeId: widget.storeId,
                  storeName: widget.storeName,
                  storeImagePath: widget.storeImagePath,
                  initialIsPickup: widget.initialIsPickup,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.bgWhite,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              size: 16, color: AppColors.textPrimary),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _MenuOptionImage(imagePath: widget.imagePath),
      ),
    );
  }
}

class _MenuOptionImage extends StatelessWidget {
  final String imagePath;

  const _MenuOptionImage({required this.imagePath});

  static Future<ImageProvider?> _loadEmbeddedImage(String assetPath) async {
    final svg = await rootBundle.loadString(assetPath);
    final match = RegExp(r'base64,([^"\s]+)').firstMatch(svg);
    if (match == null) return null;
    return MemoryImage(base64Decode(match.group(1)!));
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('assets/')) {
      if (imagePath == 'assets/images/bongus.svg') {
        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          filterQuality: FilterQuality.high,
        );
      }
      if (imagePath.toLowerCase().endsWith('.svg')) {
        return FutureBuilder<ImageProvider?>(
          future: _loadEmbeddedImage(imagePath),
          builder: (context, snapshot) {
            final imageProvider = snapshot.data;
            if (imageProvider != null) {
              return Image(
                image: imageProvider,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                filterQuality: FilterQuality.high,
              );
            }
            return SvgPicture.asset(imagePath, fit: BoxFit.cover);
          },
        );
      }
      return Image.asset(imagePath, fit: BoxFit.cover);
    }
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.bgLight,
        alignment: Alignment.center,
        child: const Icon(Icons.fastfood, color: AppColors.textMuted),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final String label;
  const _RankBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _OptionSection extends StatelessWidget {
  final String title;
  final List<_Option> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _OptionSection({
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...options.asMap().entries.map((e) {
          final i = e.key;
          final opt = e.value;
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppColors.brandOrange
                            : const Color(0xFFCCCCCC),
                        width: selected ? 6 : 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      opt.label,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.w500 : FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.krwTextToUsd(opt.priceLabel),
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _QuantityRow extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityRow({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'quantity',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFDDDDDD), width: 1.2),
          ),
          child: Row(
            children: [
              _QtyButton(icon: Icons.remove, onTap: onDecrement),
              SizedBox(
                width: 36,
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _QtyButton(icon: Icons.add, onTap: onIncrement),
            ],
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String orderLabel;
  final VoidCallback onOrder;
  final VoidCallback onCart;

  const _BottomBar({
    required this.orderLabel,
    required this.onOrder,
    required this.onCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.bgWhite,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Minimum Order',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                CurrencyFormatter.formatKrw(15000),
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onCart,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.brandOrange, width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.brandOrange,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onOrder,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.brandOrange,
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: Text(
                  orderLabel,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Option {
  final String label;
  final String priceLabel;
  final int price;

  const _Option(this.label, this.priceLabel, this.price);
}
