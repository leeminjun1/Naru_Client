import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../cart/domain/cart_item.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../lists/data/models/order_history_model.dart';
import '../../../lists/presentation/providers/orders_provider.dart';
import '../../data/coupon_service.dart';
import '../../../order/data/order_service.dart';
import 'payment_success_page.dart';

class OrderPage extends StatefulWidget {
  final int? menuId;
  final int? storeId;
  final String? storeName;
  final String? storeImagePath;
  final String menuName;
  final String selectedSize;
  final String selectedJokbal;
  final String selectedDrink;
  final int totalPrice;
  final String menuImagePath;
  final bool isPickup;
  final List<CartItem>? cartItems;

  const OrderPage({
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
    required this.menuImagePath,
    required this.isPickup,
    this.cartItems,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int _selectedPayment = 0;
  int _selectedRequirement = 0;
  int _selectedMethod = 0; // 0: Store Delivery, 1: Pick up
  bool _noUtensils = true;
  bool _isOrdering = false;
  OrderService? _orderService;
  CouponService? _couponService;
  List<UserCoupon> _coupons = const [];
  UserCoupon? _selectedCoupon;
  bool _isLoadingCoupons = false;

  static const _paymentMethods = [
    'Credit',
    'Apple Pay',
    'Kakao Pay',
    'Global Payments',
  ];

  static const _storeRequirements = [
    'No requirement',
    'Please make it less spicy',
    'Please keep sauce on the side',
    'Please avoid pork',
    'Please avoid seafood',
    'Please avoid nuts',
    'Please label spicy items',
    'Please call if an item is unavailable',
  ];

  static const _orderMethods = [
    _DeliveryMethod('Store Delivery', 'Arrives in 39–54 min'),
    _DeliveryMethod('Pick up', 'Pick up in 24–45 min'),
  ];

  bool get _isPickupOrder => _selectedMethod == 1;
  int get _couponDiscount {
    final coupon = _selectedCoupon;
    if (coupon == null) return 0;
    return coupon.discountAmount.clamp(0, widget.totalPrice).toInt();
  }

  int get _paymentTotal =>
      (widget.totalPrice - _couponDiscount).clamp(0, widget.totalPrice).toInt();

  String _formatPrice(int price) => CurrencyFormatter.formatKrw(price);

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.isPickup ? 1 : 0;
    _initServices();
  }

  Future<void> _initServices() async {
    final api = await ApiClient.getInstance();
    if (mounted) {
      setState(() {
        _orderService = OrderService(api);
        _couponService = CouponService(api);
      });
    }
    await _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    final service = _couponService;
    if (service == null || _isLoadingCoupons) return;
    setState(() => _isLoadingCoupons = true);
    try {
      final coupons = await service.fetchCoupons();
      if (!mounted) return;
      setState(() => _coupons = coupons);
    } catch (_) {
      if (!mounted) return;
      setState(() => _coupons = const []);
    } finally {
      if (mounted) setState(() => _isLoadingCoupons = false);
    }
  }

  Future<void> _placeOrder() async {
    if (_isOrdering) return;
    setState(() => _isOrdering = true);

    final orderItems = _orderHistoryItems;
    final ordersProvider = context.read<OrdersProvider>();
    final cartProvider = context.read<CartProvider>();
    late final int remoteOrderId;

    try {
      final orderService = _orderService;
      if (orderService == null) {
        throw StateError('Order service is not ready. Please try again.');
      }
      final type = _isPickupOrder ? 'PICKUP' : 'DELIVERY';
      final directItems = widget.cartItems != null
          ? orderItems
              .map((item) => {
                    if (_cartItemFor(item)?.menuId != null)
                      'menuId': _cartItemFor(item)!.menuId,
                    if (_cartItemFor(item)?.storeId != null)
                      'storeId': _cartItemFor(item)!.storeId,
                    'name': item.name,
                    'imageUrl': item.imageUrl,
                    'image_url': item.imageUrl,
                    'menu_image': item.imageUrl,
                    'quantity': item.quantity,
                    'price': item.unitPrice,
                  })
              .toList()
          : [
              {
                if (widget.menuId != null) 'menuId': widget.menuId,
                if (widget.storeId != null) 'storeId': widget.storeId,
                'name': widget.menuName,
                'imageUrl': widget.menuImagePath,
                'image_url': widget.menuImagePath,
                'menu_image': widget.menuImagePath,
                'quantity': 1,
                'price': widget.totalPrice,
              }
            ];
      final remoteOrder = await orderService.createOrder(
        type: type,
        totalAmount: _paymentTotal,
        items: directItems,
        couponId: _selectedCoupon?.id,
        storeName: _displayStoreName,
        storeImageUrl: _displayStoreImage,
      );
      final parsedOrderId = (remoteOrder['id'] as num?)?.toInt();
      if (parsedOrderId == null || parsedOrderId <= 0) {
        throw const FormatException('The server returned an invalid order.');
      }
      remoteOrderId = parsedOrderId;
    } catch (error) {
      if (mounted) setState(() => _isOrdering = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not place your order. ${error.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isOrdering = false);
    final recordedOrder = await ordersProvider.recordLocalOrder(
      remoteOrderId: remoteOrderId,
      storeId: widget.storeId,
      storeName: _displayStoreName,
      storeImageUrl: _displayStoreImage,
      totalAmount: _paymentTotal,
      items: orderItems,
    );
    if (widget.cartItems != null) {
      cartProvider.clear();
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessPage(
          totalPrice: _paymentTotal,
          isPickup: _isPickupOrder,
          orderId: recordedOrder.id,
        ),
      ),
    );
  }

  List<OrderHistoryItemModel> get _orderHistoryItems {
    final cartItems = widget.cartItems;
    if (cartItems != null && cartItems.isNotEmpty) {
      return cartItems
          .map((item) => OrderHistoryItemModel(
                menuId: item.menuId,
                name: item.menuName,
                imageUrl: item.imagePath,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                selectedSize: item.selectedSize,
                selectedJokbal: item.selectedJokbal,
                selectedDrink: item.selectedDrink,
              ))
          .toList();
    }

    return [
      OrderHistoryItemModel(
        menuId: widget.menuId,
        name: widget.menuName,
        imageUrl: widget.menuImagePath,
        quantity: 1,
        unitPrice: widget.totalPrice,
        selectedSize: widget.selectedSize,
        selectedJokbal: widget.selectedJokbal,
        selectedDrink: widget.selectedDrink,
      ),
    ];
  }

  CartItem? _cartItemFor(OrderHistoryItemModel item) {
    final cartItems = widget.cartItems;
    if (cartItems == null) return null;
    for (final cartItem in cartItems) {
      if (cartItem.menuName == item.name &&
          cartItem.quantity == item.quantity &&
          cartItem.unitPrice == item.unitPrice) {
        return cartItem;
      }
    }
    return null;
  }

  String get _displayStoreName {
    final cartItems = widget.cartItems;
    if (widget.storeName != null && widget.storeName!.isNotEmpty) {
      return widget.storeName!;
    }
    if (cartItems != null && cartItems.isNotEmpty) {
      final storeName = cartItems.first.storeName;
      if (storeName != null && storeName.isNotEmpty) return storeName;
    }
    return 'Delivery order';
  }

  String get _displayStoreImage {
    final cartItems = widget.cartItems;
    if (widget.storeImagePath != null && widget.storeImagePath!.isNotEmpty) {
      return widget.storeImagePath!;
    }
    if (cartItems != null && cartItems.isNotEmpty) {
      final storeImage = cartItems.first.storeImagePath;
      if (storeImage != null && storeImage.isNotEmpty) return storeImage;
    }
    return widget.menuImagePath;
  }

  @override
  Widget build(BuildContext context) {
    final buttonLabel = _isPickupOrder ? 'Pick Up Order' : 'Delivery Order';

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMenuCard(),
                    const SizedBox(height: 12),
                    _buildOrderMethodCard(),
                    const SizedBox(height: 12),
                    _buildRequirementCard(),
                    const SizedBox(height: 12),
                    _buildPaymentCard(),
                    const SizedBox(height: 12),
                    _buildCouponCard(),
                    const SizedBox(height: 20),
                    _buildPaymentSummary(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomBar(buttonLabel),
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
              'Order',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildMenuCard() {
    final items = widget.cartItems;
    if (items != null && items.isNotEmpty) {
      return _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((item) => Padding(
                    padding:
                        EdgeInsets.only(bottom: items.last == item ? 0 : 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _OrderImage(
                            imagePath: item.imagePath,
                            width: 64,
                            height: 64,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.menuName,
                                  style: const TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  )),
                              const SizedBox(height: 2),
                              Text(item.optionsSummary, style: _subtitleStyle),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatPrice(item.totalPrice)}  ×${item.quantity}',
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
    }

    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _OrderImage(
              imagePath: widget.menuImagePath,
              width: 64,
              height: 64,
            ),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
                Text(widget.selectedSize, style: _subtitleStyle),
                Text(widget.selectedJokbal, style: _subtitleStyle),
                Text(widget.selectedDrink, style: _subtitleStyle),
                const SizedBox(height: 8),
                Text(
                  _formatPrice(widget.totalPrice),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderMethodCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose your order method',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._orderMethods.asMap().entries.map((entry) {
            final selected = entry.key == _selectedMethod;
            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == _orderMethods.length - 1 ? 0 : 10,
              ),
              child: GestureDetector(
                onTap: () => setState(() => _selectedMethod = entry.key),
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
                        entry.value.title,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.value.subtitle,
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

  Widget _buildRequirementCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Store requirement',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedRequirement,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    size: 20, color: AppColors.textSecondary),
                borderRadius: BorderRadius.circular(12),
                menuMaxHeight: 320,
                selectedItemBuilder: (context) {
                  return _storeRequirements.map((label) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList();
                },
                items: _storeRequirements.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedRequirement = value);
                },
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                dropdownColor: AppColors.bgWhite,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: _selectedRequirement == 0
                ? const SizedBox.shrink()
                : Text(
                    _storeRequirements[_selectedRequirement],
                    key: ValueKey(_selectedRequirement),
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.25,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _noUtensils = !_noUtensils),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _noUtensils
                        ? AppColors.textPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _noUtensils
                          ? AppColors.textPrimary
                          : const Color(0xFFCCCCCC),
                      width: 1.5,
                    ),
                  ),
                  child: _noUtensils
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                const Text(
                  'No utensils needed',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ..._paymentMethods.asMap().entries.map((e) {
            final selected = e.key == _selectedPayment;
            return GestureDetector(
              onTap: () => setState(() => _selectedPayment = e.key),
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
                    Text(
                      e.value,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.w500 : FontWeight.w400,
                        color: AppColors.textPrimary,
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

  Widget _buildCouponCard() {
    final selectedCoupon = _selectedCoupon;
    final couponText = selectedCoupon == null
        ? (_isLoadingCoupons
            ? 'Loading coupons...'
            : _coupons.isEmpty
                ? 'No coupon is available'
                : '${_coupons.length} coupon${_coupons.length == 1 ? '' : 's'} available')
        : '${selectedCoupon.name}  -${_formatPrice(_couponDiscount)}';

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Discount coupon',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _isLoadingCoupons ? null : _showCouponSheet,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      couponText,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        color: selectedCoupon == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontWeight: selectedCoupon == null
                            ? FontWeight.w400
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (selectedCoupon != null) ...[
                    GestureDetector(
                      onTap: () => setState(() => _selectedCoupon = null),
                      child: const Icon(Icons.close,
                          size: 18, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Icon(Icons.chevron_right,
                      size: 20, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          const Row(
            children: [
              Text(
                'Ponits',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Spacer(),
              Text(
                '0',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  void _showCouponSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select coupon',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                if (_coupons.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No coupon is available',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else ...[
                  _CouponSheetRow(
                    title: 'Do not use coupon',
                    subtitle: 'Pay without a discount',
                    selected: _selectedCoupon == null,
                    onTap: () {
                      setState(() => _selectedCoupon = null);
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  ..._coupons.map((coupon) {
                    final discount = coupon.discountAmount
                        .clamp(0, widget.totalPrice)
                        .toInt();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CouponSheetRow(
                        title: coupon.name,
                        subtitle: '-${_formatPrice(discount)}',
                        selected: _selectedCoupon?.id == coupon.id,
                        onTap: () {
                          setState(() => _selectedCoupon = coupon);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentSummary() {
    return _Card(
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
                _formatPrice(widget.totalPrice),
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (_couponDiscount > 0) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Coupon discount',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '-${_formatPrice(_couponDiscount)}',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    color: AppColors.brandOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
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
                _formatPrice(_paymentTotal),
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
    );
  }

  Widget _buildBottomBar(String label) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: AppColors.bgWhite,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: GestureDetector(
          onTap: _isOrdering ? null : _placeOrder,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.brandOrange,
              borderRadius: BorderRadius.circular(28),
            ),
            alignment: Alignment.center,
            child: _isOrdering
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
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
    );
  }

  static const _subtitleStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 13,
    color: AppColors.textSecondary,
    height: 1.4,
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
      ),
      child: child,
    );
  }
}

class _CouponSheetRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _CouponSheetRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.brandOrange : const Color(0xFFDDDDDD),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}

class _OrderImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;

  const _OrderImage({
    required this.imagePath,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
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
        child: const Icon(Icons.restaurant, color: AppColors.textMuted),
      ),
    );
  }
}

class _DeliveryMethod {
  final String title;
  final String subtitle;

  const _DeliveryMethod(this.title, this.subtitle);
}
