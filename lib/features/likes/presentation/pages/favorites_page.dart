import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_asset_image.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../cart/presentation/pages/cart_list_page.dart';
import '../../../home/presentation/pages/search_page.dart' as home_search;
import '../providers/favorites_provider.dart';
import '../../data/models/favorite_store_model.dart';
import 'store_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Row(
                children: [
                  const Text(
                    'Likes',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.08,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const home_search.SearchPage(),
                      ),
                    ),
                    icon: const Icon(
                      Icons.search,
                      size: 24,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CartListPage(),
                      ),
                    ),
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 24,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<FavoritesProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final stores = provider.favorites;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total ${stores.length} Shop',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...stores.map(
                          (store) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _FavoriteStoreCard(
                              store: store,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _LikesPromoBanner(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NaruBottomNavBar(currentIndex: 2),
    );
  }
}

class _FavoriteStoreCard extends StatelessWidget {
  final FavoriteStoreModel store;

  const _FavoriteStoreCard({
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StoreDetailPage(
            storeId: store.storeId,
            syncFavoriteRemote: store.syncRemote,
            storeName: store.name,
            storeSubtitle: store.categoryName ?? '',
            heroImagePath: store.imageUrl ?? 'assets/images/food_jokbal.png',
            logoImagePath: store.imageUrl ?? 'assets/images/food_jokbal.png',
            rating: store.rating.toStringAsFixed(1),
            reviewCount: '(${store.reviewCount})',
          ),
        ),
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE4E6E8), width: 1),
              ),
              child: store.imageUrl != null
                  ? _favoriteStoreImage(store.imageUrl!)
                  : const Icon(Icons.store, color: AppColors.textMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
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
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '★ ${store.rating.toStringAsFixed(1)}  ·  ${store.reviewCount} reviews',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.read<FavoritesProvider>().remove(
                    store.storeId,
                    syncRemote: store.syncRemote,
                  ),
              tooltip: 'Remove from Likes',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              icon: const Icon(
                Icons.favorite,
                color: AppColors.accentOrange,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _favoriteStoreImage(String imagePath) {
  if (imagePath.startsWith('assets/')) {
    return AppAssetImage(assetPath: imagePath, fit: BoxFit.cover);
  }
  return Image.network(
    imagePath,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) =>
        const Icon(Icons.store, color: AppColors.textMuted),
  );
}

class _LikesPromoBanner extends StatelessWidget {
  const _LikesPromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
      decoration: BoxDecoration(
        color: const Color(0xFFCC6E55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFAE5D48), width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery with NARU',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Check your food easily\non the map',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 114,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                'assets/images/checkmap.png',
                width: 210,
                height: 194,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
