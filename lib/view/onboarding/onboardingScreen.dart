import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/bloc/onboarding/onboarding_bloc.dart';
import 'package:todoapp/bloc/onboarding/onboarding_event.dart';
import 'package:todoapp/design/color/color.dart';
import 'package:todoapp/design/text/string.dart';
import 'package:todoapp/design/widgets/backgroundWidget.dart';
import 'package:todoapp/design/widgets/customButton.dart';
import 'package:todoapp/view/login/login.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Image.asset(
              'assets/images/onboarding/onboarding.png',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            GetthingsdonewithTODOo,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: FirstTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: SecondTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          CustomButton(
            text: GetStarted,
            onPressed: () {
              context
                  .read<OnboardingBloc>()
                  .add(CompleteOnboarding()); // Complete onboarding
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
