import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/cart/presentation/providers/cart_provider.dart';
import 'features/lists/presentation/providers/orders_provider.dart';
import 'features/lists/presentation/providers/store_history_provider.dart';
import 'features/likes/presentation/providers/favorites_provider.dart';
import 'features/my_page/presentation/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => StoreHistoryProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: NaruApp(
        initialRoute: authProvider.isAuthenticated
            ? AppRouter.main
            : AppRouter.onboarding,
      ),
    ),
  );
}
