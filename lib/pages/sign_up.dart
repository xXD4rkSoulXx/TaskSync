import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasksync/pages/login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController caixatextoEmail = TextEditingController();
  final TextEditingController caixatextoPassword = TextEditingController();
  final TextEditingController caixatextoRepetirPassword = TextEditingController();
  final FirebaseAuth autenticacao = FirebaseAuth.instance;
  String mensagemErro = '';

  // Função responsável por registar o utilizador
  // --------------------------------------------------------
  Future<void> signUp() async {
    // Verifica se as passwords coincidem para o utilizador ter certeza
    // de que não se enganou
    // -------------
    if (caixatextoEmail.text != caixatextoPassword.text) {
      setState(() {
        mensagemErro = 'As passwords não coincidem.';
      });
      return;
    }
    // ------------

    try {
      // Código de registar utilizador no Firebase
      // ------------
      await autenticacao.createUserWithEmailAndPassword(
        email: caixatextoEmail.text,
        password: caixatextoPassword.text,
      );
      // -----------
      // ShowDialog informativo que o registo foi bem sucedido e redireciona
      // para o login
      // -----------
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text("Registado com sucesso."),
              content: Text("A sua conta foi registada com sucesso."),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Ok'),
                ),
              ],
            );
          },
        );
      }
      // -----------
    } on FirebaseAuthException catch (e) {
      // Faz as validações de registo
      // -----------
      setState(() {
        if (e.code == 'email-already-in-use') {
          mensagemErro = 'O email já existe.';
        }
        else if(e.code == 'invalid-email') {
          mensagemErro = 'O formato do email é inválido.';
        }
        else if(e.code == 'weak-password') {
          mensagemErro = 'Password fraca. Tem que ter pelo menos 6 caractéres.';
        }
        else {
          mensagemErro = 'Ocorreu um erro. Tente novamente mais tarde.';
        }
      });
    }
    // -------------
    // --------------------------------------------------------
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Layout do fundo
        // --------------------------------------------------------
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purpleAccent, Colors.deepPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // --------------------------------------------------------
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Título Registar
            // --------------------------------------------------------
            const Text(
              "Registar",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white
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
            const SizedBox(height: 10),
            // Caixa de texto de Repetir Password
            // --------------------------------------------------------
            TextField(
              controller: caixatextoRepetirPassword,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Repetir Password",
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
            // Botão de Registar
            // --------------------------------------------------------
            ElevatedButton(
              onPressed: signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Registar", style: TextStyle(fontSize: 18)),
            ),
            // --------------------------------------------------------
            const SizedBox(height: 15),
            // Mensagem a perguntar se já tem conta e redirecionar para a página Login
            // --------------------------------------------------------
            TextButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                });
              },
              child: const Text(
                "Já tem uma conta? Faça login.",
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
