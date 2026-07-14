import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../cart/presentation/pages/cart_list_page.dart';
import '../../../likes/presentation/pages/menu_option_page.dart';

class SearchPage extends StatefulWidget {
  final int initialTabIndex;
  const SearchPage({super.key, this.initialTabIndex = 0});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _hasQuery = false;

  // --- Popular searches ranking animation ---
  static const _popularSearches = [
    'Mawang Jokbal',
    'Malatang',
    'Bossam',
    'Fried Chicken',
    'Korean BBQ',
  ];

  int _currentRankIndex = 0;
  late AnimationController _rankAnimController;
  late Animation<Offset> _slideOutAnim;
  late Animation<Offset> _slideInAnim;
  Timer? _rankTimer;

  static const _deliveryResults = [
    _SearchResultData(
      name: 'Yupki Ddukbokki Sillim',
      tags: ['Tteokbokki', 'Street Food'],
      rating: '4.9',
      reviewCount: '2,002',
      pickUpTime: '20min',
      walkingTime: '5 min',
      label: 'Tteokbokki\n₩12,000',
      imagePath: 'assets/images/food_tteokbokki.png',
      keywords: ['엽떡', '떡볶이', '분식', 'yupki', 'yeopgi'],
    ),
    _SearchResultData(
      name: 'Simin Jokbal Bossam Sillim',
      tags: ['Jokbal', 'Bossam'],
      rating: '5.0',
      reviewCount: '2,002',
      pickUpTime: '40min',
      walkingTime: '8 min',
      label: 'Jokbal\n₩38,000',
      imagePath: 'assets/images/food_jokbal.png',
      keywords: ['족발', '보쌈', '마왕족발', 'simin', 'mawang'],
    ),
    _SearchResultData(
      name: 'Musa Kimchi BBQ',
      tags: ['Korean BBQ', 'Grilled Pork'],
      rating: '4.7',
      reviewCount: '1,846',
      pickUpTime: '25~35min',
      walkingTime: '9 min',
      label: 'BBQ\n₩16,000',
      imagePath: 'assets/images/food_jokbal.png',
      keywords: ['고기', '김치', '삼겹살', 'korean bbq', 'bbq'],
    ),
    _SearchResultData(
      name: 'Rakungfu MALATANG',
      tags: ['MALATANG', 'Self MALATANG'],
      rating: '3.2',
      reviewCount: '132',
      pickUpTime: '15~20min',
      walkingTime: '13 min',
      label: 'MALATANG\n₩10,000',
      imagePath: 'assets/images/food_tteokbokki.png',
      keywords: ['마라탕', '라쿵푸', 'rakungfu', 'mala'],
    ),
    _SearchResultData(
      name: 'Nene Chicken Sillim',
      tags: ['Chicken', 'Wings'],
      rating: '4.8',
      reviewCount: '3,102',
      pickUpTime: '20~30min',
      walkingTime: '10 min',
      label: 'Chicken\n₩18,000',
      imagePath: 'assets/images/food_jokbal.png',
      keywords: ['치킨', '네네치킨', 'fried chicken'],
    ),
    _SearchResultData(
      name: 'Cafe Bombom Sillim',
      tags: ['Coffee', 'Dessert'],
      rating: '5.0',
      reviewCount: '1,245',
      pickUpTime: '10~15min',
      walkingTime: '3 min',
      label: 'Preparing',
      imagePath: 'assets/images/food_cafe.png',
      keywords: ['카페', '커피', '디저트', 'cafe', 'coffee'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _searchController.addListener(() {
      setState(() => _hasQuery = _searchController.text.isNotEmpty);
    });
    _tabController.addListener(_onTabChanged);

    _rankAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideOutAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _rankAnimController,
      curve: Curves.easeIn,
    ));
    _slideInAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _rankAnimController,
      curve: Curves.easeOut,
    ));

    _rankTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _rankAnimController.forward().then((_) {
        setState(() {
          _currentRankIndex = (_currentRankIndex + 1) % _popularSearches.length;
        });
        _rankAnimController.reset();
      });
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _rankAnimController.dispose();
    _rankTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            _buildTabs(),
            Expanded(
              child: _hasQuery
                  ? _buildSearchResults()
                  : (_tabController.index == 1
                      ? const _PickupDefaultContent()
                      : _buildDefaultContent()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_ios_new,
                  size: 18, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F7),
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search store you want to go',
                        hintStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  if (_hasQuery)
                    GestureDetector(
                      onTap: () => _searchController.clear(),
                      child: const Icon(Icons.close,
                          size: 18, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CartListPage(),
              ),
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                size: 22, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.textPrimary,
      unselectedLabelColor: AppColors.inactive,
      indicatorColor: AppColors.textPrimary,
      indicatorWeight: 2,
      labelStyle: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      tabs: const [Tab(text: 'Delivery'), Tab(text: 'Pickup')],
    );
  }

  // ── Default (no query) ─────────────────────────────────────────────────────

  Widget _buildDefaultContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Pickup Searches',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildRankingTicker(),
          const SizedBox(height: 18),
          _buildDiscoverBanner(),
          const SizedBox(height: 28),
          const Text(
            'Recently Popular Stores',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildRecentStores(),
        ],
      ),
    );
  }

  Widget _buildRankingTicker() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          Text(
            '${_currentRankIndex + 1}',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ClipRect(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  SlideTransition(
                    position: _slideOutAnim,
                    child: Text(
                      _popularSearches[_currentRankIndex],
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SlideTransition(
                    position: _slideInAnim,
                    child: Text(
                      _popularSearches[
                          (_currentRankIndex + 1) % _popularSearches.length],
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_drop_up,
              color: AppColors.brandOrange, size: 22),
        ],
      ),
    );
  }

  Widget _buildDiscoverBanner() {
    return Container(
      height: 108,
      decoration: BoxDecoration(
        color: const Color(0xFFA0782A),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 0, 16),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Not sure where to go?',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Discover a new Korea\nthrough friends!',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
            child: Image.asset(
              'assets/images/searchimg.png',
              width: 110,
              height: 108,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentStores() {
    const stores = [
      _StoreCardData(
        name: 'Yupki Ddukbokki',
        rating: '4.9',
        reviewCount: '2,002',
        time: '20min',
        tags: ['pick up', 'new'],
        imagePath: 'assets/images/food_tteokbokki.png',
      ),
      _StoreCardData(
        name: 'Simin Jokbal & Boss',
        rating: '5.0',
        reviewCount: '2,002',
        time: '40min',
        tags: ['pick up', 'new'],
        imagePath: 'assets/images/food_jokbal.png',
      ),
    ];

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stores.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _StoreCard(store: stores[i]),
      ),
    );
  }

  // ── Search results ─────────────────────────────────────────────────────────

  Widget _buildSearchResults() {
    final query = _searchController.text.trim().toLowerCase();
    final source = _tabController.index == 1
        ? _PickupDefaultContent.stores
        : _deliveryResults;
    final results = source.where((item) => item.matches(query)).toList();

    if (results.isNotEmpty) {
      return _SearchResultsContent(
        results: results,
        initialIsPickup: _tabController.index == 1,
      );
    }

    return const Center(
      child: Text(
        'No results found',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ── Pickup default content ────────────────────────────────────────────────────

class _PickupDefaultContent extends StatelessWidget {
  static const _filters = [
    _FilterChip(icon: 'assets/icons/black_clock.svg', label: 'reservation'),
    _FilterChip(icon: 'assets/icons/promo.svg', label: 'promo now'),
    _FilterChip(icon: 'assets/icons/black_star.svg', label: 'Highest Rated'),
  ];

  static const stores = [
    _SearchResultData(
      name: 'Simin Jokbal Bossam Sillim',
      tags: ['Jokbal', 'Bossam'],
      rating: '5.0',
      reviewCount: '2,002',
      pickUpTime: '24~45min',
      walkingTime: '8 min',
      label: 'Jokbal\n₩38,000',
      imagePath: 'assets/images/food_jokbal.png',
      keywords: ['족발', '보쌈', '마왕족발', 'simin', 'mawang'],
    ),
    _SearchResultData(
      name: 'Musa Kimchi BBQ',
      tags: ['Korean BBQ', 'Grilled Pork'],
      rating: '4.7',
      reviewCount: '1,846',
      pickUpTime: '25~35min',
      walkingTime: '9 min',
      label: 'BBQ\n₩16,000',
      imagePath: 'assets/images/food_jokbal.png',
      keywords: ['고기', '김치', '삼겹살', 'korean bbq', 'bbq'],
    ),
    _SearchResultData(
      name: 'Yupki Ddukbokki Sillim',
      tags: ['Tteokbokki', 'Street Food'],
      rating: '4.9',
      reviewCount: '2,002',
      pickUpTime: '15~20min',
      walkingTime: '5 min',
      label: 'Tteokbokki\n₩12,000',
      imagePath: 'assets/images/food_tteokbokki.png',
      keywords: ['엽떡', '떡볶이', '분식', 'yupki', 'yeopgi'],
    ),
    _SearchResultData(
      name: 'Rakungfu MALATANG',
      tags: ['MALATANG', 'Self MALATANG'],
      rating: '3.2',
      reviewCount: '132',
      pickUpTime: '15~20min',
      walkingTime: '13 min',
      label: 'Preparing',
      imagePath: 'assets/images/food_tteokbokki.png',
      keywords: ['마라탕', '라쿵푸', 'rakungfu', 'mala'],
    ),
    _SearchResultData(
      name: 'Cafe Bombom Sillim',
      tags: ['Coffee', 'Dessert'],
      rating: '5.0',
      reviewCount: '1,245',
      pickUpTime: '10~15min',
      walkingTime: '3 min',
      label: 'Preparing',
      imagePath: 'assets/images/food_cafe.png',
      keywords: ['카페', '커피', '디저트', 'cafe', 'coffee'],
    ),
    _SearchResultData(
      name: 'Nene Chicken Sillim',
      tags: ['Chicken', 'Wings'],
      rating: '4.8',
      reviewCount: '3,102',
      pickUpTime: '20~30min',
      walkingTime: '10 min',
      label: 'Chicken\n₩18,000',
      imagePath: 'assets/images/food_jokbal.png',
      keywords: ['치킨', '네네치킨', 'fried chicken'],
    ),
  ];

  const _PickupDefaultContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _FilterChipWidget(chip: _filters[i]),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Recommended',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: stores.length,
            separatorBuilder: (_, __) => const Divider(
              height: 24,
              thickness: 1,
              color: Color(0xFFEEEEEE),
            ),
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MenuOptionPage(
                    rank: 'Top ${i + 1}',
                    storeName: stores[i].name,
                    storeImagePath: stores[i].imagePath,
                    menuName: stores[i].menuName,
                    basePrice: stores[i].basePrice,
                    description: stores[i].tags.join(', '),
                    imagePath: stores[i].imagePath,
                    initialIsPickup: true,
                  ),
                ),
              ),
              behavior: HitTestBehavior.opaque,
              child: _SearchResultRow(item: stores[i]),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Search results ───────────────────────────────────────────────────────────

class _SearchResultsContent extends StatelessWidget {
  final List<_SearchResultData> results;
  final bool initialIsPickup;

  static const _filters = [
    _FilterChip(icon: 'assets/icons/black_clock.svg', label: 'reservation'),
    _FilterChip(icon: 'assets/icons/promo.svg', label: 'promo now'),
    _FilterChip(icon: 'assets/icons/black_star.svg', label: 'Highest Rated'),
  ];

  const _SearchResultsContent({
    required this.results,
    required this.initialIsPickup,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter chips
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _FilterChipWidget(chip: _filters[i]),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Recommended',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MenuOptionPage(
                    rank: 'Top ${i + 1}',
                    storeName: results[i].name,
                    storeImagePath: results[i].imagePath,
                    menuName: results[i].menuName,
                    basePrice: results[i].basePrice,
                    description: results[i].tags.join(', '),
                    imagePath: results[i].imagePath,
                    initialIsPickup: initialIsPickup,
                  ),
                ),
              ),
              behavior: HitTestBehavior.opaque,
              child: _SearchResultRow(item: results[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChipWidget extends StatelessWidget {
  final _FilterChip chip;
  const _FilterChipWidget({required this.chip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD0D0D0), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(chip.icon, width: 14, height: 14),
          const SizedBox(width: 6),
          Text(
            chip.label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  final _SearchResultData item;
  const _SearchResultRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isPreparing = item.label == 'Preparing';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image with label overlay
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                item.imagePath,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black.withValues(alpha: 0.38),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  CurrencyFormatter.krwTextToUsd(item.label),
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: isPreparing ? 13 : 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              // Tags line
              Row(
                children: item.tags.asMap().entries.map((e) {
                  final isOdd = e.key % 2 == 1;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        e.value,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          color: isOdd
                              ? AppColors.textSecondary
                              : AppColors.brandOrange,
                        ),
                      ),
                      if (e.key < item.tags.length - 1)
                        const Text(
                          ', ',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 4),
              // Rating
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/star.svg',
                    width: 14,
                    height: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    item.rating,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    ' (${item.reviewCount})',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'Pick Up  ${item.pickUpTime}',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Walking ${item.walkingTime}',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Store card (default view) ────────────────────────────────────────────────

class _StoreCard extends StatelessWidget {
  final _StoreCardData store;
  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              store.imagePath,
              width: double.infinity,
              height: 130,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/star.svg',
                        width: 13, height: 13),
                    const SizedBox(width: 3),
                    Text(
                      store.rating,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      ' (${store.reviewCount})',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SvgPicture.asset('assets/icons/clock.svg',
                        width: 13, height: 13),
                    const SizedBox(width: 3),
                    Text(
                      store.time,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  children: store.tags.map((t) => _TagChip(label: t)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ── Data classes ─────────────────────────────────────────────────────────────

class _StoreCardData {
  final String name;
  final String rating;
  final String reviewCount;
  final String time;
  final List<String> tags;
  final String imagePath;

  const _StoreCardData({
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.time,
    required this.tags,
    required this.imagePath,
  });
}

class _FilterChip {
  final String icon;
  final String label;
  const _FilterChip({required this.icon, required this.label});
}

class _SearchResultData {
  final String name;
  final List<String> tags;
  final List<String> keywords;
  final String rating;
  final String reviewCount;
  final String pickUpTime;
  final String walkingTime;
  final String label;
  final String imagePath;

  const _SearchResultData({
    required this.name,
    required this.tags,
    required this.rating,
    required this.reviewCount,
    required this.pickUpTime,
    required this.walkingTime,
    required this.label,
    required this.imagePath,
    this.keywords = const [],
  });

  String get menuName {
    final value = label.split('\n').first.trim();
    if (value.isEmpty || value.toLowerCase() == 'preparing') {
      return tags.isEmpty ? 'Popular menu' : tags.first;
    }
    return value;
  }

  int? get basePrice {
    final digits =
        label.split('\n').skip(1).join().replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  bool matches(String query) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return true;

    final haystack = [
      name,
      ...tags,
      ...keywords,
      label,
    ].map(_normalize).join();

    return haystack.contains(normalizedQuery);
  }

  static String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[\s.,&()~+\-/]+'), '');
  }
}
