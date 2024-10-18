import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:todoapp/design/widgets/backgroundWidget.dart';
import 'package:todoapp/view/home/homeScreen.dart';
import 'package:todoapp/view/login/login.dart';
import 'package:todoapp/view/onboarding/onboardingScreen.dart';

import '../../design/color/color.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleScaleUpAnimation;
  late Animation<double> _circleScaleDownAnimation;
  late Animation<double> _logoFadeInAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _circleScaleUpAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _circleScaleDownAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeIn),
      ),
    );

    _logoFadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), _navigateAfterSplash);
  }

  Future<void> _navigateAfterSplash() async {
    final prefs = await SharedPreferences.getInstance();

    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else {
      _checkLoginStatus();
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _circleScaleUpAnimation,
              builder: (context, child) {
                double scaleValue = _circleScaleUpAnimation.value;
                if (_circleScaleDownAnimation.value < 1) {
                  scaleValue = _circleScaleDownAnimation.value;
                }
                return Transform.scale(
                  scale: scaleValue,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: MainColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
            // Logo fade-in animation
            AnimatedBuilder(
              animation: _logoFadeInAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoFadeInAnimation.value,
                  child: Image.asset(
                    'assets/images/splash/logo.png',
                    width: 200,
                    height: 200,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
