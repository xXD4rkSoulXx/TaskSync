### **Requisitos Não Funcionais**  
1. **Performance**:  
   - Carregamento rápido de tarefas via Firestore.  
   - Atualizações em tempo real na lista de tarefas.  
2. **Segurança**:  
   - Autenticação segura com Firebase Auth.  
   - Dados de utilizador isolados por `userID` no Firestore.  
3. **Usabilidade**:  
   - Interface intuitiva com botões claros (ex: "+" para adicionar tarefas).  
   - Navegação fluida entre telas.  
4. **Confiabilidade**:  
   - Tratamento básico de erros de rede (ex: exibição de mensagens).  
5. **Compatibilidade**:  
   - Funciona em dispositivos Android e iOS (base Flutter).  
6. **Acessibilidade**:  
   - Contraste de cores em textos/botões (ex: branco sobre gradiente escuro).  
7. **Consistência visual**:  
   - Design uniforme em todas as telas (gradientes, bordas arredondadas).  
8. **Manutenibilidade**:  
   - Código organizado em páginas separadas (login, home, histórico).  
9. **Privacidade**:  
   - Dados do utilizador armazenados apenas com seu `userID`.  
10. **Documentação**:  
    - Nomes claros de variáveis e métodos (ex: `_markTaskAsCompleted`).
11. **Latência**:  
    - Sincronização quase instantânea com Firestore após ações.  
12. **Feedback visual**:  
    - Animações ao marcar/desmarcar tarefas.  
    - Efeitos de hover em botões.  
13. **Resiliência**:  
    - Recuperação de sessão após reinício do app.  
14. **Eficiência**:  
    - Consultas filtradas no Firestore (ex: `where('feito', isEqualTo: false)`).  
15. **Testabilidade**:  
    - Separação lógica entre UI e regras de negócio (ex: métodos `_login`, `_signUp`).  
16. **Escalabilidade**:  
    - Suporte a múltiplos utilizadores com dados isolados no Firestore.  
17. **Conformidade**:  
    - Uso de políticas de password do Firebase (mínimo 6 caracteres).  
18. **Experiência do Utilizador**:  
    - Transições suaves entre telas.  
    - Feedback tátil em interações (ex: botões).  
19. **Desempenho**:  
    - Uso eficiente de recursos (ex: StreamBuilder para atualizações em tempo real).  
20. **Robustez**:  
    - Tratamento de exceções em operações críticas (ex: login, registo).
