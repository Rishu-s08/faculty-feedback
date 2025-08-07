import 'package:facultyfeed/core/error_text.dart';
import 'package:facultyfeed/core/loader.dart';
import 'package:facultyfeed/features/auth/controller/auth_controller.dart';
import 'package:facultyfeed/features/dashboard/controller/dashboard_controller.dart';
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(userProvider); // includes role, branch, sem
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

            final filteredForms =
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
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    filteredForms.isEmpty
                        ? Center(
                          child: Text(
                            'No feedback available at the moment.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                        : ListView.separated(
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
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      'Faculty: ${form.facultyName}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      'Year: ${form.year}, Semester: ${form.semester}',
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
                                  context.push('/give-feedback', extra: form);
                                },
                              ),
                            );
                          },
                        ),
              ),
            );
          },
          error: (err, _) => ErrorText(message: err.toString()),
          loading: () => const Loader(),
        );
  }
}
