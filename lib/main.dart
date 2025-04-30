import 'package:flutter/material.dart';
import 'package:quizzing/screens/login_screen.dart';
import 'package:quizzing/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  // Flutter's binding is initialized before executing any asynchronous code
  WidgetsFlutterBinding.ensureInitialized();
  // Use 'await' to ensure Firebase initializes before the app starts
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MaterialApp(title: "Quizzing", home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // True if Firebase has finished initializing
  bool _firebaseReady = false;
  @override
  void initState() {
    super.initState();
    // Initializes Firebase asynchronously
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((value) => setState(() => _firebaseReady = true));
  }

  @override
  Widget build(BuildContext context) {
    // Shows a circle loading indicator while Firebase is initializing
    if (!_firebaseReady) {
      return const Center(child: CircularProgressIndicator());
    }
    // Retrieves the currently authenticated user
    User? user = FirebaseAuth.instance.currentUser;
    // Directs the user to the home_screen if they are logged in, otherwise to the login_screen.
    if (user != null) return const HomeScreen();
    return const LoginScreen();
  }
}
