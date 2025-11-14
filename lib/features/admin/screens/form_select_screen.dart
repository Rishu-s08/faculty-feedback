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
  @override
  Widget build(BuildContext context) {
    return ref
        .watch(feedbackFormsProvider)
        .when(
          data: (forms) {
            return Scaffold(
              appBar: AppBar(title: const Text('Select Feedback Form')),
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
                          children: [
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.9,
                                    ),
                                itemCount: forms.length,
                                itemBuilder: (context, index) {
                                  final form = forms[index];
                                  return GestureDetector(
                                    onTap: () {
                                      context.push('/stats', extra: form);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      curve: Curves.easeInOut,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 80,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 36,
                                              backgroundImage: AssetImage(
                                                Constants.userImage,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              form.subject,
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.titleMedium,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              form.facultyName,
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall,
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
