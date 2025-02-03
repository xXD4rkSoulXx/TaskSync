import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasksync/pages/home_page.dart';
import 'package:tasksync/pages/login.dart';

class VerificarLogin extends StatelessWidget {
  const VerificarLogin({super.key});

  @override
  Widget build(BuildContext context) {
    // Verifica se o utilizador está logado ou não, se estiver manda para a página principal
    // se não, manda para a página de Login
    // --------------------------------------------------------
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
    // --------------------------------------------------------
  }
}
