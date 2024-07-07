import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 20.0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 20.0,
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String email = emailController.text;
                final String password = passwordController.text;

                User? user =
                    await AuthService().signInWithEmail(email, password);
                if (user != null) {
                  print('Successfully logged in as ${user.email}');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                } else {
                  print('Login failed');
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                minimumSize: const Size(250, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
              ),
              child: const Text('Log In'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                User? user = await AuthService().signInWithGoogle();
                if (user != null) {
                  print('Successfully logged in with Google as ${user.email}');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                } else {
                  print('Google login failed');
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                minimumSize: const Size(250, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
              ),
              child: const Text('Log In with Google'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                User? user = await AuthService().signInWithFacebook();
                if (user != null) {
                  print(
                      'Successfully logged in with Facebook as ${user.email}');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                } else {
                  print('Facebook login failed');
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(250, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
              ),
              child: const Text('Log In with Facebook'),
            ),
          ],
        ),
      ),
    );
  }
}
