import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../widgets/delivery_pickup_tab.dart';

class HomeDeliveryPage extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const HomeDeliveryPage({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  State<HomeDeliveryPage> createState() => _HomeDeliveryPageState();
}

class _HomeDeliveryPageState extends State<HomeDeliveryPage> {
  final _pageController = PageController();
  int _bannerPage = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final next = (_bannerPage + 1) % 3;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          color: AppColors.accentOrange,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            Text('Sillim-dong···', style: AppTextStyles.title),
                            const SizedBox(width: 4),
                            Transform.rotate(
                              angle: math.pi / 2,
                              child: SvgPicture.asset(
                                'assets/images/ic_right_small.svg',
                                width: 8,
                                height: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SvgPicture.asset(
                        'assets/images/ic_search_header.svg',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 6),
                      SvgPicture.asset(
                        'assets/images/ic_cart.svg',
                        width: 24,
                        height: 24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(39),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 0, 16, 0),
                    child: Row(
                      children: [
                        Text(
                          'Search name of food',
                          style: AppTextStyles.body
                              .copyWith(color: const Color(0xFF7B7B7B)),
                        ),
                        const Spacer(),
                        SvgPicture.asset(
                          'assets/images/ic_search_bar.svg',
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 144,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _bannerPage = i),
                    itemCount: 3,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: _BannerCard(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color:
                            _bannerPage == i ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeliveryPickupTab(
                selectedIndex: widget.selectedIndex,
                onChanged: widget.onTabChanged,
              ),
              const SizedBox(height: 16),
              // Category grid
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _CategoryGrid(),
              ),
              const SizedBox(height: 16),
              Container(height: 10, color: AppColors.bgLight),
              // Recently Ordered Stores
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _SectionHeader(
                  title: 'Recently Ordered Stores',
                  subtitle: 'You can order Again',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    _StoreCard(
                      imagePath: 'assets/images/food_tteokbokki.png',
                      name: 'Yupki Ddukbokki Sillim',
                      rating: '4.9',
                      time: '20min',
                      tags: ['pick up', 'new'],
                    ),
                    SizedBox(width: 14),
                    _StoreCard(
                      imagePath: 'assets/images/food_jokbal.png',
                      name: 'Simin Jokbal & Bossam',
                      rating: '5.0',
                      time: '40min',
                      tags: ['pick up', 'new'],
                    ),
                    SizedBox(width: 14),
                    _StoreCard(
                      imagePath: 'assets/images/food_jokbal.png',
                      name: 'Simin Jokbal & Bossam',
                      rating: '5.0',
                      time: '40min',
                      tags: ['pick up', 'new'],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(height: 10, color: AppColors.bgLight),
              // Stores with Free Delivery
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _SectionHeader(
                  title: 'Stores with Free Delivery',
                  subtitle: 'Order now for ₩0 delivery',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 276,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    _FreeDeliveryCard(),
                    SizedBox(width: 14),
                    _FreeDeliveryCard(),
                    SizedBox(width: 14),
                    _FreeDeliveryCard(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(height: 10, color: AppColors.bgLight),
              // Popular Franchises
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x21FB461F), Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: _SectionHeader(
                        title: 'Popular Franchises',
                        subtitle: 'Discover flavors you can trust',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 165,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: const [
                          _FranchiseCard(
                            category: 'Burger Chains',
                            name: 'Lotteria',
                            bgImage: 'assets/images/franchise_lotteria_bg.png',
                            logoImage:
                                'assets/images/franchise_lotteria_logo.png',
                          ),
                          SizedBox(width: 6),
                          _FranchiseCard(
                            category: 'Chicken Chains',
                            name: 'Nene Chicken',
                            bgImage: 'assets/images/franchise_nene_bg.png',
                            logoImage: 'assets/images/franchise_nene_logo.png',
                          ),
                          SizedBox(width: 6),
                          _FranchiseCard(
                            category: 'Pizza Chains',
                            name: 'Domino',
                            bgImage: 'assets/images/franchise_domino_bg.png',
                            logoImage:
                                'assets/images/franchise_domino_logo.png',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Container(height: 10, color: AppColors.bgLight),
              // Cafés Near You
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _SectionHeader(
                  title: 'Cafés Near You',
                  subtitle: 'Grab a refreshing drink on your way home',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    _CafeCard(
                      name: 'Cafe Bombom Sillim',
                      imagePath: 'assets/images/food_cafe.png',
                    ),
                    SizedBox(width: 14),
                    _CafeCard(
                      name: 'Bback Dabang sillim',
                      imagePath: 'assets/images/food_jokbal.png',
                    ),
                    SizedBox(width: 14),
                    _CafeCard(
                      name: 'Bback Dabang sillim',
                      imagePath: 'assets/images/food_jokbal.png',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Bottom promo banner
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: _PromoBanner(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 144,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 3,
            child: Image.asset(
              'assets/images/banner_food.png',
              width: 225,
              height: 138,
              fit: BoxFit.contain,
            ),
          ),
          const Positioned(
            left: 24,
            top: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bold, Spicy, and Full of Flavor',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Seoul Bangyidong\nJjukkumi House',
                  style: AppTextStyles.title,
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            top: 95,
            child: Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(61),
              ),
              alignment: Alignment.center,
              child: const Text(
                'View More',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  static const _columns = 5;
  static const _columnGap = 6.0;
  static const _rowGap = 14.0;
  static const _items = [
    _CategoryData(label: 'Korean', imagePath: 'assets/images/cat_korean.png'),
    _CategoryData(
        label: 'Chicken', imagePath: 'assets/images/cat_chicken_single.png'),
    _CategoryData(label: 'Street', imagePath: 'assets/images/cat_street.png'),
    _CategoryData(label: 'BBQ', imagePath: 'assets/images/cat_chicken.png'),
    _CategoryData(label: 'Asian', imagePath: 'assets/images/cat_asian.png'),
    _CategoryData(label: 'Desserts', imagePath: 'assets/images/cat_korean.png'),
    _CategoryData(label: 'Coffee', imagePath: 'assets/images/cat_coffee.png'),
    _CategoryData(
        label: 'Fast Food', imagePath: 'assets/images/cat_fastfood.png'),
    _CategoryData(label: 'Healthy', imagePath: 'assets/images/cat_healthy.png'),
    _CategoryData(
        label: 'Late Night', imagePath: 'assets/images/cat_healthy.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rawItemWidth =
            (constraints.maxWidth - (_columnGap * (_columns - 1))) / _columns;
        final itemWidth = rawItemWidth > 0 ? rawItemWidth : 0.0;
        return Wrap(
          spacing: _columnGap,
          runSpacing: _rowGap,
          children: _items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: _CategoryItem(
                      label: item.label, imagePath: item.imagePath),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _CategoryData {
  final String label;
  final String imagePath;
  const _CategoryData({required this.label, required this.imagePath});
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final String imagePath;
  const _CategoryItem({required this.label, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primary),
            ),
            clipBehavior: Clip.hardEdge,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        const SizedBox(height: 6),
        Text(subtitle,
            style: AppTextStyles.body.copyWith(color: const Color(0xFF7B7B7B))),
      ],
    );
  }
}

class _StoreCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String rating;
  final String time;
  final List<String> tags;

  const _StoreCard({
    required this.imagePath,
    required this.name,
    required this.rating,
    required this.time,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 222,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(imagePath,
                width: 198, height: 129, fit: BoxFit.cover),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 198,
            child: Text(name,
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 198,
            height: 20,
            child: _RatingRow(rating: rating, time: time),
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: 198,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: tags.map((tag) => _TagChip(label: tag)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeDeliveryCard extends StatelessWidget {
  const _FreeDeliveryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 222,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/food_jokbal.png',
                  width: 198,
                  height: 129,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                child: SizedBox(
                  height: 22,
                  width: 198,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          height: 22,
                          color: AppColors.brandOrange,
                          padding: const EdgeInsets.only(left: 10),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'No fee for delivery',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SvgPicture.asset('assets/images/ic_tag_arrow.svg',
                          height: 22, width: 22),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 198,
            child: const Text('Simin Jokbal & Bossam',
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 198,
            height: 20,
            child: const _RatingRow(rating: '5.0', time: '40min'),
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: 198,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0x61D9654C),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFD9654C)),
                    ),
                    child: const Text('free delivery',
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 4),
                const _TagChip(label: 'eco-friendly'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 198,
            child: const Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                _TagChip(label: 'pick up'),
                _TagChip(label: 'reservation'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FranchiseCard extends StatelessWidget {
  final String category;
  final String name;
  final String bgImage;
  final String logoImage;

  const _FranchiseCard({
    required this.category,
    required this.name,
    required this.bgImage,
    required this.logoImage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 152,
      height: 165,
      child: Stack(
        children: [
          Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: Stack(
                  children: [
                    Image.asset(bgImage,
                        width: 152, height: 77, fit: BoxFit.cover),
                    Container(
                        width: 152, height: 77, color: const Color(0x33000000)),
                  ],
                ),
              ),
              Container(
                width: 152,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  border: Border.all(color: AppColors.borderDark),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 18,
            left: 10,
            right: 10,
            child: SizedBox(
              width: 132,
              child: Column(
                children: [
                  Container(
                    width: 49,
                    height: 49,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE4E4E4)),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.asset(logoImage, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 8),
                  Text(category,
                      style: AppTextStyles.caption
                          .copyWith(color: const Color(0xFF7A7B7D)),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(name,
                      style: AppTextStyles.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CafeCard extends StatelessWidget {
  final String name;
  final String imagePath;
  const _CafeCard({required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 222,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(imagePath,
                width: 198, height: 129, fit: BoxFit.cover),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 198,
            child: Text(name,
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 198,
            height: 20,
            child: const _RatingRow(rating: '5.0', time: '40min'),
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: 198,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(21),
              ),
              child: const Text(
                'available for pick up',
                style: AppTextStyles.caption,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderDark),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SvgPicture.asset(
              'assets/images/banner_overlay.svg',
              width: double.infinity,
              height: 115,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            left: 24,
            top: 19,
            right: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bringing Korea's speed to you",
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Discover the benefit\nof ₩0 delivery',
                  style: AppTextStyles.h2,
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            top: 21,
            child: Image.asset(
              'assets/images/delivery_mascot.png',
              width: 76,
              height: 75,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final String rating;
  final String time;
  const _RatingRow({required this.rating, required this.time});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 198,
      height: 20,
      child: Row(
        children: [
          SvgPicture.asset('assets/images/ic_star.svg', width: 14, height: 14),
          const SizedBox(width: 1),
          Text(rating,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
          Text(' (2,002)',
              style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
          const SizedBox(width: 7),
          SvgPicture.asset('assets/images/ic_time.svg', width: 16, height: 16),
          const SizedBox(width: 2),
          Expanded(
            child: Text(time,
                style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF333333),
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Text(label,
          style:
              AppTextStyles.caption.copyWith(color: const Color(0xFF787E81))),
    );
  }
}
