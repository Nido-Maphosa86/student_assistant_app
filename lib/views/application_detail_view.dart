// ignore_for_file: deprecated_member_use

/* File: application_detail_view.dart
/// Purpose: Application Detail Screen (Assignment 1.4 - Read/Delete).
///          Shows full details of a submitted application. The student can
///          edit (while pending) or delete it after confirmation.
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/application_model.dart';
import '../routes/route_manager.dart';
import '../viewmodels/application_viewmodel.dart';
import '../widgets/ui_kit.dart';

class ApplicationDetailView extends StatelessWidget {
  final ApplicationModel application;
  const ApplicationDetailView({required this.application, super.key});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.rejected.withOpacity(0.15),
                  border: Border.all(
                      color: AppTheme.rejected.withOpacity(0.4)),
                ),
                child: Text(
                  'IRREVERSIBLE',
                  style: AppTheme.label.copyWith(color: AppTheme.rejected),
                ),
              ),
              const SizedBox(height: 16),
              Text('Delete', style: AppTheme.displayMd),
              Text(
                'application?',
                style: AppTheme.displayMd.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppTheme.rejected,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This will permanently remove your Student Assistant '
                'application. You can submit a new one afterwards.',
                style: AppTheme.bodyMuted,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(ctx, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.rejected,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'DELETE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    // ignore: use_build_context_synchronously
    final ok = await context
        .read<ApplicationViewModel>()
        .deleteApplication(application.id);

    if (!context.mounted) return;
    if (ok) {
      // Reset back to home (Unit 3 - popUntil pattern)
      Navigator.popUntil(context, ModalRoute.withName(RouteManager.studentHome));
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = application.status == 'pending';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('APPLICATION DETAILS', style: AppTheme.label),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // ============= HEADER STRIP =============
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'REF / ${application.id.substring(0, 8).toUpperCase()}',
                  style: AppTheme.label,
                ),
                StatusPill(application.status),
              ],
            ),
            const SizedBox(height: 24),

            // ============= NAME BLOCK =============
            Text(application.fullName, style: AppTheme.displayMd),
            const SizedBox(height: 4),
            Text(application.studentNumber, style: AppTheme.mono),
            const SizedBox(height: 32),

            // ============= APPLICANT SECTION =============
            const SectionLabel('Applicant', index: '01'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  InfoRow(label: 'Email', value: application.email),
                  _divider(),
                  InfoRow(label: 'Year', value: application.yearOfStudy),
                  _divider(),
                  InfoRow(
                    label: 'Submitted',
                    value: _formatDate(application.createdAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ============= MODULES SECTION =============
            const SectionLabel('Module applications', index: '02'),
            const SizedBox(height: 12),

            _ModuleCard(
              index: '1',
              level: application.module1Level,
              code: application.module1Code,
              primary: true,
            ),
            if (application.module2Code != null) ...[
              const SizedBox(height: 12),
              _ModuleCard(
                index: '2',
                level: application.module2Level!,
                code: application.module2Code!,
                primary: false,
              ),
            ],
            const SizedBox(height: 24),

            // ============= ELIGIBILITY SECTION =============
            const SectionLabel('Eligibility', index: '03'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    application.meetsRequirements
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    size: 20,
                    color: application.meetsRequirements
                        ? AppTheme.accent
                        : AppTheme.rejected,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      application.meetsRequirements
                          ? 'Applicant confirmed they meet the minimum '
                              'requirements'
                          : 'Applicant did not confirm eligibility',
                      style: AppTheme.body,
                    ),
                  ),
                ],
              ),
            ),

            // ============= SUPPORTING DOCUMENT =============
            if (application.documentUrl != null) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(color: AppTheme.border),
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
                      child: const Icon(Icons.description_outlined,
                          size: 18, color: AppTheme.accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Supporting document',
                              style: AppTheme.body
                                  .copyWith(fontWeight: FontWeight.w600)),
                          Text('Stored in Supabase', style: AppTheme.label),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),

            // ============= ACTIONS =============
            if (canEdit) ...[
              PrimaryButton(
                label: 'Edit application',
                icon: Icons.edit_outlined,
                onPressed: () => Navigator.pushNamed(
                  context,
                  RouteManager.applicationForm,
                  arguments: application,
                ),
              ),
              const SizedBox(height: 12),
              OutlineButton(
                label: 'Delete application',
                icon: Icons.delete_outline,
                color: AppTheme.rejected,
                onPressed: () => _confirmDelete(context),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 18, color: AppTheme.textMid),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This application has been reviewed and can no '
                        'longer be edited.',
                        style: AppTheme.bodyMuted.copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: AppTheme.border);

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}';
}

// =========================================================================
// MODULE CARD - displays a single module application
// =========================================================================
class _ModuleCard extends StatelessWidget {
  final String index;
  final String level;
  final String code;
  final bool primary;

  const _ModuleCard({
    required this.index,
    required this.level,
    required this.code,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Large mono index number
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary
                  ? AppTheme.accent
                  : AppTheme.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              index,
              style: TextStyle(
                fontFamily: AppTheme.fontDisplay,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: primary ? AppTheme.canvas : AppTheme.accent,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(level.toUpperCase(), style: AppTheme.label),
                const SizedBox(height: 4),
                Text(code,
                    style: AppTheme.body
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
