# Student Assistant Application System

## 📌 Overview
This is a Flutter mobile application developed for managing Student Assistant applications in the IT Department.

The system allows students to apply for assistant positions and enables admin users to review, approve, or reject applications.

---

## 🚀 Features

### 👨‍🎓 Student
- Login using Supabase Authentication
- Submit Student Assistant application
- View application status
- Edit application (while pending)
- Delete application

### 👨‍💼 Admin
- View all applications
- Approve or reject applications
- Update application status
- Delete invalid applications

---

## 🏗️ Architecture
The application follows the **MVVM (Model-View-ViewModel)** architecture:

- **Model** → Handles data and business logic  
- **ViewModel** → Manages state and connects UI to Model  
- **View** → UI components (Flutter screens)  

State management is implemented using **Provider**.

---

## 🧠 Technologies Used
- Flutter
- Dart
- Provider (State Management)
- Supabase (Authentication & Database)
- GitHub (Version Control)

---

## 🔄 CRUD Operations

| Operation | Description |
|----------|------------|
| Create   | Submit new application |
| Read     | View applications |
| Update   | Edit application (if pending) |
| Delete   | Remove application |

---

## 🔐 Authentication
- Implemented using Supabase Authentication
- Role-based access:
  - Student
  - Admin

---

📊 Contribution

Each member contributed to:

UI development
ViewModel logic
Supabase integration
Testing and debugging

📌 Notes
-Only one application per student is allowed
-Maximum of two modules per application
-Admin approval is required for final status

🏁 Conclusion

This system improves the management of Student Assistant applications by providing a structured, secure, and user-friendly platform.
