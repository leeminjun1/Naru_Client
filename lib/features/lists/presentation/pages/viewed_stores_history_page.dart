import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_asset_image.dart';
import '../../../likes/presentation/pages/store_detail_page.dart';
import '../../data/models/viewed_store_model.dart';
import '../providers/store_history_provider.dart';

class ViewedStoresHistoryPage extends StatefulWidget {
  const ViewedStoresHistoryPage({super.key});

  @override
  State<ViewedStoresHistoryPage> createState() =>
      _ViewedStoresHistoryPageState();
}

class _ViewedStoresHistoryPageState extends State<ViewedStoresHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreHistoryProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreHistoryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.viewedStores.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.viewedStores.isEmpty) {
          return const _HistoryMessage(
            icon: Icons.storefront_outlined,
            title: 'No viewed stores yet',
            subtitle: 'Stores you open will appear here.',
          );
        }

        return RefreshIndicator(
          onRefresh: provider.fetch,
          color: AppColors.brandOrange,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            itemCount: provider.viewedStores.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _ViewedStoreRow(store: provider.viewedStores[index]);
            },
          ),
        );
      },
    );
  }
}

class _ViewedStoreRow extends StatelessWidget {
  final ViewedStoreModel store;

  const _ViewedStoreRow({required this.store});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StoreDetailPage(
            storeId: store.storeId > 0 ? store.storeId : null,
            storeName: store.name,
            storeSubtitle: store.description ?? store.categoryName ?? '',
            heroImagePath: store.displayImage,
            logoImagePath: store.displayImage,
            rating: store.rating == 0 ? '5.0' : store.rating.toStringAsFixed(1),
            reviewCount: '(${store.reviewCount})',
            bottomNavIndex: 3,
          ),
        ),
      ),
      child: Container(
        height: 104,
        padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StoreImage(imageUrl: store.displayImage),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.categoryName ??
                            store.description ??
                            'Recently viewed store',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 15, color: AppColors.brandOrange),
                      const SizedBox(width: 3),
                      Text(
                        store.rating == 0
                            ? 'New'
                            : '${store.rating.toStringAsFixed(1)} (${store.reviewCount})',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        store.formattedViewedAt,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreImage extends StatelessWidget {
  final String? imageUrl;

  const _StoreImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    return Container(
      width: 76,
      height: 76,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF3F5F7),
      ),
      child: url == null || url.isEmpty
          ? const _StoreImageFallback()
          : url.startsWith('assets/')
              ? AppAssetImage(
                  assetPath: url,
                  fit: BoxFit.cover,
                  fallback: const _StoreImageFallback(),
                )
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _StoreImageFallback(),
                ),
    );
  }
}

class _StoreImageFallback extends StatelessWidget {
  const _StoreImageFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.storefront_outlined,
        size: 30,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HistoryMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: AppColors.textMuted),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
