import 'package:flutter/material.dart';
import 'package:todoapp/design/color/color.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;

  const BackgroundWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:BackGround,
      body: SafeArea(
        child: Stack(
          children: [
            // Background image circles
            Positioned(
              top: -70,
              left: -100,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/main/main.png',
                ),
              ),
            ),

        
            // The actual page content
            SafeArea(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
