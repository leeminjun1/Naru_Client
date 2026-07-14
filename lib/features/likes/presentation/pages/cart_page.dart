import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_asset_image.dart';
import '../../../home/presentation/pages/search_page.dart' as home_search;
import 'order_page.dart';

class CartPage extends StatefulWidget {
  final int? menuId;
  final int? storeId;
  final String? storeName;
  final String? storeImagePath;
  final String menuName;
  final String selectedSize;
  final String selectedJokbal;
  final String selectedDrink;
  final int totalPrice;
  final int quantity;
  final String menuImagePath;
  final bool initialIsPickup;

  const CartPage({
    super.key,
    this.menuId,
    this.storeId,
    this.storeName,
    this.storeImagePath,
    required this.menuName,
    required this.selectedSize,
    required this.selectedJokbal,
    required this.selectedDrink,
    required this.totalPrice,
    required this.quantity,
    required this.menuImagePath,
    this.initialIsPickup = false,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _quantity = 1;
  int _selectedMethod = 0; // 0: Store Delivery, 1: Pick up
  final Set<String> _addedExtras = {};

  static const _extras = [
    _ExtraItem(
      name: 'CocaCola',
      price: 2000,
      priceLabel: '₩2,000',
      imagePath: 'assets/images/coke.png',
    ),
    _ExtraItem(
      name: 'Fanta',
      price: 2500,
      priceLabel: '₩2,500',
      imagePath: 'assets/images/fanta.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity;
    _selectedMethod = widget.initialIsPickup ? 1 : 0;
  }

  int get _extrasTotal {
    int total = 0;
    for (final e in _extras) {
      if (_addedExtras.contains(e.name)) total += e.price;
    }
    return total;
  }

  int get _menuUnitTotal => widget.quantity <= 0
      ? widget.totalPrice
      : widget.totalPrice ~/ widget.quantity;
  int get _menuTotal => _menuUnitTotal * _quantity;
  int get _subtotal => _menuTotal + _extrasTotal;
  int get _totalPayment => _subtotal;
  String get _selectedExtrasLabel {
    final selectedExtras = _extras
        .where((extra) => _addedExtras.contains(extra.name))
        .map((extra) => extra.name)
        .toList();
    if (selectedExtras.isEmpty) return widget.selectedDrink;
    return '${widget.selectedDrink} · ${selectedExtras.join(' · ')}';
  }

  String get _displayStoreName =>
      widget.storeName ?? 'Simin Jokbal Bossam Sillim';

  String get _displayStoreImage =>
      widget.storeImagePath ?? widget.menuImagePath;

  String _formatPrice(int price) {
    return CurrencyFormatter.formatKrw(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStoreHeader(),
                    _buildCartItem(),
                    const SizedBox(height: 16),
                    const Divider(
                        height: 8, thickness: 8, color: Color(0xFFF3F5F7)),
                    _buildPerfectTogether(),
                    const Divider(
                        height: 8, thickness: 8, color: Color(0xFFF3F5F7)),
                    _buildOrderMethod(),
                    const Divider(
                        height: 8, thickness: 8, color: Color(0xFFF3F5F7)),
                    _buildPaymentSummary(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: AppColors.textPrimary),
          ),
          const Expanded(
            child: Text(
              'Cart',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const home_search.SearchPage(),
              ),
            ),
            icon: const Icon(
              Icons.search,
              size: 22,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE4E6E8), width: 1),
            ),
            child: _CartPageImage(imagePath: _displayStoreImage),
          ),
          const SizedBox(width: 10),
          Text(
            _displayStoreName,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right,
              size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildCartItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.menuName,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.selectedSize,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    widget.selectedJokbal,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    widget.selectedDrink,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatPrice(_menuTotal),
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFCCCCCC), width: 1),
                          ),
                          child: const Text(
                            'Option change',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _QuantityControl(
                        quantity: _quantity,
                        onDecrement: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                        onIncrement: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _CartPageSizedImage(
                imagePath: widget.menuImagePath,
                width: 72,
                height: 72,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerfectTogether() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perfect Together',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._extras.map((e) {
            final added = _addedExtras.contains(e.name);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(e.imagePath,
                          width: 44, height: 44, fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.name,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.krwTextToUsd(e.priceLabel),
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        if (added) {
                          _addedExtras.remove(e.name);
                        } else {
                          _addedExtras.add(e.name);
                        }
                      }),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: added
                                ? AppColors.brandOrange
                                : const Color(0xFFCCCCCC),
                            width: 1.5,
                          ),
                          color: added
                              ? AppColors.brandOrange
                              : Colors.transparent,
                        ),
                        child: Icon(
                          added ? Icons.check : Icons.add,
                          size: 16,
                          color: added ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderMethod() {
    const methods = [
      _DeliveryMethod('Store Delivery', 'Arrives in 39–54 min'),
      _DeliveryMethod('Pick up', 'Pick up in 24–45 min'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose your order method',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...methods.asMap().entries.map((e) {
            final selected = e.key == _selectedMethod;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selectedMethod = e.key),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.textPrimary
                          : const Color(0xFFDDDDDD),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.value.title,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        e.value.subtitle,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review your payment amount',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _formatPrice(_subtotal),
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Payment',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _formatPrice(_totalPayment),
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final label = _selectedMethod == 0 ? 'Delivery Order' : 'Pick Up Order';
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
              Text(
                _formatPrice(_totalPayment),
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'Order Available',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderPage(
                    menuId: widget.menuId,
                    storeId: widget.storeId,
                    storeName: _displayStoreName,
                    storeImagePath: _displayStoreImage,
                    menuName: widget.menuName,
                    selectedSize: widget.selectedSize,
                    selectedJokbal: widget.selectedJokbal,
                    selectedDrink: _selectedExtrasLabel,
                    totalPrice: _totalPayment,
                    menuImagePath: widget.menuImagePath,
                    isPickup: _selectedMethod == 1,
                  ),
                ),
              ),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.brandOrange,
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
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

class _CartPageImage extends StatelessWidget {
  final String imagePath;

  const _CartPageImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('assets/')) {
      return AppAssetImage(assetPath: imagePath, fit: BoxFit.cover);
    }
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.bgLight,
        alignment: Alignment.center,
        child: const Icon(Icons.store, color: AppColors.textMuted),
      ),
    );
  }
}

class _CartPageSizedImage extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;

  const _CartPageSizedImage({
    required this.imagePath,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('assets/')) {
      return AppAssetImage(
        assetPath: imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      imagePath,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: AppColors.bgLight,
        alignment: Alignment.center,
        child: const Icon(Icons.fastfood, color: AppColors.textMuted),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityControl({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1.2),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Icon(Icons.remove, size: 16, color: AppColors.textPrimary),
            ),
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Icon(Icons.add, size: 16, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtraItem {
  final String name;
  final int price;
  final String priceLabel;
  final String imagePath;

  const _ExtraItem({
    required this.name,
    required this.price,
    required this.priceLabel,
    required this.imagePath,
  });
}

class _DeliveryMethod {
  final String title;
  final String subtitle;

  const _DeliveryMethod(this.title, this.subtitle);
}
