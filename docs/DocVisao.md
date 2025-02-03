# Documento de Visão - TaskSync 📋✅  

## **Objetivo**  
O TaskSync é um aplicação móvel multiplataforma (Android/iOS) que visa simplificar a **gestão de tarefas pessoais e profissionais**, oferecendo:  
- **Sincronização em tempo real** via Firebase.  
- **Organização intuitiva** por categorias e status (pendente/concluída).  
- **Acesso seguro** com autenticação por e-mail/password.  

---

## **Escopo**  
- **Plataformas**: Disponível para Android e iOS.  
- **Funcionalidades Principais**:  
  - Autenticação de utilizador.  
  - CRUD de tarefas (criar, editar, eliminar, marcar como concluída).  
  - Histórico de tarefas finalizadas.   

---

## **Partes Interessadas (Stakeholders)**  
| **Papel**               | **Interesse**                          |  
|-------------------------|----------------------------------------|  
| Utilizadores Individuais    | Organizar tarefas do dia a dia.        |  
| Profissionais           | Gerenciar metas e prazos profissionais.|  
| Equipa de Desenvolvimento | Garantir funcionalidade e segurança.  |  
| Google (Firebase)       | Fornecer infraestrutura de backend.    |  

---

## **Equipa do Projeto**  
- **[Afonso Carrasquinho.](https://github.com/Afonso295)**: Desenvolvimento Frontend (Flutter).  
- **[Diogo Vieira.](https://github.com/xXD4rkSoulXx)**: Integração Backend (Firebase).

---

## **Características do Produto**  
- **Autenticação Segura**: Registro e login com Firebase Auth.  
- **Gestão de Tarefas**:  
  - Adicionar tarefas com descrição e categoria.  
  - Editar ou eliminar tarefas com confirmação de segurança.  
- **Sincronização em Nuvem**: Dados salvos automaticamente no Firestore.  
- **Histórico de Conclusões**: Visualização de tarefas finalizadas.  
- **UI Responsiva**: Design adaptável para diferentes tamanhos de tela.  

---

## **Restrições do Produto**  
- **Plataformas**: Disponível apenas para **Android e iOS** (versões recentes).  
- **Acesso**: Requer conexão à internet para sincronização inicial.  
- **Segurança**: Dependência do Firebase para autenticação e armazenamento.  

---

## **Arquitetura**  
- **Frontend**: Desenvolvido em **Flutter** (Dart) com componentes reativos.  
- **Backend**:  
  - **Firebase Auth**: Autenticação de usuários.  
  - **Cloud Firestore**: Armazenamento de tarefas em tempo real.
  - **Padrão de Design**: Model-View-ViewModel (MVVM) para separação de camadas.  

