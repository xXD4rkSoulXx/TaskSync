### **Requisitos Funcionais**  
1. **Registo de utilizador** com email e password (via Firebase Auth).  
2. **Login/autenticação** com email e password.  
3. **Logout** da conta.  
4. **Criação de tarefas** com descrição e categoria (armazenadas no Firestore).  
5. **Edição de tarefas** (descrição e categoria).  
6. **Eliminação de tarefas** com confirmação via diálogo.  
7. **Marcar tarefas como concluídas** (atualização do campo `feito` para `true`).  
8. **Exibição do histórico de tarefas concluídas**.  
9. **Desfazer conclusão de tarefas** (marcar como "não concluída" no histórico).  
10. **Listagem dinâmica de tarefas pendentes** (filtradas por `feito: false`).  
11. **Navegação entre telas**: Login → Registo, Home → Histórico.  
12. **Validação de formulários**:  
    - Email válido no login/registo.  
    - Password com pelo menos 6 caracteres.  
    - Confirmação de password igual ao campo original.  
13. **Exibição de erros específicos**:  
    - "Password incorreta" (login).  
    - "Email já em uso" (registo).  
    - "Password fraca" (registo).  
14. **Persistência de dados** via Firestore (tarefas vinculadas ao `userID`).  
15. **Recuperação automática do estado de autenticação** (redireciona para Home se já logado).  
16. **Exibição de feedback visual**:  
    - Ícone de check animado ao marcar tarefas.  
    - Snackbar para erros de formulário.  
17. **Gestão de sessão**:  
    - Encerramento da sessão via logout.  
    - Redirecionamento para login após logout.  
18. **Associação de tarefas a categorias** (lista fixa de categorias do Firestore).  
19. **Diálogos de confirmação** para ações críticas (eliminar tarefas).  
20. **Exibição de mensagens de sucesso** após registo bem-sucedido.
