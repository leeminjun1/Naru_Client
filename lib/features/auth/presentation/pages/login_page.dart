import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/auth_input_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: IconButton(
                icon: const Icon(Icons.close, size: 20),
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 25, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.loginTitle,
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    Text(AppStrings.loginSubtitle,
                        style: AppTextStyles.h2.copyWith(
                            color: AppColors.textDark)),
                    const SizedBox(height: 40),
                    const AuthInputField(
                      hint: AppStrings.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    const AuthInputField(
                      hint: AppStrings.password,
                      obscureText: true,
                    ),
                    const SizedBox(height: 40),
                    // Login button
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(
                          context, AppRouter.home),
                      child: Container(
                        height: 51,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.dark,
                          borderRadius: BorderRadius.circular(9000),
                        ),
                        alignment: Alignment.center,
                        child: Text(AppStrings.login,
                            style: AppTextStyles.body.copyWith(
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.signup),
                        child: Text('Sign up instead',
                            style: AppTextStyles.body.copyWith(
                                color: AppColors.textMuted,
                                decoration: TextDecoration.underline)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
