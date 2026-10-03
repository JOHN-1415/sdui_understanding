import 'package:flutter/material.dart';
import 'screens/sdui_screen.dart';
import 'services/sdui_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SDUIService().init();
  runApp(const SDUIMobileApp());
}

class SDUIMobileApp extends StatelessWidget {
  const SDUIMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SDUI Dynamic Mobile App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E293B),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SDUIScreenWidget(),
    );
  }
}
