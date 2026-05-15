/*
Student numbers
223039784 Nido Maphosa
223035639 PM Lesekele
219007064 T Dasheka
221001040 K.Loape
224020157 KP Molelekeng
/ Purpose: Centralised navigation table (Unit 3 - "RouteManager =
/          receptionist"). Supports both static routes and a dynamic
/          route for application details (Unit 3 dynamic-route pattern).
*/
import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../views/login_view.dart';
import '../views/auth_wrapper.dart';
import '../views/signup_view.dart';
import '../views/student_home_view.dart';
import '../views/application_form_view.dart';
import '../views/application_detail_view.dart';
import '../views/admin_dashboard_view.dart';

class RouteManager {
  // ============= STATIC ROUTE NAMES =============
  static const String wrapper = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String studentHome = '/student-home';
  static const String applicationForm = '/application-form';
  static const String applicationDetail = '/application-detail';
  static const String adminDashboard = '/admin-dashboard';

  /// onGenerateRoute callback (Unit 3 - "central control for all routes").
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case wrapper:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpView());

      case studentHome:
        return MaterialPageRoute(builder: (_) => const StudentHomeView());

      case applicationForm:
        // Dynamic route - optionally pass an existing application to edit.
        // If null, the form acts as a "create" form (Unit 3 dynamic routes).
        final existing = settings.arguments as ApplicationModel?;
        return MaterialPageRoute(
          builder: (_) => ApplicationFormView(existing: existing),
        );

      case applicationDetail:
        // Dynamic route - the application to display is passed as an arg.
        final app = settings.arguments as ApplicationModel;
        return MaterialPageRoute(
          builder: (_) => ApplicationDetailView(application: app),
        );

      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardView());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
