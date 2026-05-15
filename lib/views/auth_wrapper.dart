
/* Student numbers
223039784 Nido Maphosa
223035639 PM Lesekele
219007064 T Dasheka
221001040 K.Loape
224020157 KP Molelekeng
/// Purpose: Decides which screen to show on startup based on the user's
///          authentication state and role. Implements the assignment's
///          requirement that "the system must direct users to an
///          appropriate interface based on their role".
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_view.dart';
import 'student_home_view.dart';
import 'admin_dashboard_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the auth ViewModel - rebuilds when sign-in / sign-out happens.
    final auth = context.watch<AuthViewModel>();

    if (!auth.isLoggedIn) return const LoginView();
    if (auth.isAdmin) return const AdminDashboardView();
    return const StudentHomeView();
  }
}
