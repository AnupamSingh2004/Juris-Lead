import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import '../widgets/main_layout.dart';
import '../models/user_model.dart';

class NavigationDemo extends StatelessWidget {
  const NavigationDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a demo user for testing
    final demoUser = User(
      id: '1',
      email: 'demo@example.com',
      firstName: 'Demo',
      lastName: 'User',
      emailVerified: true,
      isGoogleUser: false,
    );

    return MaterialApp(
      title: 'AarogyaRekha Navigation Demo',
      navigatorKey: NavigationService.navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainLayoutController(user: demoUser),
      debugShowCheckedModeBanner: false,
    );
  }
}
