/**
 * Student Numbers: 210000001, 210000002, 210000003, 210000004, 210000005
 * Student Names  : [Member 1], [Member 2], [Member 3], [Member 4], [Member 5]
 * File: application_form_view.dart
 * Purpose: Student Assistant Application Form (Assignment 1.3 - Create /
 *          Update Operation). Demonstrates Unit 4 form handling: GlobalKey,
 *          TextFormField with validators, controlled input via dropdowns,
 *          eligibility checkbox, and file upload.
 */

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/application_model.dart';
import '../models/module_catalogue.dart';
import '../routes/route_manager.dart';
import '../viewmodels/application_viewmodel.dart';
import '../widgets/ui_kit.dart';

class ApplicationFormView extends StatefulWidget {
  /// If non-null the form pre-fills with this application and runs in
  /// "update" mode (only allowed while status == "pending").
  final ApplicationModel? existing;

  const ApplicationFormView({this.existing, super.key});

  @override
  State<ApplicationFormView> createState() => _ApplicationFormViewState();
}

class _ApplicationFormViewState extends State<ApplicationFormView> {
  // ============= FORM PLUMBING (Unit 4) =============
  final _formKey = GlobalKey<FormState>();

  // Text controllers - lifecycle in init / dispose (Unit 4)
  late final TextEditingController _nameCtrl;
  late final TextEditingController _studentNumCtrl;
  late final TextEditingController _emailCtrl;

