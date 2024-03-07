import 'package:admin_app/views/user_provider.dart';
import 'package:admin_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:admin_app/routes/app_routes.dart';
import 'package:admin_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController =
      TextEditingController(text: 'admin@gmail.com');
  TextEditingController passwordController =
      TextEditingController(text: 'admin');

  Future<Map<String, dynamic>> login(
      String? email, String? password, BuildContext context) async {
    if (email == null || password == null) {
      print('Email or password is null');
      return {'error': 'Invalid email or password'};
    }

    try {
      Provider.of<UserProvider>(context, listen: false).setLoading(true);

      final response = await http.post(
        Uri.parse(
            'https://lpg-api-06n8.onrender.com/api/v1/users/authenticate/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          '__t': 'Admin',
        }),
      );

      Provider.of<UserProvider>(context, listen: false).setLoading(false);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          final List<dynamic>? userData = data['data'];
          if (userData != null && userData.isNotEmpty) {
            String userId = userData[0]['_id'] ?? '';
            print('User ID: $userId');

            // Set the user ID in the app state
            Provider.of<UserProvider>(context, listen: false).setUserId(userId);

            return data;
          } else {
            return {'error': 'User data is missing or empty'};
          }
        } else {
          return {'error': 'Login failed'};
        }
      } else {
        return {'error': 'Login failed'};
      }
    } catch (error, stackTrace) {
      Provider.of<UserProvider>(context, listen: false).setLoading(false);

      print('Error: $error');
      print('Stack trace: $stackTrace');
      return {'error': 'An error occurred during login'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 60.0),
                    Image.network(
                      "https://res.cloudinary.com/dzcjbziwt/image/upload/v1708533697/images/hefwwla0ozppgz5itlkt.png",
                      width: 550.0,
                      height: null,
                    ),
                    const SizedBox(height: 50.0),
                    LoginTextField(
                      controller: emailController,
                      labelText: "Email Address",
                      hintText: "Enter your Email Address",
                    ),
                    LoginTextField(
                      controller: passwordController,
                      obscureText: true,
                      labelText: "Password",
                      hintText: "Enter your Password",
                    ),
                    const SizedBox(height: 30.0),
                    Column(
                      children: [
                        LoginButton(
                          onPressed: () async {
                            final loginResult = await login(
                              emailController.text,
                              passwordController.text,
                              context,
                            );

                            if (loginResult.containsKey('error')) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Center(
                                      child: Text(
                                        'Login Failed',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    content: Text(loginResult['error']),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'OK',
                                          style: TextStyle(
                                            color: Color(0xFF050404),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              Navigator.pushNamed(context, dashboardRoute);
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          if (Provider.of<UserProvider>(context).isLoading)
            Center(
              child: LoadingAnimationWidget.flickr(
                leftDotColor: const Color(0xFF050404).withOpacity(0.8),
                rightDotColor: const Color(0xFFd41111).withOpacity(0.8),
                size: 40,
              ),
            ),
        ],
      ),
    );
  }
}
