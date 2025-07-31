import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'screens/authentication_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
    print('Environment loaded successfully');
  } catch (e) {
    print('Warning: Could not load .env file: $e');
    print('Continuing with default configuration...');
  }
  
  runApp(const JurisLeadApp());
}

class JurisLeadApp extends StatelessWidget {
  const JurisLeadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juris-Lead',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthenticationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
