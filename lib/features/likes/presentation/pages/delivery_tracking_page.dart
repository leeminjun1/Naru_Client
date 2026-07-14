import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../lists/presentation/providers/orders_provider.dart';
import 'delivery_completed_page.dart';

class DeliveryTrackingPage extends StatefulWidget {
  final int totalPrice;
  final bool isPickup;
  final int orderId;

  const DeliveryTrackingPage({
    super.key,
    required this.totalPrice,
    required this.isPickup,
    required this.orderId,
  });

  @override
  State<DeliveryTrackingPage> createState() => _DeliveryTrackingPageState();
}

class _DeliveryTrackingPageState extends State<DeliveryTrackingPage> {
  // Delivery: Order Confirmed, Preparing, Out for Delivery, Delivered
  // Pickup: Order Confirmed, Preparing, Ready for Pickup
  int _currentStep = 0;
  Timer? _progressTimer;
  bool _didOpenCompletedPage = false;
  BitmapDescriptor? _deliveryPin;
  BitmapDescriptor? _blueDotPin;
  Set<Marker> _markers = const {};

  static const _deliverySteps = [
    'Order Confirmed',
    'Preparing',
    'Out for Delivery',
    'Delivered',
  ];

  static const _pickupSteps = [
    'Order Confirmed',
    'Preparing',
    'Ready for Pickup',
  ];

  static const _stepDuration = Duration(milliseconds: 700);

  List<String> get _steps => widget.isPickup ? _pickupSteps : _deliverySteps;

  static const CameraPosition _camera = CameraPosition(
    target: LatLng(37.55645, 126.92245),
    zoom: 16.0,
  );

  static const LatLng _storeLocation = LatLng(37.55658, 126.92335);
  static const LatLng _userLocation = LatLng(37.55645, 126.92245);

  String _formatPrice(int price) => CurrencyFormatter.formatKrw(price);

  String get _confirmedTime {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : now.hour;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final m = now.minute.toString().padLeft(2, '0');
    return '$period $h:$m';
  }

  @override
  void initState() {
    super.initState();
    _initMarkers();
    _startProgressTimer();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startProgressTimer() {
    int stepIndex = 0;
    void scheduleNext() {
      if (stepIndex >= _steps.length - 1) return;
      _progressTimer = Timer(_stepDuration, () {
        if (!mounted) return;
        final nextStep = stepIndex + 1;
        setState(() => _currentStep = nextStep);
        stepIndex++;
        if (nextStep == _steps.length - 1) {
          _openCompletedPage();
          return;
        }
        scheduleNext();
      });
    }

    scheduleNext();
  }

  Future<void> _openCompletedPage() async {
    if (_didOpenCompletedPage) return;
    _didOpenCompletedPage = true;
    _progressTimer?.cancel();
    try {
      await context.read<OrdersProvider>().completeOrder(widget.orderId);
    } catch (_) {
      _didOpenCompletedPage = false;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not complete the order.'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _openCompletedPage,
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DeliveryCompletedPage(isPickup: widget.isPickup),
      ),
    );
  }

  Future<void> _initMarkers() async {
    final deliveryPin = await _buildDeliveryPin();
    final blueDot = await _buildBlueDot();
    if (!mounted) return;
    setState(() {
      _deliveryPin = deliveryPin;
      _blueDotPin = blueDot;
      _markers = {
        Marker(
          markerId: const MarkerId('delivery'),
          position: _storeLocation,
          icon: _deliveryPin!,
          anchor: const Offset(0.5, 0.93),
        ),
        Marker(
          markerId: const MarkerId('user'),
          position: _userLocation,
          icon: _blueDotPin!,
          anchor: const Offset(0.5, 0.5),
        ),
      };
    });
  }

  Future<BitmapDescriptor> _buildDeliveryPin() async {
    try {
      const double canvasW = 44;
      const double canvasH = 56;
      const innerRect = Rect.fromLTWH(6, 6, 32, 32);
      final innerRRect =
          RRect.fromRectAndRadius(innerRect, const Radius.circular(10));

      final byteData =
          await rootBundle.load('assets/images/delivery_mascot.png');
      final codec = await ui.instantiateImageCodec(
        byteData.buffer.asUint8List(),
        targetWidth: 56,
        targetHeight: 56,
      );
      final frame = await codec.getNextFrame();
      final sourceImage = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Pin body
      final pinPath = Path()
        ..addRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(2.5, 2.5, 39, 39),
          const Radius.circular(11),
        ))
        ..moveTo(16, 37)
        ..lineTo(28, 37)
        ..lineTo(22, 55)
        ..close();

      canvas.drawPath(pinPath, Paint()..color = AppColors.accentOrange);
      canvas.drawRRect(innerRRect, Paint()..color = const Color(0xFFFFFFFF));

      canvas.save();
      canvas.clipRRect(innerRRect);
      paintImage(
        canvas: canvas,
        rect: innerRect,
        image: sourceImage,
        fit: BoxFit.cover,
      );
      canvas.restore();

      final image = await recorder
          .endRecording()
          .toImage(canvasW.toInt(), canvasH.toInt());
      final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (pngBytes == null) {
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
      }
      return BitmapDescriptor.bytes(pngBytes.buffer.asUint8List());
    } catch (_) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

  Future<BitmapDescriptor> _buildBlueDot() async {
    try {
      const double size = 34;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const center = Offset(size / 2, size / 2);
      canvas.drawCircle(center, 9, Paint()..color = Colors.white);
      canvas.drawCircle(center, 7, Paint()..color = const Color(0xFF46A8FF));
      final image =
          await recorder.endRecording().toImage(size.toInt(), size.toInt());
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      }
      return BitmapDescriptor.bytes(bytes.buffer.asUint8List());
    } catch (_) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Column(
        children: [
          // Google Map — top half
          Expanded(
            flex: 4,
            child: GoogleMap(
              initialCameraPosition: _camera,
              markers: _markers,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
            ),
          ),
          // Bottom sheet
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusHeader(),
                  const SizedBox(height: 20),
                  _buildTimeline(),
                  const SizedBox(height: 28),
                  Text(
                    widget.isPickup ? 'Pickup Details' : 'Delivery Details',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentSummary(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isPickup
                    ? "We're preparing your pickup"
                    : "We're confirming your order",
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isPickup
                    ? 'Your order will be ready for pickup soon.'
                    : 'You can cancel your order\nuntil it has been confirmed.',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: const Color(0xFFCCCCCC), width: 1),
                  ),
                  child: const Text(
                    'Order Cancel',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Image.asset(
          'assets/images/delivery_wait.png',
          width: 90,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: List.generate(_steps.length, (i) {
        final isCompleted = i <= _currentStep;
        final isCurrent = i == _currentStep;
        final isLast = i == _steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dot + line column
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.brandOrange
                          : const Color(0xFFCCCCCC),
                      border: isCurrent
                          ? Border.all(
                              color:
                                  AppColors.brandOrange.withValues(alpha: 0.3),
                              width: 3)
                          : null,
                    ),
                    child: isCompleted && !isCurrent
                        ? const Icon(Icons.check, size: 8, color: Colors.white)
                        : null,
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 28,
                      color: i < _currentStep
                          ? AppColors.brandOrange
                          : const Color(0xFFDDDDDD),
                      margin: const EdgeInsets.symmetric(vertical: 2),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _steps[i],
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.w400,
                        color: isCompleted
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (i == 0)
                      Text(
                        _confirmedTime,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
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
                _formatPrice(widget.totalPrice),
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
        ],
      ),
    );
  }
}
