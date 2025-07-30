import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../models/user_model.dart';

void main() {
  runApp(const NavigationTestApp());
}

class NavigationTestApp extends StatelessWidget {
  const NavigationTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a test user
    final testUser = User(
      id: '1',
      email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      emailVerified: true,
      isGoogleUser: false,
    );

    return MaterialApp(
      title: 'Navigation Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainLayoutController(user: testUser),
      debugShowCheckedModeBanner: false,
    );
  }
}
