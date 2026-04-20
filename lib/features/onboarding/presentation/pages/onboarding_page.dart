import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/router/app_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  static const _colors = [
    Color(0xFFE95322),
    Color(0xFFF9B621),
    Color(0xFF354D91),
  ];

  int _current = 0;
  late AnimationController _animController;
  late Animation<Color?> _colorAnim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _colorAnim = ColorTween(
      begin: _colors[0],
      end: _colors[1],
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));

    _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      _advance();
    });
  }

  void _advance() {
    final next = _current + 1;

    if (next >= _colors.length) {
      _timer?.cancel();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.terms);
      }
      return;
    }

    _colorAnim = ColorTween(
      begin: _colors[_current],
      end: _colors[next],
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));

    _animController.forward(from: 0).then((_) {
      if (mounted) setState(() => _current = next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final bg = _colorAnim.value ?? _colors[_current];
        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Column(
              children: [
                const Spacer(),
                // 브릿지 로고
                Image.asset(
                  'assets/images/naru_bridge.png',
                  width: 134,
                  height: 117,
                ),
                const SizedBox(height: 10),
                // NARU 텍스트
                SvgPicture.asset(
                  'assets/images/naru_text.svg',
                  width: 106,
                  height: 30,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const Spacer(),
                // 페이지 인디케이터
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_colors.length, (i) {
                    final active = i == _current;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 53 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withValues(alpha: active ? 1.0 : 0.45),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
