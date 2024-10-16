import 'package:flutter/material.dart';
import 'package:todoapp/design/widgets/backgroundWidget.dart';
import 'package:todoapp/design/widgets/customButton.dart';
import 'package:todoapp/design/widgets/customTextField.dart';
import 'package:todoapp/view/home/homeScreen.dart';
class AddTodoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top illustration or image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Image.asset(
                  'assets/images/addtodo/addtodo.png',
                ),
              ),

              SizedBox(height: 30),

              // Instructional text
              Text(
                'Add what you want to do later on...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xF055847A),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 50),

              // Input fields for the to-do list items using CustomTextField
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    CustomTextField(controller:TextEditingController(),
                      hintText: 'Task 1',
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      hintText: 'Task 2', controller:TextEditingController(),
                    ),
                    SizedBox(height: 20),
                    CustomTextField(controller:TextEditingController(),
                      hintText: 'Task 3',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Add to list button
              CustomButton(
                text: 'Add to List',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
