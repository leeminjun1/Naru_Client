import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'login_page.dart';
import 'signup_page.dart';

class AuthSelectionPage extends StatelessWidget {
  const AuthSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // NARU 로고 (회색)
            SvgPicture.asset(
              'assets/images/naru_logo_gray.svg',
              height: 15,
              colorFilter: const ColorFilter.mode(
                Color(0xFFAAAAAA),
                BlendMode.srcIn,
              ),
            ),

            const SizedBox(height: 24),

            // 메인 카피
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.h1.copyWith(height: 1.32),
                children: const [
                  TextSpan(text: 'Find your food\natmosphere here '),
                  TextSpan(
                    text: 'now.',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 음식 이미지
            Image.asset(
              'assets/images/auth_food.png',
              width: 110,
              height: 77,
              fit: BoxFit.contain,
            ),

            const Spacer(flex: 2),

            // Apple / Google 소셜 로그인
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialBtn(
                  image: 'assets/images/social_apple.png',
                  label: 'Apple',
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _SocialBtn(
                  image: 'assets/images/social_google.png',
                  label: 'Google',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Login with E-mail 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
                child: Container(
                  height: 51,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(9000),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Login with E-mail',
                    style: AppTextStyles.body.copyWith(
                      color: const Color(0xFF333333),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Sign up 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupPage()),
                ),
                child: Container(
                  height: 51,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: BorderRadius.circular(9000),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Sign up',
                    style: AppTextStyles.body.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String image;
  final String label;
  final VoidCallback onTap;

  const _SocialBtn({
    required this.image,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(image, width: 56, height: 56),
          const SizedBox(height: 9),
          Text(
            label,
            style: AppTextStyles.body.copyWith(color: const Color(0xFF333333)),
          ),
        ],
      ),
    );
  }
}
