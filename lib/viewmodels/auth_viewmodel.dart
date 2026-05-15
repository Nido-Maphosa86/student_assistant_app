/* 
 // Group names
      ///K Loape 221001040
      ///P Lesekele 223035639
      ///NM Maphosa 223039784
      ///T Dasheka 219007064
      ///Maleke 222009259

/// 
/// Purpose: ViewModel for authentication. Handles sign-in / sign-out via
///          Supabase Auth (Unit 5) and exposes the current user's role so
///          the system can direct users to the correct portal 

*/
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// AuthViewModel - extends ChangeNotifier (Unit 2 MVVM pattern).
///
/// Holds authentication state and exposes it through getters.
/// Views interact with it via context.read() / context.watch() (Unit 2).
class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Private state (Unit 2 - private model, public getters)
  bool _isLoading = false;
  String? _errorMessage;
  String _role = 'student'; // "student" or "admin"

  // ============= GETTERS =============
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get role => _role;
  bool get isAdmin => _role == 'admin';

  bool get isLoggedIn => _supabase.auth.currentSession != null;
  String? get currentUserEmail => _supabase.auth.currentUser?.email;
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Clear any displayed error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============= SIGN IN (Unit 5) =============
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        _errorMessage = 'Sign-in failed. Please try again.';
        return false;
      }

      // After authentication, determine user role from the `profiles` table.
      // The assignment requires the system to "direct users to an appropriate
      // interface based on their role".
      await _loadUserRole(response.user!.id);
      return true;
    } catch (e) {
      _errorMessage = _friendly(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============= SIGN UP (Unit 5) =============
  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );
      if (response.user != null) {
        // New accounts default to "student" role - created server-side.
        _role = 'student';
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = _friendly(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============= SIGN OUT (Unit 5) =============
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _role = 'student';
    notifyListeners();
  }

  /// Reads the user's role from the `profiles` table.
  /// Profiles table is created server-side with a `role` column.
  Future<void> _loadUserRole(String userId) async {
    try {
      final result = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      _role = (result?['role'] as String?) ?? 'student';
    } catch (_) {
      _role = 'student'; // safe default
    }
  }

  /// Convert raw Supabase errors into user-friendly text.
  String _friendly(String raw) {
    if (raw.contains('Invalid login')) return 'Invalid email or password.';
    if (raw.contains('already registered')) return 'Email already registered.';
    if (raw.contains('Password should')) {
      return 'Password must be at least 6 characters.';
    }
    return 'Something went wrong. Please try again.';
  }
}
