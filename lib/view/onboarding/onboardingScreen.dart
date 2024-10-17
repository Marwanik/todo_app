import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/bloc/onboarding/onboarding_bloc.dart';
import 'package:todoapp/bloc/onboarding/onboarding_event.dart';
import 'package:todoapp/design/widgets/backgroundWidget.dart';
import 'package:todoapp/design/widgets/customButton.dart';
import 'package:todoapp/view/login/login.dart';

class OnboardingScreen extends StatelessWidget {
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
          SizedBox(height: 20),
          Text(
            'Get things done with TODOo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              'Lorem ipsum dolor sit amet, consectetur adipisicing. Maxime, tempore! Animi nemo aut atque, deleniti nihil dolorem repellendus.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 40),
          CustomButton(
            text: 'Get Started',
            onPressed: () {
              context.read<OnboardingBloc>().add(CompleteOnboarding()); // Complete onboarding
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
