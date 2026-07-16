/// Computes the academic year, term, and feedbackCycle from batch year and semester.
///
/// Example:
///   batchYear = 2024, sem = 5
///   yearOffset = (5-1) ~/ 2 = 2
///   startYear = 2024 + 2 = 2026
///   academicYear = "2026-2027"
///   term = "Odd" (sem 5 is odd)
///   feedbackCycle = "2026-2027_Odd"
class FeedbackCycleInfo {
  final String academicYear;
  final String term;
  final String feedbackCycle;

  FeedbackCycleInfo({
    required this.academicYear,
    required this.term,
    required this.feedbackCycle,
  });
}

FeedbackCycleInfo computeFeedbackCycle({
  required int batchYear,
  required int sem,
}) {
  final yearOffset = (sem - 1) ~/ 2;
  final startYear = batchYear + yearOffset;
  final academicYear = '$startYear-${startYear + 1}';
  final term = sem.isOdd ? 'Odd' : 'Even';
  final feedbackCycle = '${academicYear}_$term';

  return FeedbackCycleInfo(
    academicYear: academicYear,
    term: term,
    feedbackCycle: feedbackCycle,
  );
}
