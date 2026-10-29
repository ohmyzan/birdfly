import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const BirdFlyApp());
}

class BirdFlyApp extends StatelessWidget {
  const BirdFlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BirdFly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}
