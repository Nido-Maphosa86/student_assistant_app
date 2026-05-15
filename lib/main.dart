
/*
Student numbers
223039784 Nido Maphosa
223035639 PM Lesekele
219007064 T Dasheka
221001040 K.Loape
224020157 KP Molelekeng

        up the Providers (Unit 2), and hands off to RouteManager
         (Unit 3) for navigation.
*/


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_theme.dart';
import 'routes/route_manager.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/application_viewmodel.dart';

// =========================================================================
// SUPABASE CREDENTIALS
// Replace with your own values from your single shared Supabase project
// (Assignment: "all group members must connect to a single Supabase
// project"). Both must be set before the app runs.
// =========================================================================
const String kSupabaseUrl = 'https://duxioizxwfqeyqnsclqm.supabase.co';
const String kSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR1eGlvaXp4d2ZxZXlxbnNjbHFtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg3ODQ1MjIsImV4cCI6MjA5NDM2MDUyMn0.IVRWH8kjenD3yscIB6jY1b0giht94QeS0rnUZ-FcXIA';

Future<void> main() async {
  // Required before any async work in main (Unit 5)
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Supabase (Unit 5)
  await Supabase.initialize(
    url: kSupabaseUrl,
    anonKey: kSupabaseAnonKey,
  );

  runApp(const StudentAssistantApp());
}

class StudentAssistantApp extends StatelessWidget {
  const StudentAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider - registers all our ViewModels so any descendant
    // widget can read / watch them (Unit 2 - Provider setup).
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
      ],
      child: MaterialApp(
        title: 'Student Assistant',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData,
        // Unit 3 - initial route + centralised onGenerateRoute
        initialRoute: RouteManager.wrapper,
        onGenerateRoute: RouteManager.generateRoute,
      ),
    );
  }
}
