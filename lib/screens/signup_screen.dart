import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizzing/screens/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? _email; // Stores the user's email input
  String? _password; // Stores the user's password input
  String? _repeatPassword; // Stores the user's repeat password input
  String? _error; // Stores any signup error
  final _formKey =
      GlobalKey<FormState>(); // Key to track the form's validation state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Quizzing",
              style: TextStyle(color: Colors.deepOrangeAccent))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey, // Associates the form with the form key for validation
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(hintText: 'Enter your email'),
                maxLength: 64,
                onChanged: (value) =>
                    _email = value, // Updates the email variable on user input
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null; // Returning null means "no issues"
                },
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Enter a password'),
                obscureText: true,
                onChanged: (value) => _password =
                    value, // Updates the password variable on user input
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Your password must contain at least 8 characters.';
                  }
                  return null; // Returning null means "no issues"
                },
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Repeat password'),
                obscureText: true,
                onChanged: (value) => _repeatPassword = value,
                validator: (value) {
                  if (value != _password) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text('Sign Up'),
                onPressed: () {
                  // Checks if the form input is valid before attempting signup
                  if (_formKey.currentState!.validate()) {
                    trySignUp(); // Calls function to create user
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text("Back to Login"),
                onPressed: () {
                  Navigator.pop(context); // goes back to login screen
                },
              ),
              if (_error != null)
                Text(
                  "Error: $_error",
                  style: TextStyle(color: Colors.red[800], fontSize: 12),
                )
            ],
          ),
        ),
      ),
    );
  }

  void trySignUp() async {
    if (_password != _repeatPassword) {
      setState(() {
        _error = 'Passwords do not match.';
      });
      return;
    }

    try {
      // The await keyword blocks execution to wait for
      // signInWithEmailAndPassword to complete its asynchronous execution and
      // return a result.
      //
      // FirebaseAuth with raise an exception if the email or password
      // are determined to be invalid, e.g., the email doesn't exist.
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email!, password: _password!);
      _error = null; // clear the error message if exists.
      setState(() {}); // Trigger a rebuild

      // We need this next check to use the Navigator in an async method.
      // It basically makes sure LoginScreen is still visible.
      if (!mounted) return;

      // Navigate to HomeScreen
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      // Exceptions are raised if the Firebase Auth service
      // encounters an error. We need to display these to the user.
      if (e.code == 'email-already-in-use') {
        _error = 'The email address is already in use.';
      } else {
        _error = 'An error occurred: ${e.message}';
      }

      // Call setState to redraw the widget, which will display
      // the updated error text.
      setState(() {});
    }
  }
}
