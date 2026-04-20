import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text('MY Naru', style: AppTextStyles.h3),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  children: [
                    // Profile
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 83,
                            height: 83,
                            decoration: BoxDecoration(
                              color: AppColors.profileBg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primary, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD03C)
                                      .withValues(alpha: 0.32),
                                  blurRadius: 27.9,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.person_outline,
                                size: 40, color: AppColors.primary),
                          ),
                          const SizedBox(height: 8),
                          Text('Baegopa', style: AppTextStyles.h3),
                          const SizedBox(height: 4),
                          Text('d2434@e-mirim.hs.kr',
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.textGray)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Address card
                    _InfoCard(
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Seoul Bangyidong Parkdream',
                                    style: AppTextStyles.title),
                                const SizedBox(height: 4),
                                Text('2102 - 39gil', style: AppTextStyles.body),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Coupon & Point card
                    _InfoCard(
                      child: Column(
                        children: [
                          _InfoRow(label: 'Coupon Box', value: '0'),
                          const Divider(color: AppColors.border),
                          _InfoRow(label: 'Point', value: '0'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Exchanged amount card (with fold effect)
                    Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 16,
                          right: 16,
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.border.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        _InfoCard(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Exchanged amount',
                                  style: AppTextStyles.title),
                              Row(
                                children: [
                                  Text('₩123,000', style: AppTextStyles.h2),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right, size: 20),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Total orders
                    _InfoCard(
                      child: _InfoRow(
                        label: 'Total Orders',
                        value: '2',
                        showArrow: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Liked stores
                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            label: 'Stores you liked',
                            value: '2',
                            showArrow: true,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _StoreThumb(label: 'Kyochon Chicken···'),
                              const SizedBox(width: 8),
                              _StoreThumb(label: 'Yupki Ddukbokki···'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Promo banner
                    Container(
                      constraints: const BoxConstraints(minHeight: 94),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF140806)),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Get on the promo',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption
                                      .copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Order Right Now and',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.title
                                      .copyWith(color: Colors.white),
                                ),
                                Text(
                                  'Get 20% Off',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.title
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NaruBottomNavBar(currentIndex: 4),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showArrow;

  const _InfoRow({
    required this.label,
    required this.value,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.title),
        Row(
          children: [
            Text(value, style: AppTextStyles.title),
            if (showArrow) const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ],
    );
  }
}

class _StoreThumb extends StatelessWidget {
  final String label;
  const _StoreThumb({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
