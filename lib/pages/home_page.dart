import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'historico.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> categorias = [];
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

  Future<void> _getCategorias() async {
    try {
      final snapshot = await _firestore.collection('Categorias').get();
      setState(() {
        categorias = snapshot.docs.map((doc) => doc['categoria'].toString()).toList();
      });
    } catch(e) {
      print("Erro ao buscar categorias: $e");
    }
  }

  Future<void> _getTasks() async {
    try {
      final snapshot = await _firestore.collection('Tarefas').where('userID', isEqualTo: _currentUser?.uid).where('feito', isEqualTo: false).get();
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
    } catch(e) {
      print("Erro ao buscar as tarefas: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getCategorias();
  }

  void _markTaskAsCompleted(int index) async {
    final String taskID = tarefas[index]['id'];

    await _firestore.collection('Tarefas').doc(taskID).update({'feito': true});
    setState(() {
      tarefas.removeAt(index);
    });
  }

  void _openTaskDialog({int? index}) {
    String taskDescription = index != null ? tarefas[index]['descricao'] : '';
    String? selectedCategorie = index != null ? tarefas[index]['categoria'] : null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            index == null ? 'Adicionar Tarefa' : 'Editar Tarefa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  initialValue: taskDescription,
                  onChanged: (value) => taskDescription = value,
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  value: selectedCategorie,
                  items: categorias.map((String categorie) {
                    return DropdownMenuItem<String>(
                      value: categorie,
                      child: Text(categorie),
                    );
                  }).toList(),
                  onChanged: (value) => selectedCategorie = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (taskDescription.isNotEmpty && selectedCategorie != null) {
                  if (index == null) {
                    final tarefaId = await _firestore.collection('Tarefas').add({
                      'descricao': taskDescription,
                      'categoria': selectedCategorie!,
                      'feito': false,
                      'userID': _currentUser?.uid,
                    });
                    setState(() {
                      tarefas.add({
                        'id': tarefaId.id,
                        'descricao': taskDescription,
                        'categoria': selectedCategorie!,
                        'feito': false,
                        'userID': _currentUser?.uid,
                      });
                    });
                  } else {
                    final tarefaId = tarefas[index]['id'];
                    await _firestore.collection('Tarefas').doc(tarefaId).update({
                      'descricao': taskDescription,
                      'categoria': selectedCategorie!,
                    });
                    setState(() {
                      tarefas[index]['descricao'] = taskDescription;
                      tarefas[index]['categoria'] = selectedCategorie!;
                    });
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Preencha todos os campos!'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Tem certeza de que deseja mesmo eliminar esta tarefa?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String tarefaId = tarefas[index]['id'];

                await _firestore.collection('Tarefas').doc(tarefaId).delete();
                setState(() {
                  tarefas.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
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
        title: Text('TaskSync', style: TextStyle(fontSize: 25, color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, size: 30, color: Colors.white),
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
                      'Nenhuma tarefa criada ainda!',
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
                              onTap: () => _markTaskAsCompleted(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black54, width: 2),
                                ),
                              ),
                            ),
                            title: Text(
                              tarefas[index]['descricao'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            subtitle: Text(
                              tarefas[index]['categoria'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.black45,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blueAccent.withOpacity(0.2),
                                  radius: 22,
                                  child: IconButton(
                                    onPressed: () => _openTaskDialog(index: index),
                                    icon: Icon(Icons.mode_edit_outline_rounded, color: Colors.blueAccent, size: 26),
                                    tooltip: "Editar tarefa",
                                  ),
                                ),
                                SizedBox(width: 10),
                                CircleAvatar(
                                  backgroundColor: Colors.redAccent.withOpacity(0.2),
                                  radius: 22,
                                  child: IconButton(
                                    onPressed: () => _deleteTask(index),
                                    icon: Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 26),
                                    tooltip: "Eliminar tarefa",
                                  ),
                                ),
                              ],
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
                        MaterialPageRoute(builder: (context) => Historico()),
                      );
                    });
                  },
                  icon: const Icon(Icons.history, color: Colors.white, size: 22),
                  label: const Text(
                    'Histórico',
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openTaskDialog,
        backgroundColor: Colors.tealAccent[700],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Adicionar tarefa',
      ),
    );
  }
}
