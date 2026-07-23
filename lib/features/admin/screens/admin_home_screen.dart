import 'package:facultyfeed/core/loader.dart';
import 'package:facultyfeed/core/no_internet_widget.dart';
import 'package:facultyfeed/features/admin/screens/branch_forms_screen.dart';
import 'package:facultyfeed/features/dashboard/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Admin home screen that shows branch cards with form counts.
/// Tapping a branch navigates to its forms grouped by semester.
class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  /// All branches in the institution.
  static const List<_BranchInfo> _branches = [
    _BranchInfo(name: 'CSE', fullName: 'Computer Science', icon: Icons.computer),
    _BranchInfo(name: 'IT', fullName: 'Information Technology', icon: Icons.dns),
    _BranchInfo(name: 'TT', fullName: 'Textile Technology', icon: Icons.texture),
    _BranchInfo(name: 'TC', fullName: 'Telecommunication', icon: Icons.cell_tower),
    _BranchInfo(name: 'ME', fullName: 'Mechanical Engineering', icon: Icons.precision_manufacturing),
    _BranchInfo(name: 'ECE', fullName: 'Electronics & Comm.', icon: Icons.memory),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(feedbackFormsProvider).when(
      data: (forms) {
        // Count forms per branch
        final formCounts = <String, int>{};
        for (final form in forms) {
          formCounts[form.branch] = (formCounts[form.branch] ?? 0) + 1;
        }

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Departments',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap a branch to view its feedback forms',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _branches.length,
                    itemBuilder: (context, index) {
                      final branch = _branches[index];
                      final count = formCounts[branch.name] ?? 0;
                      return _BranchCard(
                        branch: branch,
                        formCount: count,
                        onTap: () => _openBranch(context, branch.name),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      error: (e, _) => NoInternetWidget(
        message: 'Unable to load data.\nPlease check your connection.',
        onRetry: () => ref.invalidate(feedbackFormsProvider),
      ),
      loading: () => const Loader(),
    );
  }

  void _openBranch(BuildContext context, String branch) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BranchFormsScreen(branch: branch),
      ),
    );
  }
}

/// Data class for branch display info.
class _BranchInfo {
  final String name;
  final String fullName;
  final IconData icon;

  const _BranchInfo({
    required this.name,
    required this.fullName,
    required this.icon,
  });
}

/// A single branch card in the grid.
class _BranchCard extends StatelessWidget {
  final _BranchInfo branch;
  final int formCount;
  final VoidCallback onTap;

  const _BranchCard({
    required this.branch,
    required this.formCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.06 * 255).toInt()),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha((0.10 * 255).toInt()),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  branch.icon,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                branch.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$formCount form${formCount == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
