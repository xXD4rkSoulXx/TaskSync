import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasksync/pages/login.dart';
import 'package:tasksync/pages/home_page.dart';

class Historico extends StatefulWidget {
  const Historico({super.key});

  @override
  State<Historico> createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  final List<Map<String, dynamic>> tarefas = [];
  final FirebaseAuth autenticacao = FirebaseAuth.instance;
  final FirebaseFirestore dadosFirebase = FirebaseFirestore.instance;
  User? utilizador;

  // Função para obter os dados do utilizador logado
  // --------------------------------------------------------
  void getUtilizador() {
    autenticacao.authStateChanges().listen((user) {
      if (user != null) {
        setState(() {
          utilizador = autenticacao.currentUser;
        });
        getTarefas();
      }
    });
  }
  // --------------------------------------------------------

  // Função para obter as tarefas do utilizador
  // --------------------------------------------------------
  Future<void> getTarefas() async {
    try {
      final dados = await dadosFirebase.collection('Tarefas').where('userID', isEqualTo: utilizador?.uid).where('feito', isEqualTo: true).get();
      setState(() {
        tarefas.clear();
        for (var documentos in dados.docs) {
          tarefas.add({
            'id': documentos.id,
            'descricao': documentos['descricao'],
            'categoria': documentos['categoria'],
            'feito': documentos['feito'],
            'userID': documentos['userID'],
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar tarefas. Tente novamente mais tarde.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
  // --------------------------------------------------------

  // Sempre que a página atualiza, setState, executa sempre estas funções antes de tudo
  // --------------------------------------------------------
  @override
  void initState() {
    super.initState();
    getUtilizador();
  }
  // --------------------------------------------------------

  // Função que desfaz a tarefa concluida
  // --------------------------------------------------------
  void desfazerTarefaConcluida(int index) async {
    await dadosFirebase.collection('Tarefas').doc(tarefas[index]['id']).update({'feito': false});
    setState(() {
      tarefas.removeAt(index);
    });
  }
  // --------------------------------------------------------

  // Função que termina sessão
  // --------------------------------------------------------
  Future<void> logout() async {
    await autenticacao.signOut();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }
  // --------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Layout da parte de cima da página
      // --------------------------------------------------------
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.tealAccent[700],
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout, size: 30, color: Colors.white70),
            tooltip: 'Terminar sessão',
          ),
        ],
      ),
      // --------------------------------------------------------
      body: Container(
        // Fundo da página, transição das cores
        // --------------------------------------------------------
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // --------------------------------------------------------
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                // Verifica se tem tarefas concluídas ou não
                child: tarefas.isEmpty
                  // Quando não tem tarefas concluidas, aparece mensagem a informar que não tem
                  // tarefas concluidas
                  // -----
                  ? const Center(
                      child: Text(
                        'Nenhuma tarefa concluída ainda!',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    )
                  // -----
                  // Quando tem tarefas concluidas, faz aparecer a lista de todas as tarefas concluidas
                  // -----
                  : ListView.builder(
                      itemCount: tarefas.length,
                      itemBuilder: (context, index) {
                        // Layout de cada tarefa
                        // --------------------
                        return Card(
                          // Layout do cartão
                          // ---
                          color: Colors.white.withAlpha(230),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          // ---
                          child: ListTile(
                            // Botão circular verde para desfazer tarefa como concluída
                            // ------
                            contentPadding: const EdgeInsets.all(15),
                            leading: GestureDetector(
                              onTap: () => desfazerTarefaConcluida(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(76),
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 18),
                              ),
                            ),
                            // ------
                            // Descrição da tarefa
                            // ------
                            title: Text(
                              tarefas[index]['descricao'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.black54,
                              ),
                            ),
                            // ------
                            // Categoria da tarefa
                            // ------
                            subtitle: Text(
                              tarefas[index]['categoria'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.black45,
                              ),
                            ),
                            // ------
                          ),
                        );
                        // --------------------
                      },
                    ),
                  // ------
              ),
              // Botão Voltar
              // --------------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                      );
                    });
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                  label: const Text(
                    'Voltar',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.tealAccent[700],
                    foregroundColor: Colors.white,
                    elevation: 5,
                  ),
                ),
              ),
              // --------------------------------------------------------
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