  // Controlled-input state (dropdowns / checkbox - Unit 4
  // "controlled input to avoid invalid selections")
  String? _yearOfStudy;
  String? _module1Level;
  String? _module1Code;
  bool _includeModule2 = false;
  String? _module2Level;
  String? _module2Code;
  bool _meetsRequirements = false;
  File? _document;
  String? _existingDocUrl;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.fullName ?? '');
    _studentNumCtrl = TextEditingController(text: e?.studentNumber ?? '');
    _emailCtrl = TextEditingController(text: e?.email ?? '');

    if (e != null) {
      _yearOfStudy = e.yearOfStudy;
      _module1Level = e.module1Level;
      _module1Code = e.module1Code;
      if (e.module2Code != null) {
        _includeModule2 = true;
        _module2Level = e.module2Level;
        _module2Code = e.module2Code;
      }
      _meetsRequirements = e.meetsRequirements;
      _existingDocUrl = e.documentUrl;
    }
  }

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks (Unit 4)
    _nameCtrl.dispose();
    _studentNumCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  /// Open the file picker to select a supporting document (Unit 5).
  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );
    if (result == null || result.files.single.path == null) return;
    setState(() => _document = File(result.files.single.path!));
  }

  /// Submit the form. Validates first, then calls the ViewModel.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Custom rule: must check the eligibility box
    if (!_meetsRequirements) {
      _snack('Please confirm you meet the minimum requirements.',
          error: true);
      return;
    }
    // Must attach supporting document (or already have one in edit mode)
    if (_document == null && _existingDocUrl == null) {
      _snack('Please attach your supporting documentation.', error: true);
      return;
    }

    final vm = context.read<ApplicationViewModel>();

    bool ok;
    if (_isEdit) {
      // ----- UPDATE -----
      final updated = widget.existing!.copyWith(
        fullName: _nameCtrl.text.trim(),
        studentNumber: _studentNumCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        yearOfStudy: _yearOfStudy,
        module1Level: _module1Level,
        module1Code: _module1Code,
        module2Level: _includeModule2 ? _module2Level : null,
        module2Code: _includeModule2 ? _module2Code : null,
        meetsRequirements: _meetsRequirements,
      );
      ok = await vm.updateApplication(updated);
    } else {
      // ----- CREATE -----
      // Guard against duplicate submission (Assignment: "applicants must
      // not submit more than one application")
      if (vm.myApplication != null) {
        _snack('You have already submitted an application.', error: true);
        return;
      }
      ok = await vm.createApplication(
        fullName: _nameCtrl.text.trim(),
        studentNumber: _studentNumCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        yearOfStudy: _yearOfStudy!,
        module1Level: _module1Level!,
        module1Code: _module1Code!,
        module2Level: _includeModule2 ? _module2Level : null,
        module2Code: _includeModule2 ? _module2Code : null,
        meetsRequirements: _meetsRequirements,
        document: _document,
      );
    }

    if (!mounted) return;
    if (ok) {
      _snack(_isEdit ? 'Application updated.' : 'Application submitted.');
      Navigator.pushNamedAndRemoveUntil(
        context, RouteManager.studentHome, (_) => false,
      );
    } else {
      _snack(vm.errorMessage ?? 'Submission failed.', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error ? AppTheme.rejected : AppTheme.accent,
        behavior: SnackBarBehavior.floating,
        content: Text(
          msg,
          style: TextStyle(
            color: error ? Colors.white : AppTheme.canvas,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ApplicationViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'EDIT APPLICATION' : 'NEW APPLICATION',
          style: AppTheme.label,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          // Unit 4 - show validation errors as soon as the user interacts
          // with a field, not only when they tap Submit. This makes the
          // form feel responsive and helps the user fix mistakes early.
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // IMPORTANT: we use SingleChildScrollView + Column here instead of
          // ListView. ListView builds children lazily, so fields that scroll
          // off-screen get disposed and the Form no longer validates them.
          // With Column, every TextFormField is always mounted, so
          // _formKey.currentState!.validate() checks ALL fields (Unit 4).
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // ============= HEADER =============
              Text(
                _isEdit ? 'Update' : 'Apply',
                style: AppTheme.displayMd,
              ),
              Text(
                _isEdit ? 'application.' : 'for a position.',
                style: AppTheme.displayMd.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'One application per student. Apply to assist with no more '
                'than two modules.',
                style: AppTheme.bodyMuted.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 32),

              // =====================================================
              // SECTION 01 - PERSONAL DETAILS
              // =====================================================
              const SectionLabel('Personal details', index: '01'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameCtrl,
                style: AppTheme.body,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  if (v.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  // Unit 4 - regex: letters, spaces, hyphens, apostrophes only.
                  // Rejects digits and special characters in the name.
                  if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(v.trim())) {
                    return 'Name can only contain letters, spaces and hyphens';
                  }
                  // Must contain at least one space (first + last name)
                  if (!v.trim().contains(' ')) {
                    return 'Please enter both first and last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _studentNumCtrl,
                keyboardType: TextInputType.number,
                style: AppTheme.body,
                decoration: const InputDecoration(labelText: 'Student number'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Student number is required';
                  }
                  // Unit 4 - regex: digits only.
                  if (!RegExp(r'^\d+$').hasMatch(v.trim())) {
                    return 'Student number must contain digits only';
                  }
                  // CUT student numbers are exactly 9 digits.
                  if (v.trim().length != 9) {
                    return 'Student number must be exactly 9 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: AppTheme.body,
                decoration: const InputDecoration(labelText: 'Email address'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$')
                      .hasMatch(v.trim())) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Controlled-input dropdown for year of study (Unit 4)
              _dropdown<String>(
                label: 'Current year of study',
                value: _yearOfStudy,
                items: ModuleCatalogue.yearsOfStudy,
                onChanged: (v) => setState(() => _yearOfStudy = v),
                validator: (v) =>
                    v == null ? 'Please select your year of study' : null,
              ),

              const SizedBox(height: 32),

              // =====================================================
              // SECTION 02 - FIRST MODULE
              // =====================================================
              const SectionLabel('First module', index: '02'),
              const SizedBox(height: 16),

              _dropdown<String>(
                label: 'Academic level',
                value: _module1Level,
                items: ModuleCatalogue.levels,
                onChanged: (v) => setState(() {
                  _module1Level = v;
                  _module1Code = null; // reset dependent dropdown
                }),
                validator: (v) =>
                    v == null ? 'Please select the academic level' : null,
              ),
              const SizedBox(height: 16),

              _dropdown<String>(
                label: 'Module',
                value: _module1Code,
                items: ModuleCatalogue.modulesFor(_module1Level),
                onChanged: (v) => setState(() => _module1Code = v),
                validator: (v) =>
                    v == null ? 'Please select a module' : null,
              ),

              const SizedBox(height: 32),

              // =====================================================
              // SECTION 03 - SECOND MODULE (OPTIONAL, LIMITED)
              // =====================================================
              const SectionLabel('Second module — optional', index: '03'),
              const SizedBox(height: 12),

              // Custom toggle for "add second module"
              _ToggleCard(
                value: _includeModule2,
                onChanged: (v) => setState(() {
                  _includeModule2 = v;
                  if (!v) {
                    _module2Level = null;
                    _module2Code = null;
                  }
                }),
                title: 'Apply for a second module',
                subtitle: 'Maximum of two modules allowed.',
              ),

              if (_includeModule2) ...[
                const SizedBox(height: 16),
                _dropdown<String>(
                  label: 'Academic level',
                  value: _module2Level,
                  items: ModuleCatalogue.levels,
                  onChanged: (v) => setState(() {
                    _module2Level = v;
                    _module2Code = null;
                  }),
                  validator: (v) {
                    if (!_includeModule2) return null;
                    return v == null ? 'Please select the academic level' : null;
                  },
                ),
                const SizedBox(height: 16),
                _dropdown<String>(
                  label: 'Module',
                  value: _module2Code,
                  items: ModuleCatalogue.modulesFor(_module2Level),
                  onChanged: (v) => setState(() => _module2Code = v),
                  validator: (v) {
                    if (!_includeModule2) return null;
                    if (v == null) return 'Please select a module';
                    if (v == _module1Code) {
                      return 'Module 2 must differ from Module 1';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 32),

              // =====================================================
              // SECTION 04 - ELIGIBILITY + DOCUMENTATION
              // =====================================================
              const SectionLabel('Eligibility & documents', index: '04'),
              const SizedBox(height: 16),

              _ToggleCard(
                value: _meetsRequirements,
                onChanged: (v) => setState(() => _meetsRequirements = v),
                title: 'I meet the minimum requirements',
                subtitle:
                    'I confirm I have passed the modules I am applying to '
                    'assist with.',
              ),

              const SizedBox(height: 16),

              // Document upload tile
              GestureDetector(
                onTap: _pickDocument,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border.all(
                      color: _document != null || _existingDocUrl != null
                          ? AppTheme.accent.withOpacity(0.5)
                          : AppTheme.border,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Icon(Icons.upload_file,
                            size: 18, color: AppTheme.accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _document != null
                                  ? _document!.path.split('/').last
                                  : _existingDocUrl != null
                                      ? 'Existing document on file'
                                      : 'Supporting document',
                              style: AppTheme.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text('PDF, JPG or PNG', style: AppTheme.label),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          size: 18, color: AppTheme.textMid),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // =====================================================
              // SUBMIT
              // =====================================================
              PrimaryButton(
                label: _isEdit ? 'Save changes' : 'Submit application',
                icon: _isEdit ? Icons.check : Icons.send,
                isLoading: vm.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Eligibility decisions are made by administrators.',
                  style: AppTheme.label,
                ),
              ),
              const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // STYLED DROPDOWN - keeps the design language consistent
  // =====================================================
  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      style: AppTheme.body,
      dropdownColor: AppTheme.surfaceHi,
      icon: const Icon(Icons.expand_more, color: AppTheme.textMid, size: 20),
      decoration: InputDecoration(labelText: label),
      items: items
          .map((i) => DropdownMenuItem<T>(
                value: i,
                child: Text(i.toString(), style: AppTheme.body),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}

// =========================================================================
// TOGGLE CARD - custom on/off control used for eligibility + 2nd module
// =========================================================================
class _ToggleCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;

  const _ToggleCard({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(
            color: value
                ? AppTheme.accent.withOpacity(0.5)
                : AppTheme.border,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom square check indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: value ? AppTheme.accent : Colors.transparent,
                border: Border.all(
                  color: value ? AppTheme.accent : AppTheme.borderHi,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child: value
                  ? const Icon(Icons.check, size: 14, color: AppTheme.canvas)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTheme.bodyMuted.copyWith(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}