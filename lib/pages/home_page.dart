import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> categorias = [];
  final List<Map<String, dynamic>> tarefas = [];
  bool exibirHistorico = false;
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
      final snapshot = await _firestore.collection('Tarefas').where('userID', isEqualTo: _currentUser?.uid).get();
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

  void _openTaskDialog({int? index}) {
    String taskDescription = index != null ? tarefas[index]['descricao'] : '';
    String? selectedCategorie = index != null ? tarefas[index]['categoria'] : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(index == null ? 'Adicionar Tarefa' : 'Editar Tarefa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  taskDescription = value;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                value: selectedCategorie,
                items: categorias.map((String categorie) {
                  return DropdownMenuItem<String>(
                    value: categorie,
                    child: Text(categorie),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategorie = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (taskDescription.isNotEmpty && selectedCategorie != null) {
                  if (index == null) {
                    final id_tarefa=await _firestore.collection('Tarefas').add({
                      'descricao': taskDescription,
                      'categoria': selectedCategorie!,
                      'feito': false,
                      'userID': _currentUser?.uid,
                    });
                    setState(() {
                      tarefas.add({
                        'id': id_tarefa.id,
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
                    SnackBar(content: Text('Preencha todos os campos!')),
                  );
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _markTaskAsCompleted(int index) async {
    final String taskID = tarefas[index]['id'];

    await _firestore.collection('Tarefas').doc(taskID).update({'feito': true});

    setState(() {
      tarefas[index]['feito'] = true;
    });
  }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar'),
          content: Text('Tem certeza de que deseja mesmo eliminar esta tarefa?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String taskID = tarefas[index]['id'];

                await _firestore.collection('Tarefas').doc(taskID).delete();

                setState(() {
                  tarefas.removeAt(index);
                });
                Navigator.of(context).pop();
              },
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
    final tarefasFiltradas = exibirHistorico
      ? tarefas.where((task) => task['feito']).toList()
      : tarefas.where((task) => !task['feito']).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("TaskSync"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: tarefas.isEmpty
                ? Text('')
                : ListView.builder(
                  itemCount: tarefasFiltradas.length,
                  itemBuilder: (context, index) {
                    final task = tarefasFiltradas[index];
                    return ListTile(
                      title: Text(task['descricao']),
                      subtitle: Text(task['categoria']),
                      trailing: exibirHistorico
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _markTaskAsCompleted(index),
                                  icon: Icon(Icons.check, color: Colors.green),
                                ),
                                IconButton(
                                  onPressed: () => _openTaskDialog(index: index),
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                ),
                                IconButton(
                                  onPressed: () => _deleteTask(index),
                                  icon: Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                        ),
                    );
                  },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    exibirHistorico = !exibirHistorico;
                  });
                },
                icon: Icon(exibirHistorico ? Icons.arrow_back : Icons.history),
                label: Text(exibirHistorico ? 'Voltar' : 'Histórico'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openTaskDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
