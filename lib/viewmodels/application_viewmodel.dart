/**
 // Group names
      ///K Loape 221001040
      ///P Lesekele 223035639
      ///NM Maphosa 223039784
      ///T Dasheka 219007064
      ///Maleke 222009259
 */

/// Purpose: ViewModel for Student Assistant applications. Performs the four
///          CRUD operations against Supabase (Unit 5) and notifies the UI.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';

/// ApplicationViewModel - the business-logic layer for applications.
///
///Unit 2 MVVM: private state, public getters, methods that mutate
/// state and call notifyListeners(). All persistence goes through Supabase
/// (Unit 5), and uploaded documents go to Supabase Storage.
class ApplicationViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _table = 'applications';
  static const String _bucket = 'documents';

  // ============= PRIVATE STATE =============
  List<ApplicationModel> _applications = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _filter = 'all'; // admin filter: all | pending | approved | rejected

  // ============= GETTERS =============
  List<ApplicationModel> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filter => _filter;

  /// Filtered list for the admin dashboard (Selector-friendly, Unit 2 Part 2).
  List<ApplicationModel> get filteredApplications {
    if (_filter == 'all') return _applications;
    return _applications.where((a) => a.status == _filter).toList();
  }

  /// The current authenticated student's single application (if any).
  /// The system enforces "applicants must not submit more than one
  /// application" - so this returns the first match.
  ApplicationModel? get myApplication {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return null;
    final mine = _applications.where((a) => a.userId == uid).toList();
    return mine.isEmpty ? null : mine.first;
  }

  // ============= ADMIN FILTER =============
  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  // ============= READ (Unit 5) =============
  /// Fetch only the current user's applications (RLS-scoped).
  Future<void> fetchMyApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from(_table)
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      _applications = (response as List)
          .map((row) => ApplicationModel.fromJson(row))
          .toList();
    } catch (e) {
      _errorMessage = 'Could not load your applications.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch ALL applications (admin-only).
  Future<void> fetchAllApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from(_table)
          .select()
          .order('created_at', ascending: false);

      _applications = (response as List)
          .map((row) => ApplicationModel.fromJson(row))
          .toList();
    } catch (e) {
      _errorMessage = 'Could not load applications.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============= CREATE (Unit 5) =============
  Future<bool> createApplication({
    required String fullName,
    required String studentNumber,
    required String email,
    required String yearOfStudy,
    required String module1Level,
    required String module1Code,
    String? module2Level,
    String? module2Code,
    required bool meetsRequirements,
    File? document,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = _supabase.auth.currentUser!.id;

      // Step 1 - insert row (without document URL yet)
      final inserted = await _supabase.from(_table).insert({
        'user_id': uid,
        'full_name': fullName,
        'student_number': studentNumber,
        'email': email,
        'year_of_study': yearOfStudy,
        'module1_level': module1Level,
        'module1_code': module1Code,
        'module2_level': module2Level,
        'module2_code': module2Code,
        'meets_requirements': meetsRequirements,
        'status': 'pending',
      }).select();

      if (inserted.isEmpty) return false;

      final newApp = ApplicationModel.fromJson(inserted.first);

      // Step 2 - if a supporting document was supplied, upload it (Unit 5
      // Storage flow) and patch the row with its URL.
      String? docUrl;
      if (document != null) {
        docUrl = await _uploadDocument(document, newApp.id, uid);
        if (docUrl != null) {
          await _supabase
              .from(_table)
              .update({'document_url': docUrl}).match({'id': newApp.id});
        }
      }

      _applications.insert(0, newApp.copyWith(documentUrl: docUrl));
      return true;
    } catch (e) {
      _errorMessage = 'Could not submit application. $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============= UPDATE (Unit 5) =============
  /// Student-side update - only allowed while status is "pending".
  Future<bool> updateApplication(ApplicationModel updated) async {
    if (updated.status != 'pending') {
      _errorMessage = 'Only pending applications can be edited.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _supabase
          .from(_table)
          .update(updated.toJson())
          .match({'id': updated.id});

      final i = _applications.indexWhere((a) => a.id == updated.id);
      if (i != -1) _applications[i] = updated;
      return true;
    } catch (e) {
      _errorMessage = 'Could not update application.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Admin-side status change (approve / reject).
  Future<bool> changeStatus(String id, String newStatus) async {
    try {
      await _supabase
          .from(_table)
          .update({'status': newStatus}).match({'id': id});

      final i = _applications.indexWhere((a) => a.id == id);
      if (i != -1) {
        _applications[i] = _applications[i].copyWith(status: newStatus);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Could not update status.';
      notifyListeners();
      return false;
    }
  }

  // ============= DELETE (Unit 5) =============
  Future<bool> deleteApplication(String id) async {
    try {
      await _supabase.from(_table).delete().match({'id': id});
      _applications.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Could not delete application.';
      notifyListeners();
      return false;
    }
  }

  // ============= STORAGE HELPER (Unit 5) =============
  Future<String?> _uploadDocument(File file, String appId, String userId) async {
    try {
      final ext = file.path.split('.').last;
      final path = '$userId/$appId.$ext';
      await _supabase.storage.from(_bucket).upload(path, file);
      return _supabase.storage.from(_bucket).getPublicUrl(path);
    } catch (_) {
      return null;
    }
  }
}
