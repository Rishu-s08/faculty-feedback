# FacultyFeed

A Flutter-based faculty feedback system for educational institutions. Students submit anonymous feedback for their faculty, and admins view aggregated statistics filtered by academic session, batch, branch, and semester.

## Features

### Student
- View pending feedback forms (filtered by branch + semester)
- Rate faculty on 5 predefined criteria (1–5 scale)
- Optional comments
- Automatic duplicate prevention (can't submit same form twice)
- Pass-out recognition screen after final semester

### Admin
- Create feedback forms (faculty + subject + branch + semester)
- Edit/delete existing forms
- View statistics with filters:
  - Feedback Cycle (e.g., "2026-2027_Odd")
  - Batch Year (e.g., 2024)
  - Branch and Semester
- Concise view (pie charts, overall rating, quick stats)
- Detailed view (per-student responses)
- Export stats to PDF
- Manage students (add, update, delete, bulk import via Excel)
- Bulk semester update with batch isolation
- Bulk import students from Excel/CSV

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.7+ |
| State Management | Riverpod |
| Backend | Firebase (Firestore + Auth) |
| Routing | GoRouter |
| Error Handling | fpdart (Either pattern) |
| PDF Export | pdf + path_provider |
| Excel Import | excel + file_picker |
| Charts | pie_chart, percent_indicator |

## Getting Started

### Prerequisites
- Flutter SDK ^3.7.2
- Firebase project with Firestore and Authentication enabled
- Android Studio / VS Code

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/facultyfeed.git
   cd facultyfeed
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a Firebase project
   - Enable Email/Password authentication
   - Create Firestore database
   - Download and place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update `lib/firebase_options.dart` with your config

4. Run the app:
   ```bash
   flutter run
   ```

### Firestore Collections

| Collection | Purpose |
|-----------|---------|
| `users` | Student and admin profiles |
| `feedback_forms` | Form templates (subject, faculty, questions, ratings) |
| `response_feedbacks` | Individual student responses with feedback cycle tags |

## Usage

### Admin Workflow
1. Add students (single or bulk Excel import)
2. Create feedback forms for each subject/faculty
3. Students fill forms during the semester
4. View statistics filtered by session/batch
5. At semester end: bulk update students to next semester (clears submitted forms)
6. Export reports as PDF

### Student Workflow
1. Login with roll number credentials (`<rollno>@mlvti.ac.in`)
2. See pending feedback forms for current semester
3. Submit ratings + optional comment
4. Form disappears from pending list after submission

## Key Design Decisions

- **Forms are persistent templates** — not recreated each semester. The same form accumulates responses tagged with `feedbackCycle`
- **Academic session derived from student data** — `batchYear` (from email) + `semester` determines the feedback cycle at submission time
- **Stats computed from raw responses** — not from the form's aggregate `ratings` field. This allows accurate per-session filtering
- **Batch isolation on semester update** — admin selects which batch to promote, preventing accidental mixing of batches

## Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## License

This project is proprietary and intended for internal institutional use.
