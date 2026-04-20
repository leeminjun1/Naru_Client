import 'package:flutter/material.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/terms_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/navigation/presentation/pages/navigation_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/lists/presentation/pages/lists_page.dart';
import '../../features/order/presentation/pages/order_flow_page.dart';
import '../../features/likes/presentation/pages/favorites_page.dart';
import '../../features/my_page/presentation/pages/my_page.dart';

class AppRouter {
  static const String onboarding = '/';
  static const String terms = '/terms';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String navigation = '/navigation';
  static const String search = '/search';
  static const String lists = '/lists';
  static const String order = '/order';
  static const String favorites = '/favorites';
  static const String myPage = '/my';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case terms:
        return MaterialPageRoute(builder: (_) => const TermsPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case navigation:
        return MaterialPageRoute(builder: (_) => const NavigationPage());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchPage());
      case lists:
        return MaterialPageRoute(builder: (_) => const ListsPage());
      case order:
        return MaterialPageRoute(builder: (_) => const OrderFlowPage());
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesPage());
      case myPage:
        return MaterialPageRoute(builder: (_) => const MyPage());
      default:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
    }
  }
}
