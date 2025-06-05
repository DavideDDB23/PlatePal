import 'package:flutter/material.dart';
import 'package:plate_pal/screens/home_screen.dart';
import 'package:plate_pal/utils/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlatePal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, // You can create a MaterialColor from AppColors.proteinColor
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'SFProDisplay', // Set the default font family
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.primaryText),
          titleTextStyle: TextStyle(
            color: AppColors.primaryText,
            fontFamily: 'SFProDisplay', // Ensure AppBar also uses it
            fontSize: 20, // Default, can be overridden
            fontWeight: FontWeight.w600, // Semibold for titles is common
          ),
        ),
        textTheme: const TextTheme(
          // Define specific text styles if needed, they will inherit SFProDisplay
          displayLarge: TextStyle(fontFamily: 'SFProDisplay', color: AppColors.primaryText),
          displayMedium: TextStyle(fontFamily: 'SFProDisplay', color: AppColors.primaryText),
          displaySmall: TextStyle(fontFamily: 'SFProDisplay', color: AppColors.primaryText),
          headlineLarge: TextStyle(fontFamily: 'SFProDisplay', color: AppColors.primaryText),
          headlineMedium: TextStyle(fontFamily: 'SFProDisplay', color: AppColors.primaryText),
          headlineSmall: TextStyle(fontFamily: 'SFProDisplay', color: AppColors.primaryText),
          titleLarge: TextStyle(fontFamily: 'SFProDisplay', color: AppColors.primaryText, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontFamily: 'SFProDisplay', color: AppColors.secondaryText),
          titleSmall: TextStyle(fontFamily: 'SFProDisplay', color: AppColors.secondaryText),
          bodyLarge: TextStyle(fontFamily: 'SFProDisplay', color: AppColors.primaryText),
          bodyMedium: TextStyle(fontFamily: 'SFProDisplay', color: AppColors.secondaryText), // Default text
          bodySmall: TextStyle(fontFamily: 'SFProDisplay', color: AppColors.secondaryText),
          labelLarge: TextStyle(fontFamily: 'SFProDisplay', color: AppColors.primaryText, fontWeight: FontWeight.w500), // For buttons
          labelMedium: TextStyle(fontFamily: 'SFProDisplay', color: AppColors.primaryText),
          labelSmall: TextStyle(fontFamily: 'SFProDisplay', color: AppColors.primaryText),
        ).apply(
          bodyColor: AppColors.primaryText,
          displayColor: AppColors.primaryText,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}