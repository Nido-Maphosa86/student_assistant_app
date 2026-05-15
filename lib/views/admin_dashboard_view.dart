
// ignore_for_file: deprecated_member_use

/*
 // Group names
      ///K Loape 221001040
      ///P Lesekele 223035639
      ///NM Maphosa 223039784
      ///T Dasheka 219007064
      ///Maleke 222009259
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/application_model.dart';
import '../routes/route_manager.dart';
import '../viewmodels/application_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/ui_kit.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  @override
  void initState() {
    super.initState();
    // Fetch all applications after the first frame (Unit 5)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationViewModel>().fetchAllApplications();
    });
  }

  Future<void> _signOut() async {
    await context.read<AuthViewModel>().signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context, RouteManager.wrapper, (_) => false,
    );
  }

  /// Confirm + delete an application (admin "remove invalid applications").
  Future<void> _delete(BuildContext context, ApplicationModel app) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Text('Remove application', style: AppTheme.heading),
        content: Text(
          'This will permanently remove the application from the system.',
          style: AppTheme.bodyMuted,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('CANCEL', style: TextStyle(color: AppTheme.textMid)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('REMOVE',
                style: TextStyle(color: AppTheme.rejected)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    // ignore: use_build_context_synchronously
    await context.read<ApplicationViewModel>().deleteApplication(app.id);
  }

  @override
  Widget build(BuildContext context) {
    // watch() rebuilds whenever applications / filter change (Unit 2)
    final vm = context.watch<ApplicationViewModel>();
    final filtered = vm.filteredApplications;

    // Stats summary (used in the header strip)
    final total = vm.applications.length;
    final pending =
        vm.applications.where((a) => a.status == 'pending').length;
    final approved =
        vm.applications.where((a) => a.status == 'approved').length;
    final rejected =
        vm.applications.where((a) => a.status == 'rejected').length;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.accent,
          backgroundColor: AppTheme.surface,
          onRefresh: () =>
              context.read<ApplicationViewModel>().fetchAllApplications(),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              'ADMIN',
                              style: AppTheme.label.copyWith(
                                color: AppTheme.canvas,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('CONTROL PANEL', style: AppTheme.label),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, size: 20),
                        onPressed: _signOut,
                      ),
                    ],
                  ),
                ),
              ),

              // ============= TITLE =============
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Application', style: AppTheme.displayLg),
                      Text(
                        'review.',
                        style: AppTheme.displayLg.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ============= STATS STRIP =============
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        _StatCell(label: 'TOTAL', value: '$total'),
                        _vDivider(),
                        _StatCell(
                            label: 'PENDING',
                            value: '$pending',
                            color: AppTheme.pending),
                        _vDivider(),
                        _StatCell(
                            label: 'APPROVED',
                            value: '$approved',
                            color: AppTheme.approved),
                        _vDivider(),
                        _StatCell(
                            label: 'REJECTED',
                            value: '$rejected',
                            color: AppTheme.rejected),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ============= FILTER TABS =============
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _FilterChip(
                            label: 'ALL',
                            value: 'all',
                            current: vm.filter,
                            onTap: vm.setFilter),
                        const SizedBox(width: 8),
                        _FilterChip(
                            label: 'PENDING',
                            value: 'pending',
                            current: vm.filter,
                            onTap: vm.setFilter),
                        const SizedBox(width: 8),
                        _FilterChip(
                            label: 'APPROVED',
                            value: 'approved',
                            current: vm.filter,
                            onTap: vm.setFilter),
                        const SizedBox(width: 8),
                        _FilterChip(
                            label: 'REJECTED',
                            value: 'rejected',
                            current: vm.filter,
                            onTap: vm.setFilter),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ============= LIST =============
              if (vm.isLoading && vm.applications.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  ),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 40,
                            color: AppTheme.textMid.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text('No applications to show', style: AppTheme.bodyMuted),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AdminAppCard(
                          app: filtered[i],
                          onApprove: () => context
                              .read<ApplicationViewModel>()
                              .changeStatus(filtered[i].id, 'approved'),
                          onReject: () => context
                              .read<ApplicationViewModel>()
                              .changeStatus(filtered[i].id, 'rejected'),
                          onDelete: () => _delete(context, filtered[i]),
                        ),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vDivider() => Container(
        height: 32,
        width: 1,
        color: AppTheme.border,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );
}

// =========================================================================
// STAT CELL - single number+label in the stats strip
// =========================================================================
class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatCell({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTheme.displayMd.copyWith(
              fontSize: 24,
              color: color ?? AppTheme.textHi,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.label),
        ],
      ),
    );
  }
}

// =========================================================================
// FILTER CHIP - tab-style status filter
// =========================================================================
class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.accent : Colors.transparent,
          border: Border.all(
            color: active ? AppTheme.accent : AppTheme.border,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          label,
          style: AppTheme.label.copyWith(
            color: active ? AppTheme.canvas : AppTheme.textMid,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// ADMIN APP CARD - row item with inline approve / reject / remove
// =========================================================================
class _AdminAppCard extends StatelessWidget {
  final ApplicationModel app;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDelete;

  const _AdminAppCard({
    required this.app,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // ----- TOP STRIP -----
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'REF / ${app.id.substring(0, 8).toUpperCase()}',
                    style: AppTheme.label,
                  ),
                ),
                StatusPill(app.status),
              ],
            ),
          ),

          // ----- BODY -----
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.fullName,
                  style: AppTheme.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(app.studentNumber, style: AppTheme.mono),
                const SizedBox(height: 12),

                // Module badges
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _ModuleBadge(label: app.module1Code.split(' - ').first),
                    if (app.module2Code != null)
                      _ModuleBadge(label: app.module2Code!.split(' - ').first),
                    _MutedBadge(label: app.yearOfStudy),
                  ],
                ),

                // ----- VIEW DETAILS BUTTON (Unit 3 navigation) -----
                // Opens the same Application Detail screen students use,
                // where the admin can tap the supporting document tile
                // to review the uploaded file (Unit 5 Storage URL).
                const SizedBox(height: 14),
                _MiniButton(
                  label: 'VIEW DETAILS & DOCUMENT',
                  icon: Icons.description_outlined,
                  color: AppTheme.surfaceHi,
                  onPressed: () => Navigator.pushNamed(
                    context,
                    RouteManager.applicationDetail,
                    arguments: app,
                  ),
                ),

                if (app.status == 'pending') ...[
                  const SizedBox(height: 14),
                  Container(height: 1, color: AppTheme.border),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniButton(
                          label: 'APPROVE',
                          icon: Icons.check,
                          color: AppTheme.accent,
                          dark: true,
                          onPressed: onApprove,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MiniButton(
                          label: 'REJECT',
                          icon: Icons.close,
                          color: AppTheme.rejected,
                          onPressed: onReject,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _MiniIconButton(
                        icon: Icons.delete_outline,
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniButton(
                          label: 'REVERT TO PENDING',
                          icon: Icons.history,
                          color: AppTheme.textMid,
                          onPressed: () =>
                              context.read<ApplicationViewModel>()
                                  .changeStatus(app.id, 'pending'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _MiniIconButton(
                        icon: Icons.delete_outline,
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleBadge extends StatelessWidget {
  final String label;
  const _ModuleBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.1),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: AppTheme.mono.copyWith(
          color: AppTheme.accent,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MutedBadge extends StatelessWidget {
  final String label;
  const _MutedBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTheme.label.copyWith(fontSize: 10),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool dark;
  final VoidCallback onPressed;

  const _MiniButton({
    required this.label,
    required this.icon,
    required this.color,
    this.dark = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: dark ? AppTheme.canvas : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          textStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _MiniIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: AppTheme.rejected,
          side: BorderSide(color: AppTheme.rejected.withOpacity(0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        onPressed: onPressed,
        child: Icon(icon, size: 16),
      ),
    );
  }
}