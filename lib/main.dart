import 'package:flutter/material.dart';
import 'package:webapp/main_layout_screen.dart';

void main() {
  runApp(const AuraWorkspaceApp());
}

class AuraWorkspaceApp extends StatelessWidget {
  const AuraWorkspaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura Workspace',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        cardColor: const Color(0xFF151D30),
        primaryColor: const Color(0xFF6366F1),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFFEC4899),
          surface: Color(0xFF151D30),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Inter', fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
          titleLarge: TextStyle(fontFamily: 'Inter', fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
          titleMedium: TextStyle(fontFamily: 'Inter', fontSize: 16.0, fontWeight: FontWeight.w600, color: Colors.white),
          bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 15.0, color: Color(0xFF9CA3AF)),
          bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 13.0, color: Color(0xFFD1D5DB)),
        ),
        useMaterial3: true,
      ),
      home: const MainLayoutScreen(),
    );
  }
}
