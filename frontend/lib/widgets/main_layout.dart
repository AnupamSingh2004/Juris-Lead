
import 'package:flutter/material.dart';
import '../widgets/dynamic_bottom_nav.dart';
import '../models/user_model.dart';
import '../widgets/main_navigation.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  final User? user;

  const MainLayout({
    Key? key,
    required this.child,
    required this.currentRoute,
    this.user,
  }) : super(key: key); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: DynamicBottomNavBar(
        currentRoute: currentRoute,
      ),
      extendBody: false,
    );
  }
}

class MainLayoutController extends StatelessWidget {
  final User? user;

  const MainLayoutController({
    Key? key,
    this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Redirect to main navigation with default user type
    return const MainNavigation(userType: 'Rural');
  }
}