# Architecture

## Overview

FacultyFeed follows a **feature-first** architecture with clear separation between UI, business logic, and data layers. State management is handled by Riverpod with repository pattern for data access.

```
lib/
├── main.dart                    # App entry point, Firebase init
├── app_router.dart              # GoRouter route definitions
├── firebase_options.dart        # Firebase config (gitignored values)
├── core/                        # Shared utilities, models, providers
│   ├── models/                  # Data models (UserModel, FeedbackForm, ResponseForm)
│   ├── providers/               # Firebase instance providers
│   ├── services/                # Export service (PDF generation)
│   ├── utils/                   # Validators, feedback cycle helper
│   └── dialogs/                 # Reusable dialog widgets
├── features/                    # Feature modules
│   ├── auth/                    # Authentication (login, user state)
│   ├── dashboard/               # Main dashboard, feed screen
│   ├── feedback/                # Give, add, edit feedback forms
│   ├── admin/                   # Admin screens (stats, students, bulk ops)
│   └── student/                 # Student profile
└── theme/                       # App theme configuration
```

## Architecture Pattern

Each feature follows a 3-layer structure:

```
┌─────────────────────────────────────┐
│            Screen (UI)              │  ← Flutter widgets, ConsumerStatefulWidget
├─────────────────────────────────────┤
│          Controller                 │  ← Business logic, Riverpod providers
├─────────────────────────────────────┤
│          Repository                 │  ← Firestore queries, data mapping
└─────────────────────────────────────┘
```

- **Screen**: Presentation layer. Reads providers, dispatches actions.
- **Controller**: Orchestrates logic between UI and data. Exposed as Riverpod `Provider`.
- **Repository**: Direct Firestore interaction. Returns `Either<Failure, T>` using fpdart.

## Data Models

### UserModel
```
uid, email, name, branch, semester, batch, passOut, role, submittedFormIds
```
- `batch`: Admission year derived from roll number (e.g., `24xxxx` → 2024)
- `submittedFormIds`: Tracks which forms the student has completed this semester
- Cleared on bulk semester update to allow re-submission in new semester

### FeedbackForm
```
id, subject, facultyName, year, semester, branch, totalResponses, ratings, questions, createdAt
```
- Persistent template — same form is reused across academic sessions
- `ratings` / `totalResponses`: Running average (all-time), used as quick indicator only
- Actual stats are computed from raw responses with filters applied

### ResponseForm
```
id, formID, faculty, subject, sem, batchYear, branch, studentName, studentEmail,
responses, comment, academicYear, term, feedbackCycle
```
- Immutable record of a student's submission
- `feedbackCycle`: Computed at submission time from `batchYear + sem` (e.g., "2026-2027_Odd")
- Enables accurate per-session stats without modifying old data

## Feedback Cycle Computation

The academic session is derived from the student's data at submission time:

```dart
int yearOffset = (sem - 1) ~/ 2;        // sem 5 → offset 2
int startYear = batchYear + yearOffset;  // 2024 + 2 = 2026
String academicYear = "$startYear-${startYear + 1}";  // "2026-2027"
String term = sem.isOdd ? "Odd" : "Even";
String feedbackCycle = "${academicYear}_$term";  // "2026-2027_Odd"
```

This eliminates the need for a global settings document — the source of truth is the student's current state.

## State Management

```
┌──────────────┐     ┌──────────────┐     ┌──────────────────┐
│  userProvider │     │ feedbackForms│     │ getUserDataProvider│
│ (StateProvider)│    │(StreamProvider)│   │  (StreamProvider)  │
└──────────────┘     └──────────────┘     └──────────────────┘
       │                     │                       │
       ▼                     ▼                       ▼
   Auth state          All forms             Real-time user doc
   (login/logout)      (Firestore stream)    (semester, submittedForms)
```

- `userProvider`: Holds the current logged-in user. Set on login, cleared on logout.
- `feedbackFormsProvider`: Stream of all feedback forms from Firestore.
- `getUserDataProvider(uid)`: Real-time stream of a user's Firestore document.

## Authentication Flow

```
Login Screen
    │
    ▼
FirebaseAuth.signInWithEmailAndPassword()
    │
    ▼
Fetch UserModel from Firestore (users/{uid})
    │
    ├── role == 'admin' → Dashboard (Feed + Admin Profile)
    ├── passOut == true  → Pass-out congratulations screen
    └── role == 'student' → Dashboard (Feed + Student Profile)
```

Students login with `<rollno>@mlvti.ac.in` / password = roll number.

## Submission Flow

```
Student sees pending forms (branch + sem match, not in submittedFormIds)
    │
    ▼
Student submits ratings (1-5 per question)
    │
    ▼
┌─ Firestore Transaction ──────────────────────────────────────┐
│  Read form → compute new running average → update form doc   │
└──────────────────────────────────────────────────────────────┘
    │
    ▼
Save ResponseForm to response_feedbacks (with feedbackCycle tag)
    │
    ▼
Add formID to user's submittedFormIds (prevents re-submission)
```

The transaction prevents race conditions when multiple students submit simultaneously.

## Bulk Semester Update Flow

```
Admin selects: Batch (optional) → From Sem → To Sem
    │
    ▼
Query: users where role=student, semester=fromSem, batch=selectedBatch
    │
    ▼
Batch write (500 docs per batch):
  - semester = toSem (or 9 for pass-out)
  - passOut = true (if toSem == 9)
  - submittedFormIds = [] (clear for new semester)
```

Batch isolation prevents accidentally promoting students from different admission years.

## Stats Computation

Stats are **never read from the form's `ratings` field** in the admin panel. They are always computed fresh:

```
Fetch all ResponseForm docs where formID == selected form
    │
    ▼
Filter by feedbackCycle (primary) and batchYear (secondary)
    │
    ▼
Compute averages per question from filtered responses
    │
    ▼
Display in Concise View (pie chart, overall rating) or Detailed View (per-student)
```

This ensures stats are always accurate for the selected session, even though the form is reused across years.

## Firestore Security Considerations

- Students can only read forms matching their branch/semester
- `submittedFormIds` prevents duplicate submissions client-side
- Admin operations (create/delete forms, manage students) should be protected by Firestore rules checking `role == 'admin'`
- Student accounts are created via Identity Toolkit REST API to avoid switching the admin's auth session

## Error Handling

All repository methods return `Either<Failure, T>` (fpdart):
- `Left(Failure)` → error with message
- `Right(T)` → success with data

Controllers fold the result and show appropriate snackbars. Network errors (`SocketException`) are caught and displayed as user-friendly messages.
