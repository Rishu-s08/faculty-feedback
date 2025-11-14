// import 'package:facultyfeed/core/snackbar.dart';
// import 'package:facultyfeed/features/feedback/controller/add_feedback_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class AddFeedbackScreen extends ConsumerStatefulWidget {
//   const AddFeedbackScreen({super.key});

//   @override
//   ConsumerState<AddFeedbackScreen> createState() => _AddFeedbackScreenState();
// }

// class _AddFeedbackScreenState extends ConsumerState<AddFeedbackScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String selectedYear = '1st Year';
//   String selectedSem = 'even';
//   final _facultyController = TextEditingController();
//   final _subjectController = TextEditingController();
//   final List<TextEditingController> _questionControllers = [
//     TextEditingController(),
//   ];

//   void _addQuestionField() {
//     setState(() {
//       _questionControllers.add(TextEditingController());
//     });
//   }

//   void _removeQuestionField(int index) {
//     setState(() {
//       _questionControllers.removeAt(index);
//     });
//   }

//   void _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       final questions = _questionControllers.map((c) => c.text).toList();

//       // ref
//       //     .read(addFeedbackControllerProvider)
//       //     .addFeedback(
//       //       _subjectController.text.trim(),
//       //       _facultyController.text.trim(),
//       //       int.parse(selectedYear[0]),
//       //       4,
//       //       questions,
//       //       context,
//       //     );

//       final controller = ref.read(addFeedbackControllerProvider);
//       final year = int.parse(selectedYear[0]);
//       final sem = selectedSem == 'even' ? 2 * year : 2 * year - 1;

//       final res = await controller.addFeedback(
//         _subjectController.text.trim(),
//         _facultyController.text.trim(),
//         year,
//         sem,
//         questions,
//       );

//       res.fold(
//         (l) {
//           if (context.mounted) {
//             showPrettySnackBar(context, l.message, isError: true);
//           }
//         },
//         (_) {
//           if (context.mounted) {
//             showPrettySnackBar(context, "Feedback form created successfully");
//           }
//         },
//       );
//       if (context.mounted) {
//         Navigator.of(context).pop();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _facultyController.dispose();
//     _subjectController.dispose();
//     for (var controller in _questionControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Create Feedback Form')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               DropdownButtonFormField<String>(
//                 value: selectedYear,
//                 decoration: const InputDecoration(
//                   labelText: 'Select Year',
//                   border: OutlineInputBorder(),
//                 ),
//                 items:
//                     ['1st Year', '2nd Year', '3rd Year', '4th Year']
//                         .map(
//                           (year) =>
//                               DropdownMenuItem(value: year, child: Text(year)),
//                         )
//                         .toList(),
//                 onChanged: (value) {
//                   if (value != null) {
//                     setState(() {
//                       selectedYear = value;
//                     });
//                   }
//                 },
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: selectedSem,
//                 decoration: const InputDecoration(
//                   labelText: 'Select Semester',
//                   border: OutlineInputBorder(),
//                 ),
//                 items:
//                     ['even', 'odd']
//                         .map(
//                           (sem) =>
//                               DropdownMenuItem(value: sem, child: Text(sem)),
//                         )
//                         .toList(),
//                 onChanged: (value) {
//                   if (value != null) {
//                     setState(() {
//                       selectedSem = value;
//                     });
//                   }
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _facultyController,
//                 decoration: const InputDecoration(
//                   labelText: 'Faculty Name',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator:
//                     (value) =>
//                         value!.isEmpty ? 'Please enter faculty name' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _subjectController,
//                 decoration: const InputDecoration(
//                   labelText: 'Subject Name',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator:
//                     (value) =>
//                         value!.isEmpty ? 'Please enter subject name' : null,
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'Feedback Questions',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               ..._questionControllers.asMap().entries.map((entry) {
//                 final index = entry.key;
//                 final controller = entry.value;
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 12.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           controller: controller,
//                           decoration: InputDecoration(
//                             labelText: 'Question ${index + 1}',
//                             border: const OutlineInputBorder(),
//                           ),
//                           validator:
//                               (value) =>
//                                   value!.isEmpty
//                                       ? 'Please enter question ${index + 1}'
//                                       : null,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       if (_questionControllers.length > 1)
//                         IconButton(
//                           icon: const Icon(
//                             Icons.remove_circle,
//                             color: Colors.red,
//                           ),
//                           onPressed: () => _removeQuestionField(index),
//                         ),
//                     ],
//                   ),
//                 );
//               }),
//               TextButton.icon(
//                 icon: const Icon(Icons.add),
//                 label: const Text('Add Question'),
//                 onPressed: _addQuestionField,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.check),
//                 label: const Text('Create Feedback Form'),
//                 onPressed: _submitForm,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//static from now

import 'package:facultyfeed/core/snackbar.dart';
import 'package:facultyfeed/features/feedback/controller/add_feedback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddFeedbackScreen extends ConsumerStatefulWidget {
  const AddFeedbackScreen({super.key});

  @override
  ConsumerState<AddFeedbackScreen> createState() => _AddFeedbackScreenState();
}

class _AddFeedbackScreenState extends ConsumerState<AddFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  String selectedYear = '1st Year';
  String selectedSem = 'even';
  String selectedBranch = 'CSE';

  final _facultyController = TextEditingController();
  final _subjectController = TextEditingController();

  final List<String> staticQuestions = [
    'Subject Knowledge and Expertise',
    'Teaching Methodology and Delivery',
    'Communication and Clarity',
    'Punctuality and Professionalism',
    'Mentorship, Guidance, and Support',
  ];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(addFeedbackControllerProvider);
      final year = int.parse(selectedYear[0]);
      final sem = selectedSem == 'even' ? 2 * year : 2 * year - 1;

      final res = await controller.addFeedback(
        _subjectController.text.trim(),
        _facultyController.text.trim(),
        year,
        sem,
        staticQuestions,
        selectedBranch,
      );

      res.fold(
        (l) {
          if (context.mounted) {
            showPrettySnackBar(context, l.message, isError: true);
          }
        },
        (_) {
          if (context.mounted) {
            showPrettySnackBar(context, "Feedback form created successfully");
            Navigator.of(context).pop();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _facultyController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Feedback Form')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedYear,
                decoration: const InputDecoration(
                  labelText: 'Select Year',
                  border: OutlineInputBorder(),
                ),
                items:
                    ['1st Year', '2nd Year', '3rd Year', '4th Year']
                        .map(
                          (year) =>
                              DropdownMenuItem(value: year, child: Text(year)),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedYear = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedSem,
                decoration: const InputDecoration(
                  labelText: 'Select Semester',
                  border: OutlineInputBorder(),
                ),
                items:
                    ['even', 'odd']
                        .map(
                          (sem) =>
                              DropdownMenuItem(value: sem, child: Text(sem)),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedSem = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedBranch,
                decoration: const InputDecoration(
                  labelText: 'Select Branch',
                  border: OutlineInputBorder(),
                ),
                items:
                    ['CSE', 'IT']
                        .map(
                          (branch) => DropdownMenuItem(
                            value: branch,
                            child: Text(branch),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedBranch = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _facultyController,
                decoration: const InputDecoration(
                  labelText: 'Faculty Name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter faculty name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter subject name' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Static Feedback Questions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...staticQuestions.map(
                (q) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text('• $q', style: const TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Create Feedback Form'),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
