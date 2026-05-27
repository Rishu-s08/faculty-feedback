// 📦 IMPORTS
import 'dart:io'; // For file operations (reading/writing files)
import 'package:facultyfeed/core/models/feedback_form.dart'; // FeedbackForm model
import 'package:facultyfeed/core/models/response_form.dart'; // ResponseForm model
import 'package:facultyfeed/core/snackbar.dart'; // Pretty snackbar
import 'package:facultyfeed/features/dashboard/controller/dashboard_controller.dart';
import 'package:flutter/material.dart'; // For UI components
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart'; // PDF page format and settings
import 'package:pdf/widgets.dart' as pw; // PDF widgets (tables, text, etc.)
import 'package:path_provider/path_provider.dart'; // Gets device storage paths
import 'package:excel/excel.dart'; // Creates Excel files
import 'package:open_file/open_file.dart'; // Opens files after export

/// 📊 Export Service - Handles PDF and Excel export functionality
class ExportService {
  /// 📄 Export DETAILED student responses to EXCEL
  ///
  /// This creates a spreadsheet with:
  /// - Each student's name
  /// - Their ratings for each question
  /// - Their comments
  ///
  /// Perfect for detailed analysis and record-keeping
  static Future<void> exportDetailedStatsToExcel({
    required BuildContext context,
    required List<ResponseForm> responses, // All student responses
    required String formId, // Unique form identifier
    required WidgetRef ref, // Riverpod ref for provider access
  }) async {
    // ❌ Check if there's data to export
    if (responses.isEmpty) {
      showPrettySnackBar(context, 'No responses to export', isError: true);
      return;
    }

    try {
      final formData = await ref
          .read(feedbackControllerProvider)
          .getFeedbackFormByFormId(formId, context);

      // 1️⃣ CREATE EXCEL FILE
      var excel = Excel.createExcel(); // Initialize new Excel workbook
      Sheet sheetObject = excel['Detailed Responses']; // Create sheet
      final questions =
          responses.first.responses.keys.toList(); // Get all questions

      // 2️⃣ ADD HEADERS AND INFO
      sheetObject.appendRow(['Detailed Feedback Report']); // Title
      sheetObject.appendRow([]); // Empty row for spacing
      sheetObject.appendRow(['Form ID:', formId]); // Form identifier
      sheetObject.appendRow(['Total Responses:', responses.length]);
      sheetObject.appendRow(['Faculty Name', formData.facultyName]);
      sheetObject.appendRow(['Subject', formData.subject]);
      sheetObject.appendRow(['Year', formData.year]);
      sheetObject.appendRow(['Semester', formData.semester]);
      sheetObject.appendRow([
        'Generated On:',
        DateTime.now().toString(),
      ]); // Timestamp
      sheetObject.appendRow([]); // Empty row

      // 3️⃣ ADD COLUMN HEADERS (Student | Question1 | Question2 | ... | Comment)
      sheetObject.appendRow(['Student', 'Batch', ...questions, 'Comment']);

      // 4️⃣ ADD DATA ROWS - Loop through each student's response
      for (var response in responses) {
        sheetObject.appendRow([
          response.studentName, // Student name
          response.batchYear?.toString() ?? '-',
          ...questions.map((q) {
            // For each question, get the rating
            final rating = response.responses[q];
            return rating?.toString() ?? '-'; // Show '-' if no rating
          }),
          response.comment?.trim().isEmpty ?? true
              ? '-' // Show '-' if no comment
              : response.comment!,
        ]);
      }

      // 5️⃣ SAVE FILE TO DEVICE (Downloads folder)
      final directory = await getExternalStorageDirectory(); // Get app storage
      // Navigate to Downloads: /storage/emulated/0/Download
      final downloadsPath = directory!.path.split('Android')[0] + 'Download';
      final downloadsDir = Directory(downloadsPath);

      // Create Downloads folder if it doesn't exist
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName = 'FeedbackDetails_$formId.xlsx';
      final file = File('${downloadsDir.path}/$fileName');
      final bytes = excel.encode(); // Convert Excel to bytes

      if (bytes != null) {
        await file.writeAsBytes(bytes); // Write to file

        // 6️⃣ OPEN THE FILE automatically
        await OpenFile.open(file.path);

        // ✅ Show success message
        showPrettySnackBar(context, 'Excel saved to Downloads/$fileName');
      }
    } catch (e) {
      // ❌ Show error if something went wrong
      showPrettySnackBar(context, 'Error exporting Excel: $e', isError: true);
    }
  }

  /// 📈 Export CONCISE summary statistics to PDF
  ///
  /// This creates a PDF document with:
  /// - Faculty and course information
  /// - Overall average rating
  /// - Table of ratings per question
  ///
  /// Perfect for quick overview and reports
  static Future<void> exportConciseStatsToPDF({
    required BuildContext context,
    required FeedbackForm form, // The feedback form with aggregated data
    int? batchYear,
  }) async {
    try {
      // 1️⃣ CREATE PDF DOCUMENT
      final pdf = pw.Document();

      // 2️⃣ CALCULATE STATISTICS
      // Sum all ratings and find average
      double total = form.ratings.values.fold(0.0, (sum, r) => sum + r);
      double overallAverage =
          form.ratings.isEmpty ? 0 : total / form.ratings.length;

      // 3️⃣ ADD PAGE WITH CONTENT
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4, // Standard A4 size
          margin: const pw.EdgeInsets.all(32), // Margin around page
          build:
              (context) => [
                // 📌 TITLE
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'Faculty Feedback Summary',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20), // Spacing
                // 📌 BASIC INFORMATION
                pw.Text(
                  'Faculty: ${form.facultyName}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Subject: ${form.subject}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Year: ${form.year}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Semester: ${form.semester}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                if (batchYear != null)
                  pw.Text(
                    'Batch Year: $batchYear',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                pw.Text(
                  'Branch: ${form.branch}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Total Responses: ${form.totalResponses}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 20),

                // 📌 OVERALL RATING (highlighted)
                pw.Text(
                  'Overall Average Rating: ${overallAverage.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),

                // 📌 TABLE OF RATINGS PER QUESTION
                pw.TableHelper.fromTextArray(
                  headers: ['Question', 'Average Rating'], // Column headers
                  data:
                      form.ratings.entries.map((entry) {
                        // Each row: [question, rating]
                        return [
                          entry.key, // Question text
                          entry.value.toStringAsFixed(2), // Rating (2 decimals)
                        ];
                      }).toList(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 11),
                  cellAlignment: pw.Alignment.centerLeft,
                  headerAlignment: pw.Alignment.centerLeft,
                ),
              ],
        ),
      );

      // 4️⃣ SAVE PDF TO DEVICE (Downloads folder)
      final directory = await getExternalStorageDirectory(); // Get app storage
      // Navigate to Downloads: /storage/emulated/0/Download
      final downloadsPath = directory!.path.split('Android')[0] + 'Download';
      final downloadsDir = Directory(downloadsPath);

      // Create Downloads folder if it doesn't exist
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName = 'FeedbackSummary_${form.id}.pdf';
      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsBytes(await pdf.save()); // Save PDF

      // 5️⃣ OPEN THE FILE automatically
      await OpenFile.open(file.path);

      // ✅ Show success message
      showPrettySnackBar(context, 'PDF saved to Downloads/$fileName');
    } catch (e) {
      // ❌ Show error if something went wrong
      showPrettySnackBar(context, 'Error exporting PDF: $e', isError: true);
    }
  }
}
