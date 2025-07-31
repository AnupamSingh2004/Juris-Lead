import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded');
    
    runApp(const JurisLeadApp());
  } catch (e) {
    print('❌ Failed to initialize app: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Configuration Error',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Failed to load environment configuration:\n\n$e\n\nPlease check your .env file.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class JurisLeadApp extends StatelessWidget {
  const JurisLeadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juris-Lead',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const OnboardingScreen(),
    );
  }
}
