import 'package:facultyfeed/core/constants.dart';
import 'package:facultyfeed/core/error_text.dart';
import 'package:facultyfeed/core/loader.dart';
import 'package:facultyfeed/features/dashboard/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FormSelectScreen extends ConsumerStatefulWidget {
  const FormSelectScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FormSelectScreenState();
}

class _FormSelectScreenState extends ConsumerState<FormSelectScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBranch;
  int? _selectedSemester;

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedBranch = null;
      _selectedSemester = null;
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(feedbackFormsProvider)
        .when(
          data: (forms) {
            final branches =
                forms
                    .map((form) => form.branch)
                    .where((branch) => branch.trim().isNotEmpty)
                    .toSet()
                    .toList()
                  ..sort();

            final semesters =
                forms
                    .map((form) => form.semester)
                    .toSet()
                    .toList()
                  ..sort();

            // Filter forms based on search query
            final filteredForms =
                forms.where((form) {
                  final query = _searchQuery.toLowerCase();
                  final searchMatch =
                      form.facultyName.toLowerCase().contains(query) ||
                      form.subject.toLowerCase().contains(query);
                  final branchMatch =
                      _selectedBranch == null || form.branch == _selectedBranch;
                  final semesterMatch =
                      _selectedSemester == null ||
                      form.semester == _selectedSemester;
                  return searchMatch && branchMatch && semesterMatch;
                }).toList();
            return Scaffold(
              appBar: AppBar(
                title: const Text('Select Feedback Form'),
                centerTitle: true,
              ),
              body:
                  forms.isEmpty
                      ? Center(
                        child: Text(
                          'No forms available.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                      : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find a feedback form',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Search by faculty, subject, branch, or semester.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 16),
                            Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _searchController,
                                      onChanged: (value) {
                                        setState(() {
                                          _searchQuery = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText:
                                            'Search faculty or subject...',
                                        prefixIcon: const Icon(Icons.search),
                                        suffixIcon:
                                            _searchQuery.isNotEmpty
                                                ? IconButton(
                                                  icon: const Icon(
                                                    Icons.clear,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _searchController.clear();
                                                      _searchQuery = '';
                                                    });
                                                  },
                                                )
                                                : null,
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<String?>(
                                            value: _selectedBranch,
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              labelText: 'Branch',
                                              filled: true,
                                              fillColor: Colors.grey.shade50,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            items: [
                                              const DropdownMenuItem<String?>(
                                                value: null,
                                                child: Text('All branches'),
                                              ),
                                              ...branches.map(
                                                (branch) => DropdownMenuItem<
                                                  String?
                                                >(
                                                  value: branch,
                                                  child: Text(branch),
                                                ),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedBranch = value;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: DropdownButtonFormField<int?>(
                                            value: _selectedSemester,
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              labelText: 'Semester',
                                              filled: true,
                                              fillColor: Colors.grey.shade50,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            items: [
                                              const DropdownMenuItem<int?>(
                                                value: null,
                                                child: Text('All semesters'),
                                              ),
                                              ...semesters.map(
                                                (semester) => DropdownMenuItem<
                                                  int?
                                                >(
                                                  value: semester,
                                                  child: Text('Sem $semester'),
                                                ),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedSemester = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_searchQuery.isNotEmpty ||
                                        _selectedBranch != null ||
                                        _selectedSemester != null)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: _clearFilters,
                                          icon: const Icon(Icons.filter_alt_off),
                                          label: const Text('Clear filters'),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${filteredForms.length} form${filteredForms.length == 1 ? '' : 's'}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey.shade600),
                                ),
                                if (_searchQuery.isNotEmpty ||
                                    _selectedBranch != null ||
                                    _selectedSemester != null)
                                  Text(
                                    'Filtered results',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child:
                                  filteredForms.isEmpty
                                      ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(18),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.filter_alt_off,
                                                size: 44,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No forms match the selected filters',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge?.copyWith(
                                                color: Colors.grey.shade600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            TextButton(
                                              onPressed: _clearFilters,
                                              child: const Text('Reset filters'),
                                            ),
                                          ],
                                        ),
                                      )
                                      : GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 16,
                                              mainAxisSpacing: 16,
                                              childAspectRatio: 0.78,
                                            ),
                                        itemCount: filteredForms.length,
                                        itemBuilder: (context, index) {
                                          final form = filteredForms[index];
                                          return GestureDetector(
                                            onTap: () {
                                              context.push(
                                                '/stats',
                                                extra: form,
                                              );
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              curve: Curves.easeInOut,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  14.0,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 30,
                                                      backgroundColor: Theme.of(
                                                        context,
                                                      ).colorScheme.primary
                                                          .withOpacity(0.12),
                                                      backgroundImage:
                                                          AssetImage(
                                                            Constants.userImage,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Text(
                                                      form.subject,
                                                      style:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .titleMedium,
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      form.facultyName,
                                                      style:
                                                          Theme.of(
                                                            context,
                                                          ).textTheme.bodySmall,
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Wrap(
                                                      spacing: 8,
                                                      runSpacing: 6,
                                                      alignment:
                                                          WrapAlignment.center,
                                                      children: [
                                                        _FilterChipLabel(
                                                          icon: Icons
                                                              .account_tree,
                                                          label: form.branch,
                                                        ),
                                                        _FilterChipLabel(
                                                          icon: Icons.class_,
                                                          label:
                                                              'Sem ${form.semester}',
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                            ),
                          ],
                        ),
                      ),
            );
          },
          error: (e, _) => ErrorText(message: e.toString()),
          loading: () => const Loader(),
        );
  }
}

class _FilterChipLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FilterChipLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
