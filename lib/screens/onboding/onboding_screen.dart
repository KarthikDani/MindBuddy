import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rive_animation/main.dart';

import 'components/animated_btn.dart';
import 'components/sign_in_dialog.dart';

void main() {
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
      home: const OnbodingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OnbodingScreen extends StatefulWidget {
  const OnbodingScreen({super.key});

  @override
  State<OnbodingScreen> createState() => _OnbodingScreenState();
}

class _OnbodingScreenState extends State<OnbodingScreen> {
  late RiveAnimationController _btnAnimationController;

  bool isShowSignInDialog = false;

  @override
  void initState() {
    _btnAnimationController = OneShotAnimation(
      "active",
      autoplay: false,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background Images and Rive Animation (Position them as needed)
            Positioned.fill(
              child: Image.asset(
                "assets/Backgrounds/Spline.png",
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: const SizedBox(),
              ),
            ),
            const RiveAnimation.asset(
              "assets/RiveAssets/shapes.riv",
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: const SizedBox(),
              ),
            ),

            // Align the BigBuddyLogo.png at the top center of the screen
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Image.asset(
                  "assets/BigBuddyLogo.png",
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.20,
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        children: [
                          Text(
                            "MindBuddy",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.1,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins",
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 2),
                    const Center(
                      child: Text(
                        "BigBuddy AI is here to help you as your MindBuddy. \nLet the brainstorming journey begin!",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: AnimatedBtn(
                          btnAnimationController: _btnAnimationController,
                          press: () {
                            _btnAnimationController.isActive = true;

                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                setState(() {
                                  isShowSignInDialog = true;
                                });
                                showCustomDialog(context, onValue: (_) {
                                  setState(() {
                                    isShowSignInDialog = false;
                                  });
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
