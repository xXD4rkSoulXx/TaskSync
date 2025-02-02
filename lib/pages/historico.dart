import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'home_page.dart';

class Historico extends StatefulWidget {
  const Historico({super.key});

  @override
  State<Historico> createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  final List<Map<String, dynamic>> tarefas = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  void _getCurrentUser() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        setState(() {
          _currentUser = _auth.currentUser;
        });
        _getTasks();
      }
    });
  }

  Future<void> _getTasks() async {
    try {
      final snapshot = await _firestore.collection('Tarefas').where('userID', isEqualTo: _currentUser?.uid).where('feito', isEqualTo: true).get();
      setState(() {
        tarefas.clear();
        for (var docs in snapshot.docs) {
          tarefas.add({
            'id': docs.id,
            'descricao': docs['descricao'],
            'categoria': docs['categoria'],
            'feito': docs['feito'],
            'userID': docs['userID'],
          });
        }
      });
    } catch (e) {
      print("Erro ao buscar as tarefas: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _undoneTaskAsCompleted(int index) async {
    final String taskID = tarefas[index]['id'];
    await _firestore.collection('Tarefas').doc(taskID).update({'feito': false});
    setState(() {
      tarefas.removeAt(index);
    });
  }

  Future<void> _logout() async {
    await _auth.signOut();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.tealAccent[700],
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, size: 30, color: Colors.white70),
            tooltip: 'Terminar sessão',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: tarefas.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma tarefa concluída ainda!',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tarefas.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.white.withOpacity(0.9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(15),
                            leading: GestureDetector(
                              onTap: () => _undoneTaskAsCompleted(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 18),
                              ),
                            ),
                            title: Text(
                              tarefas[index]['descricao'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.black54,
                              ),
                            ),
                            subtitle: Text(
                              tarefas[index]['categoria'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ),
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
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}