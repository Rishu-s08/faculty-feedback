import 'package:facultyfeed/core/constants.dart';
import 'package:facultyfeed/core/loader.dart';
import 'package:facultyfeed/core/no_internet_widget.dart';
import 'package:facultyfeed/features/auth/controller/auth_controller.dart';
import 'package:facultyfeed/features/dashboard/controller/dashboard_controller.dart';
import 'package:facultyfeed/features/feedback/controller/give_feedback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  String selectedYear = "All";
  String selectedBranch = "All";
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = ref.watch(userProvider)!.uid;
    final user = ref
        .watch(getUserDataProvider(uid))
        .maybeWhen(
          orElse: () => null,
          data: (user) {
            return user;
          },
        ); // includes role, branch, sem
    final feedbackResponseIds = user?.submittedFormIds ?? [];

    return ref
        .watch(feedbackFormsProvider)
        .when(
          data: (forms) {
            if (user == null) {
              return const Scaffold(
                body: Center(child: Text('User not found')),
              );
            }

            List filteredForms =
                user.role == 'admin'
                    ? forms
                    : forms
                        .where(
                          (form) =>
                              form.branch == user.branch &&
                              form.semester == user.semester &&
                              !feedbackResponseIds.contains(form.id),
                        )
                        .toList();

            if (selectedBranch == "All" && selectedYear == "All") {
              // filteredForms =
              //     user.role == 'admin'
              //         ? forms
              //         : forms
              //             .where(
              //               (form) =>
              //                   form.branch == user.branch &&
              //                   form.semester == user.semester &&
              //                   !feedbackResponseIds.contains(form.id),
              //             )
              //             .toList();
            } else if (selectedBranch != "All" && selectedYear == "All") {
              filteredForms =
                  filteredForms
                      .where((form) => form.branch == selectedBranch)
                      .toList();
            } else if (selectedBranch == "All" && selectedYear != "All") {
              filteredForms =
                  filteredForms
                      .where((form) => form.year == int.parse(selectedYear[0]))
                      .toList();
            } else {
              filteredForms =
                  filteredForms
                      .where(
                        (form) =>
                            form.branch == selectedBranch &&
                            form.year == int.parse(selectedYear[0]),
                      )
                      .toList();
            }

            final isRemainingForms =
                filteredForms.isNotEmpty && user.role != 'admin';
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(isFormRemainingProvider.notifier).state =
                  isRemainingForms;
            });

            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (user.role == 'admin')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              "Filters : ",
                              style: theme.textTheme.titleMedium,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField(
                                initialValue: "All",
                                items:
                                    [
                                          "All",
                                          "1st Year",
                                          "2nd Year",
                                          "3rd Year",
                                          "4th Year",
                                        ]
                                        .map(
                                          (year) => DropdownMenuItem(
                                            value: year,
                                            child: Text(year),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedYear = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: DropdownButtonFormField(
                                items:
                                    ["All", ...Constants.branches]
                                        .map(
                                          (branch) => DropdownMenuItem(
                                            value: branch,
                                            child: Text(branch),
                                          ),
                                        )
                                        .toList(),
                                initialValue: "All",
                                onChanged: (value) {
                                  setState(() {
                                    selectedBranch = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    filteredForms.isEmpty
                        ? Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 420,
                                ),
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary
                                                .withAlpha(
                                              (0.10 * 255).toInt(),
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.inbox_rounded,
                                            size: 34,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No feedback available right now.',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'When new feedback forms are published, they will appear here automatically.',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .outline,
                                                height: 1.4,
                                              ),
                                        ),
                                        if (user.role != 'admin') ...[
                                          const SizedBox(height: 16),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary
                                                  .withAlpha(
                                                (0.06 * 255).toInt(),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              'Tip: check back after your department shares a new form.',
                                              textAlign: TextAlign.center,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        : Expanded(
                          child: ListView.separated(
                            itemCount: filteredForms.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final form = filteredForms[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 3,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(20),
                                  title: Text(
                                    form.subject,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        'Faculty: ${form.facultyName}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      Text(
                                        'Semester: ${form.semester}, Branch: ${form.branch}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.outline,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Created: ${DateFormat.yMMMMd().format(form.createdAt)}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontStyle: FontStyle.italic,
                                              color: theme.colorScheme.outline,
                                            ),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                  ),
                                  onTap: () {
                                    if (user.role == 'admin') {
                                      context.push(
                                        '/edit-feedback-form',
                                        extra: form,
                                      );
                                    } else {
                                      context.push(
                                        '/give-feedback',
                                        extra: form,
                                      );
                                    }
                                  },
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
          error: (err, _) => NoInternetWidget(
            message: 'Unable to load feedback forms.\nPlease check your connection.',
            onRetry: () => ref.invalidate(feedbackFormsProvider),
          ),
          loading: () => const Loader(),
        );
  }
}
