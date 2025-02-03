import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasksync/pages/sign_up.dart';
import 'package:tasksync/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController caixatextoEmail = TextEditingController();
  final TextEditingController caixatextoPassword = TextEditingController();
  final FirebaseAuth autenticacao = FirebaseAuth.instance;
  String mensagemErro = '';

  // Função responsável pelo login
  // --------------------------------------------------------
  Future<void> login() async {
    try {
      // Código do login com firebase
      // --------
      await autenticacao.signInWithEmailAndPassword(
        email: caixatextoEmail.text,
        password: caixatextoPassword.text,
      );
      // --------
      // Depois que o login foi bem sucedido redireciona para a página principal
      // --------
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      });
      // --------
    } on FirebaseAuthException {
      // Caso o email e a password estejam errados, configura esta mensagem de erro
      // -------
      setState(() {
        mensagemErro = 'Password incorreta.';
      });
      // -------
    }
  }
  // --------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Layout do fundo
        // --------------------------------------------------------
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.blue.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // --------------------------------------------------------
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Título TaskSync
            // --------------------------------------------------------
            const Text(
              "TaskSync",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            // --------------------------------------------------------
            const SizedBox(height: 20),
            // Caixa de texto do Email
            // --------------------------------------------------------
            TextField(
              controller: caixatextoEmail,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Email",
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.email, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withAlpha(51),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
            // --------------------------------------------------------
            const SizedBox(height: 10),
            // Caixa de texto da Password
            // --------------------------------------------------------
            TextField(
              controller: caixatextoPassword,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Password",
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.lock, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withAlpha(51),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
            // --------------------------------------------------------
            const SizedBox(height: 20),
            // Mensagem de erro
            // --------------------------------------------------------
            if (mensagemErro.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withAlpha(230),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mensagemErro,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            // --------------------------------------------------------
            // Botão de login
            // --------------------------------------------------------
            ElevatedButton(
              onPressed: login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Entrar", style: TextStyle(fontSize: 18)),
            ),
            // --------------------------------------------------------
            const SizedBox(height: 15),
            // Mensagem a perguntar se não tem conta e redirecionar para a página Sign Up
            // --------------------------------------------------------
            TextButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                });
              },
              child: const Text(
                "Não tem conta? Registe-se",
                style: TextStyle(color: Colors.white),
              ),
            ),
            // --------------------------------------------------------
          ],
        ),
      ),
    );
  }
}
