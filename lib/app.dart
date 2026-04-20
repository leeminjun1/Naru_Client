import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class NaruApp extends StatelessWidget {
  const NaruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naru',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRouter.onboarding,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
