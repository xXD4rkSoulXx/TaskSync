import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasksync/pages/login.dart';
import 'package:tasksync/pages/historico.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> categorias = [];
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


  // Função para obter as categorias pré definidas
  // --------------------------------------------------------
  Future<void> getCategorias() async {
    try {
      final dados = await dadosFirebase.collection('Categorias').get();
      setState(() {
        categorias = dados.docs.map((doc) => doc['categoria'].toString()).toList();
      });
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erro ao carregar categorias. Tente novamente mais tarde.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
  // --------------------------------------------------------

  // Função para obter as tarefas do utilizador
  // --------------------------------------------------------
  Future<void> getTarefas() async {
    try {
      final dados = await dadosFirebase.collection('Tarefas').where('userID', isEqualTo: utilizador?.uid).where('feito', isEqualTo: false).get();
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
    } catch(e) {
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
    getCategorias();
  }
  // --------------------------------------------------------

  // Função que marca a tarefa como concluída
  // --------------------------------------------------------
  void setTarefaConcluida(int index) async {
    await dadosFirebase.collection('Tarefas').doc(tarefas[index]['id']).update({'feito': true});
    setState(() {
      tarefas.removeAt(index);
    });
  }
  // --------------------------------------------------------

  // Esta função vai Adicionar ou Editar tarefa consoante o botão clicado
  // Ela possui um parâmetro opcional index, se ao chamar a função função e preencher
  // o index, significa que a tarefa está em alguma posição já definida, logo é para editar
  // porque apenas as tarefas já listadas têm index. Agora se não tiver index, significa que
  // ainda não está listado, o que indica que é adicionar tarefa pois é uma tarefa nova com index
  // --------------------------------------------------------
  void adicionarEditarTarefa({int? index}) {
    String descricao = index != null ? tarefas[index]['descricao'] : '';
    String? categoria = index != null ? tarefas[index]['categoria'] : null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // Layout do showDialog
          // -----------------
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            index == null ? 'Adicionar Tarefa' : 'Editar Tarefa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // -----------------
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Caixa de Texto da categoria
                // --------
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  initialValue: descricao,
                  onChanged: (value) => descricao = value,
                ),
                // --------
                SizedBox(height: 12),
                // Caixa de Seleção de Categorias
                // --------
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  value: categoria,
                  items: categorias.map((String categorie) {
                    return DropdownMenuItem<String>(
                      value: categorie,
                      child: Text(categorie),
                    );
                  }).toList(),
                  onChanged: (value) => categoria = value,
                ),
                // ---------
              ],
            ),
          ),
          actions: [
            // Botão cancelar
            // ---------
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              child: Text('Cancelar'),
            ),
            // ---------
            // Botão Salvar
            // ----------------------------
            ElevatedButton(
              onPressed: () async {
                // Verifica se todos os campos estão preenchidos, para não deixar
                // o utlizador meter tarefas vazias
                if (descricao.isNotEmpty && categoria != null) {
                  if (index == null) {
                    // Adicionar Tarefa
                    // -----------
                    final idTarefa = await dadosFirebase.collection('Tarefas').add({
                      'descricao': descricao,
                      'categoria': categoria!,
                      'feito': false,
                      'userID': utilizador?.uid,
                    });
                    setState(() {
                      tarefas.add({
                        'id': idTarefa.id,
                        'descricao': descricao,
                        'categoria': categoria!,
                        'feito': false,
                        'userID': utilizador?.uid,
                      });
                    });
                    // ------------
                  } else {
                    // Editar Tarefa
                    // --------
                    await dadosFirebase.collection('Tarefas').doc(tarefas[index]['id']).update({
                      'descricao': descricao,
                      'categoria': categoria!,
                    });
                    setState(() {
                      tarefas[index]['descricao'] = descricao;
                      tarefas[index]['categoria'] = categoria!;
                    });
                    // ---------
                  }
                  Navigator.of(context).pop();
                } else {
                  // Mensagem que aparece em baixo para preencher todos os campos
                  // -------------
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Preencha todos os campos!'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  // -------------
                }
              },
              // Layout do botão Salvar
              // -----------------
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              // -----------------
              child: Text('Salvar'),
            ),
            // ------------------------
          ],
        );
      },
    );
  }
  // --------------------------------------------------------

  // Função que elimina a tarefa
  // --------------------------------------------------------
  void eliminarTarefa(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // Layout do showDialog
          // -----------------
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Tem certeza de que deseja mesmo eliminar esta tarefa?'),
          // -----------------
          actions: [
            // Botão cancelar
            // ---------
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              child: Text('Cancelar'),
            ),
            // ---------
            // Botão Eliminar
            // ---------
            ElevatedButton(
              // Eliminar Tarefa
              // ----------
              onPressed: () async {
                await dadosFirebase.collection('Tarefas').doc(tarefas[index]['id']).delete();
                setState(() {
                  tarefas.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              // -----------
              // Layout do botão Eliminar
              // ------------
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Eliminar'),
              // -------------
            ),
            // ---------
          ],
        );
      },
    );
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
        title: Text('TaskSync', style: TextStyle(fontSize: 25, color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout, size: 30, color: Colors.white),
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
                // Verifica se tem tarefas ou não
                child: tarefas.isEmpty
                  // Quando não tem tarefas, aparece mensagem a informar que não tem
                  // tarefas criadas
                  // -----
                  ? const Center(
                    child: Text(
                      'Nenhuma tarefa criada ainda!',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  )
                  // -----
                  // Quando tem tarefas, faz aparecer a lista de todas as tarefas
                  // -----
                  : ListView.builder(
                      itemCount: tarefas.length,
                      itemBuilder: (context, index) {
                        // Layout de cada tarefa
                        // --------------------
                        return Card(
                          // Layout do cardão
                          // ---
                          color: Colors.white.withAlpha(239),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          // ---
                          child: ListTile(
                            // Botão circular de marcar concluída a tarefa
                            // ------
                            contentPadding: const EdgeInsets.all(15),
                            leading: GestureDetector(
                              onTap: () => setTarefaConcluida(index),
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
                            // ------
                            // Descrição da tarefa
                            // ------
                            title: Text(
                              tarefas[index]['descricao'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
                                color: Colors.black45,
                              ),
                            ),
                            // ------
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Ícone de Editar Tarefa
                                // ------
                                CircleAvatar(
                                  backgroundColor: Colors.blueAccent.withAlpha(51),
                                  radius: 22,
                                  child: IconButton(
                                    onPressed: () => adicionarEditarTarefa(index: index),
                                    icon: Icon(Icons.mode_edit_outline_rounded, color: Colors.blueAccent, size: 26),
                                    tooltip: "Editar tarefa",
                                  ),
                                ),
                                // ------
                                SizedBox(width: 10),
                                // Ícone de Eliminar Tarefa
                                // ------
                                CircleAvatar(
                                  backgroundColor: Colors.redAccent.withAlpha(51),
                                  radius: 22,
                                  child: IconButton(
                                    onPressed: () => eliminarTarefa(index),
                                    icon: Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 26),
                                    tooltip: "Eliminar tarefa",
                                  ),
                                ),
                                // ------
                              ],
                            ),
                          ),
                        );
                        // --------------------
                      },
                    ),
                  // ------
              ),
              // Botão Histórico
              // --------------------------------------------------------
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
              // --------------------------------------------------------
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // Botão adicionar tarefa
      // --------------------------------------------------------
      floatingActionButton: FloatingActionButton(
        onPressed: adicionarEditarTarefa,
        backgroundColor: Colors.tealAccent[700],
        foregroundColor: Colors.white,
        tooltip: 'Adicionar tarefa',
        child: const Icon(Icons.add),
      ),
      // --------------------------------------------------------
    );
  }
}
