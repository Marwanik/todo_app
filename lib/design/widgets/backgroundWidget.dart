import 'package:flutter/material.dart';
import 'package:todoapp/design/color/color.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;

  const BackgroundWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Stack(
          children: [

            Positioned(
              top: -70,
              left: -100,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/main/main.png',
                ),
              ),
            ),

        

            SafeArea(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
