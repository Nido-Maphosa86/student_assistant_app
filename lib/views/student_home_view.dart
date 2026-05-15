// ignore_for_file: deprecated_member_use


//Student Home screen. Shows
//         the authenticated student's application activity. Designed as a
//          "personal dossier" - ID-card style instead of a generic list.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/application_model.dart';
import '../routes/route_manager.dart';
import '../viewmodels/application_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/ui_kit.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  @override
  void initState() {
    super.initState();
    // Fetch the user's application after the first frame so that the
    // build context is fully ready (Unit 5 fetch-on-mount pattern).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationViewModel>().fetchMyApplications();
    });
  }

  Future<void> _signOut() async {
    await context.read<AuthViewModel>().signOut();
    if (!mounted) return;
    // Reset stack to login (Unit 3 - pushNamedAndRemoveUntil)
    Navigator.pushNamedAndRemoveUntil(
      context, RouteManager.wrapper, (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // watch() so the screen rebuilds when applications change (Unit 2)
    final vm = context.watch<ApplicationViewModel>();
    final auth = context.watch<AuthViewModel>();
    final ApplicationModel? app = vm.myApplication;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.accent,
          backgroundColor: AppTheme.surface,
          onRefresh: () =>
              context.read<ApplicationViewModel>().fetchMyApplications(),
          child: CustomScrollView(
            slivers: [
              // ============= TOP BAR =============
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('STUDENT PORTAL', style: AppTheme.label),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, size: 20),
                        tooltip: 'Sign out',
                        onPressed: _signOut,
                      ),
                    ],
                  ),
                ),
              ),

              // ============= GREETING =============
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome', style: AppTheme.displayLg),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'back.',
                            style: AppTheme.displayLg.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppTheme.accent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                                width: 8, height: 8, color: AppTheme.accent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        auth.currentUserEmail ?? '',
                        style: AppTheme.mono.copyWith(color: AppTheme.textMid),
                      ),
                    ],
                  ),
                ),
              ),

              // ============= MAIN CONTENT =============
              if (vm.isLoading && app == null)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  ),
                )
              else if (app == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _EmptyState(),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SectionLabel('Your Application', index: '01'),
                      const SizedBox(height: 16),
                      _ApplicationDossier(app: app),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),

              const SliverPadding(
                padding: EdgeInsets.only(bottom: 32),
                sliver: SliverToBoxAdapter(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// EMPTY STATE - shown when the student has not yet submitted an application
// =========================================================================
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('No application yet', index: '01'),
        const SizedBox(height: 24),

        // Large empty card with corner brackets - blueprint feel
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              const Positioned(top: 0, left: 0, child: CornerAccent()),
              const Positioned(
                  top: 0,
                  right: 0,
                  child: CornerAccent(alignment: Alignment.topRight)),
              const Positioned(
                  bottom: 0,
                  left: 0,
                  child: CornerAccent(alignment: Alignment.bottomLeft)),
              const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CornerAccent(alignment: Alignment.bottomRight)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppTheme.accent.withOpacity(0.4)),
                    ),
                    child: Text('STATUS: NIL',
                        style: AppTheme.label
                            .copyWith(color: AppTheme.accent)),
                  ),
                  const SizedBox(height: 20),
                  Text('Apply for a', style: AppTheme.displayMd),
                  Text(
                    'position.',
                    style: AppTheme.displayMd.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You have not submitted a Student Assistant '
                    'application yet. The system supports one application '
                    'per student, with a maximum of two modules.',
                    style: AppTheme.bodyMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Submit an application',
          icon: Icons.add,
          onPressed: () =>
              Navigator.pushNamed(context, RouteManager.applicationForm),
        ),
      ],
    );
  }
}

// =========================================================================
// APPLICATION DOSSIER - styled like a personnel file index card
// =========================================================================
class _ApplicationDossier extends StatelessWidget {
  final ApplicationModel app;
  const _ApplicationDossier({required this.app});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        RouteManager.applicationDetail,
        arguments: app,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----- TOP STRIP -----
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'APP / ${app.id.substring(0, 6).toUpperCase()}',
                    style: AppTheme.label,
                  ),
                  StatusPill(app.status),
                ],
              ),
            ),

            // ----- BODY -----
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name (display serif - the visual anchor)
                  Text(
                    app.fullName,
                    style: AppTheme.displayMd.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(app.studentNumber, style: AppTheme.mono),
                  const SizedBox(height: 20),

                  // Two-column grid: year + modules
                  _GridRow(
                    label: 'YEAR',
                    value: app.yearOfStudy,
                  ),
                  const SizedBox(height: 12),
                  _GridRow(
                    label: 'MODULE 1',
                    value: app.module1Code.split(' - ').first,
                    accent: true,
                  ),
                  if (app.module2Code != null) ...[
                    const SizedBox(height: 12),
                    _GridRow(
                      label: 'MODULE 2',
                      value: app.module2Code!.split(' - ').first,
                      accent: true,
                    ),
                  ],

                  const SizedBox(height: 24),
                  Container(height: 1, color: AppTheme.border),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TAP TO VIEW DETAILS', style: AppTheme.label),
                      const Icon(Icons.arrow_forward,
                          size: 16, color: AppTheme.accent),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridRow extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;
  const _GridRow({
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: AppTheme.label),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accent
                  ? AppTheme.accent.withOpacity(0.08)
                  : AppTheme.surfaceHi,
              border: Border.all(
                color: accent
                    ? AppTheme.accent.withOpacity(0.3)
                    : AppTheme.border,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              value,
              style: AppTheme.mono.copyWith(
                color: accent ? AppTheme.accent : AppTheme.textHi,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


