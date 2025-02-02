import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'login.dart';

class VerificarLogin extends StatelessWidget {
  const VerificarLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        else if (snapshot.hasData) {
          return MyHomePage();
        }
        else {
          return LoginPage();
        }
      },
    );
  }
}