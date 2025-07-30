import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static BuildContext? get currentContext => navigatorKey.currentContext;
  
  static void navigateTo(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }
  
  static void navigateAndReplace(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushReplacementNamed(routeName, arguments: arguments);
  }
  
  static void navigateAndClearStack(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName, 
      (route) => false,
      arguments: arguments,
    );
  }
  
  static void goBack() {
    if (navigatorKey.currentState?.canPop() == true) {
      navigatorKey.currentState?.pop();
    }
  }
}

class AppRoutes {
  static const String home = '/home';
  static const String scan = '/scan';
  static const String stores = '/stores';
  static const String schemes = '/schemes';
  static const String chatbot = '/chatbot';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String register = '/register';
  static const String authWrapper = '/';
  
  // Additional routes (removed from main nav)
  static const String search = '/search';
  static const String schedule = '/schedule';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String appointments = '/appointments';
  static const String doctors = '/doctors';
  static const String health = '/health';
}

class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;
  final Color? activeColor;

  const BottomNavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.activeIcon,
    this.activeColor,
  });
}

class NavigationConfig {
  static const List<BottomNavItem> mainNavItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      route: AppRoutes.home,
      activeColor: Color(0xFF2563EB), // Medical blue
    ),
    BottomNavItem(
      icon: Icons.camera_alt_outlined,
      activeIcon: Icons.camera_alt_rounded,
      label: 'Scan',
      route: AppRoutes.scan,
      activeColor: Color(0xFF10B981), // Medical green
    ),
    BottomNavItem(
      icon: Icons.store_outlined,
      activeIcon: Icons.store_rounded,
      label: 'Stores',
      route: AppRoutes.stores,
      activeColor: Color(0xFF8B5CF6), // Purple
    ),
    BottomNavItem(
      icon: Icons.health_and_safety_outlined,
      activeIcon: Icons.health_and_safety_rounded,
      label: 'Schemes',
      route: AppRoutes.schemes,
      activeColor: Color(0xFFF59E0B), // Orange
    ),
    BottomNavItem(
      icon: Icons.smart_toy_outlined,
      activeIcon: Icons.smart_toy_rounded,
      label: 'Chatbot',
      route: AppRoutes.chatbot,
      activeColor: Color(0xFF06B6D4), // Cyan
    ),
    BottomNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      route: AppRoutes.profile,
      activeColor: Color(0xFF6366F1), // Indigo
    ),
  ];
  
  // Routes where bottom navigation should NOT appear
  static const List<String> excludedRoutes = [
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.authWrapper,
  ];
  
  static bool shouldShowBottomNav(String currentRoute) {
    return !excludedRoutes.contains(currentRoute);
  }
}
