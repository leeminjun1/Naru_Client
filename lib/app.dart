import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class NaruApp extends StatelessWidget {
  final String initialRoute;

  const NaruApp({
    super.key,
    this.initialRoute = AppRouter.onboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naru',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
