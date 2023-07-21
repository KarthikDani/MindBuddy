import 'package:flutter/material.dart';
import 'package:rive_animation/screens/Dashboard/dashboard.dart';
import 'package:rive_animation/screens/onboding/onboding_screen.dart';
import 'package:rive_animation/screens/onboding/components/api_service.dart';

bool isUserAlreadyExists = true;
void main() {
  isUserAlreadyExists = ApiService().checkExistingUser() as bool;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindBuddy',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEEF1F8),
        primarySwatch: Colors.blue,
        fontFamily: "Intel",
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          errorStyle: TextStyle(height: 0),
          border: defaultInputBorder,
          enabledBorder: defaultInputBorder,
          focusedBorder: defaultInputBorder,
          errorBorder: defaultInputBorder,
        ),
      ),
      // home: isUserAlreadyExists
      //     ? const DashboardScreen()
      //     : const OnbodingScreen(),
      home: isUserAlreadyExists
          ? const DashboardScreen()
          : const OnbodingScreen(),
      debugShowCheckedModeBanner: true,
    );
  }
}

const defaultInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(16)),
  borderSide: BorderSide(
    color: Color(0xFFDEE3F2),
    width: 1,
  ),
);
