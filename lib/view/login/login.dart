import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/bloc/auth/auth_bloc.dart';
import 'package:todoapp/design/color/color.dart';
import 'package:todoapp/design/text/string.dart';
import 'package:todoapp/design/widgets/backgroundWidget.dart';
import 'package:todoapp/design/widgets/customButton.dart';
import 'package:todoapp/design/widgets/customTextField.dart';
import 'package:todoapp/view/home/homeScreen.dart';
import 'package:todoapp/model/authModel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username') ?? '';
    usernameController.text = savedUsername;
  }

  Future<void> _saveLoginData(String username, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('token', token);
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> _clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('token');
    await prefs.setBool('isLoggedIn', false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: Scaffold(
        body: BackgroundWidget(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image
                  Image.asset('assets/images/login/login.png'),

                  Text(
                    Welcome,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: FirstTextColor,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Email text field
                  CustomTextField(
                    hintText: UserName,
                    controller: usernameController,
                  ),

                  const SizedBox(height: 30),


                  CustomTextField(
                    hintText: Password,
                    isPasswordField: true,
                    controller: passwordController,
                  ),

                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                      },
                      child: Text(
                        ForgetPassword,
                        style: TextStyle(color: MainColor),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),


                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is SuccessToLogIn) {
                        _saveLoginData(
                            usernameController.text, 'dummy_token');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(),
                          ),
                        );
                      } else if (state is FailedToLogIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Login failed")),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is Loading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return CustomButton(
                        text: 'Sign In',
                        onPressed: () {
                          final username = usernameController.text.trim();
                          final password = passwordController.text.trim();

                          if (username.isNotEmpty && password.isNotEmpty) {
                            BlocProvider.of<AuthBloc>(context).add(
                              LogIn(
                                user: UserModel(
                                  username: username,
                                  password: password,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(Pleasefillinallfields)),
                            );
                          }
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(DontHaveAccount),
                      GestureDetector(
                        onTap: () {

                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: MainColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
