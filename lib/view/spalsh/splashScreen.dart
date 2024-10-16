import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/bloc/splash/splash_bloc.dart';
import 'package:todoapp/bloc/splash/splash_state.dart';
import 'package:todoapp/core/bloc/app_manger_bloc.dart';
import 'dart:async';
import 'package:todoapp/design/widgets/backgroundWidget.dart';
import 'package:todoapp/view/home/homeScreen.dart';
import 'package:todoapp/view/login/login.dart';
import 'package:todoapp/view/onboarding/onboardingScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleScaleUpAnimation;
  late Animation<double> _circleScaleDownAnimation;
  late Animation<double> _logoFadeInAnimation;
  late Animation<double> _textFadeInAnimation;

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
        curve: Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _circleScaleDownAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 0.6, curve: Curves.easeIn),
      ),
    );


    _logoFadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.6, 0.8, curve: Curves.easeIn),
      ),
    );


    _textFadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      context.read<AppManagerBloc>().add(HeLoggedIn());
    } else {
      context.read<AppManagerBloc>().add(LogOut());
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

      child: Scaffold(
        body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
      if (state is SplashCompleted) {
        final appManagerState = context.read<AppManagerBloc>().state;
        if (mounted) {
          if (appManagerState is NavigateToHomePage) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
            );
          }
        }
      }
    },
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Circle scale up and down animation
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
                        color:  Color(0xF055847A),
                      shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),


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
      ),
      )
    );
  }
}
