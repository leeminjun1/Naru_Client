import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({super.key});

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: 3,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => Container(
              color: AppColors.brandOrange,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 134,
                      height: 117,
                      color: AppColors.bgWhite.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'NARU',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 53 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppColors.brandOrange : AppColors.inactive,
                borderRadius: BorderRadius.circular(100),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
