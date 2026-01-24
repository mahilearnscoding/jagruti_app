# Jagruti App: Offline-First Multi-Phase Survey System

## Overview

The Jagruti app implements a complete offline-first, phased assessment flow for child welfare surveys with three distinct phases:

1. **Baseline** – Initial comprehensive household and child assessment (56 questions)
2. **Counselling** – Intervention assessment tracking behavior change (20 questions)
3. **Endline** – Follow-up measurement with anthropometric comparisons (24 questions)

All data is persisted locally first (Hive), then synced asynchronously to Appwrite when connectivity is available.

---

## Architecture & Key Components

### 1. **Fixed AppwriteService**
- `ensureSession()` now safely initializes `_account` and guards against multiple init calls
- Exposed `client` and `account` getters for access to underlying Appwrite instances
- Ensures anonymous session is created for offline capability

**File:** [lib/services/appwrite_service.dart](lib/services/appwrite_service.dart)

### 2. **Extended Phase System**
Three phases are now defined in constants:
- `phaseBaseline` – Initial assessment
- `phaseCounselling` – Intervention/counselling session
- `phaseEndline` – Final measurement & comparison

**File:** [lib/utils/constants.dart](lib/utils/constants.dart)

### 3. **Generic Question Service**
`QuestionService` now retrieves questions for any phase:
- `getBaselineQuestions(projectId)` – convenience wrapper
- `getCounsellingQuestions(projectId)` – convenience wrapper
- `getEndlineQuestions(projectId)` – convenience wrapper
- `getQuestionsForPhase(projectId, phase)` – core generic method

Supports all answer types including `multi_choice` (checkboxes).

**File:** [lib/services/question_service.dart](lib/services/question_service.dart)

### 4. **Phase-Aware Survey Screen**
Single `BaselineVisitScreen` now handles all three phases:
- Constructor accepts `phase` parameter (defaults to baseline for backward compatibility)
- Optional `title` parameter for custom headers
- Multi-choice rendering with checkbox UI (answers stored as comma-separated strings)
- Phase-specific status updates upon submission

**File:** [lib/screens/visits/baseline_visit_screen.dart](lib/screens/visits/baseline_visit_screen.dart)

### 5. **Child Profile Screen (NEW)**
Comprehensive UI showing:
- **Child Details** – Name, age, guardian, location
- **Phase Status Indicators** – Visual badges (✓ Done / ○ Pending)
  - Baseline: must be completed first
  - Counselling: enabled if baseline is done
  - Endline: enabled if baseline is done (counselling is optional but encouraged)
- **Action Buttons**
  - "Start Counselling" (enabled after baseline)
  - "Start Endline" (enabled after baseline)
  - Real-time status refresh from local Hive storage
- **Lock/Unlock Messaging** – Clear indicators of which phases are available

**File:** [lib/screens/children/child_profile_screen.dart](lib/screens/children/child_profile_screen.dart)

### 6. **Extended Child Service**
Tracks three phase statuses for each child:
- `baselineStatus` – 'draft' → 'submitted'
- `counsellingStatus` – 'pending' → 'submitted'
- `endlineStatus` – 'pending' → 'submitted'

New methods:
- `markCounsellingSubmittedLocal(childId, visitId)` – enqueues sync job
- `markEndlineSubmittedLocal(childId, visitId)` – enqueues sync job

**File:** [lib/services/child_service.dart](lib/services/child_service.dart)

### 7. **Extended Visit Service**
- `_encodeAnswer(value)` – handles `Set<String>` (multi-choice) by joining with commas
- Deterministic answer document IDs prevent duplicates on retry

**File:** [lib/services/visit_service.dart](lib/services/visit_service.dart)

### 8. **Extended Sync Manager**
Processes three new job types:
- `jobMarkCounsellingSubmitted` – updates child counselling status
- `jobMarkEndlineSubmitted` – updates child endline status
- Handles 409 conflicts by switching to update operations

**File:** [lib/services/sync_manager.dart](lib/services/sync_manager.dart)

### 9. **Counselling Question Bank**
20 structured questions covering:
- Child & family details
- Nutritional status (normal, MAM, SAM)
- Counselling delivery topics (4 meals/day, food consistency, age-appropriate foods, etc.)
- Caregiver behavior practices
- Session metadata (duration, field worker name)

**File:** [lib/models/counselling_seeder.dart](lib/models/counselling_seeder.dart)

### 10. **Endline Question Bank**
24 questions covering:
- Household & child baseline repeats
- Diet & ICDS service engagement (same as baseline for comparison)
- Health status & illness management
- **Anthropometric measurements** (weight, height, MUAC)
- **Comparison metrics** – Did weight/height/MUAC improve vs. baseline?

**File:** [lib/models/endline_seeder.dart](lib/models/endline_seeder.dart)

---

## Offline-First Data Flow

### Child Registration (Add Child Screen)
```
1. Field worker enters child name, DOB, guardian details
2. ChildService.createChildLocal() → stored in Hive immediately (UUID assigned)
3. Auto-creates Baseline Visit locally
4. Enqueues CREATE_CHILD sync job
5. SyncManager.trySync() attempts to push to Appwrite (if online)
   → If offline, child sits in Hive pending sync
```

### Baseline Survey (Phase 1)
```
1. Field worker answers 56 questions
2. Each answer saved to Hive locally
3. Enqueue UPSERT_VISIT_ANSWER jobs for each answer
4. On submit: VisitService.markVisitSubmittedLocal() + ChildService.markBaselineSubmittedLocal()
5. SyncManager.trySync() plays back all jobs in chronological order
6. Child appears in profile with baselineStatus='submitted'
```

### Counselling (Phase 2)
```
1. Child profile shows "Start Counselling" button (enabled after baseline)
2. Field worker navigates to counselling form
3. 20 questions about intervention topics answered
4. ChildService.markCounsellingSubmittedLocal() enqueues job
5. SyncManager syncs when online
```

### Endline (Phase 3)
```
1. Child profile shows "Start Endline" button (enabled after baseline)
2. Field worker answers 24 questions (includes anthropometric measurements)
3. Comparison logic shows weight/height/MUAC progress vs. baseline
4. ChildService.markEndlineSubmittedLocal() enqueues job
5. Full baseline→endline comparison available for analysis
```

---

## How to Use

### 1. Initialize Seeders on App Start
In your main.dart or app initialization:

```dart
import 'package:appwrite/appwrite.dart';
import 'lib/models/counselling_seeder.dart';
import 'lib/models/endline_seeder.dart';
import 'lib/services/appwrite_service.dart';

Future<void> initializeQuestionBanks(String projectDocId) async {
  final aw = AppwriteService.I;
  await aw.ensureSession();

  // Seed counselling questions
  final counsellingSeeder = CounsellingSeeder(aw: aw, projectDocId: projectDocId);
  await counsellingSeeder.seedCounselling();

  // Seed endline questions
  final endlineSeeder = EndlineSeeder(aw: aw, projectDocId: projectDocId);
  await endlineSeeder.seedEndline();

  print("✅ All question banks initialized!");
}
```

### 2. Navigate Child Profile from Child List
Tapping a child in the list now navigates to the full profile:

```dart
// Already implemented in child_list_screen.dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChildProfileScreen(
      childId: child['id'],
      childName: child['name'],
      projectId: widget.projectId,
      child: child,
    ),
  ),
);
```

### 3. Start Each Phase
From the profile screen, tap phase buttons:
- "Start Counselling" → BaselineVisitScreen with phase=counselling
- "Start Endline" → BaselineVisitScreen with phase=endline

The same survey screen reuses the infrastructure, just with different questions.

---

## Database Schema Requirements

### Children Collection
```
{
  "id": "uuid",
  "project": "projectId",
  "name": "string",
  "gender": "string",
  "date_of_birth": "iso8601",
  "guardian_name": "string",
  "guardian_contact": "string",
  "baselineStatus": "draft|submitted",
  "baselineVisitId": "visitId|null",
  "counsellingStatus": "pending|submitted",      // NEW
  "counsellingVisitId": "visitId|null",          // NEW
  "endlineStatus": "pending|submitted",          // NEW
  "endlineVisitId": "visitId|null",              // NEW
  "createdAt": "iso8601",
  "synced": "boolean"
}
```

### Project Questions Collection
Now supports multiple phases:
```
{
  "project": "projectId",
  "question": "questionId",
  "phase": "baseline|counselling|endline",  // Distinguishes phases
  "display_order": "int",
  "is_required": "boolean",
  "is_active": "boolean"
}
```

### Visit Answers Collection
Stores flattened multi-choice answers:
```
{
  "visit": "visitId",
  "question": "questionId",
  "answer_text": "value OR comma-separated-for-multi-choice",
  // e.g., "option_1,option_3,option_5"
}
```

---

## Key Features

✅ **Offline-First** – All data saved locally first; sync on connectivity  
✅ **Three Distinct Phases** – Baseline → Counselling → Endline workflow  
✅ **Phase Gates** – Endline unlocks only after baseline; counselling after baseline  
✅ **Status Tracking** – Real-time phase status visible on child profile  
✅ **Multi-Choice Support** – Checkboxes stored deterministically  
✅ **Anthropometric Tracking** – Weight, height, MUAC measured and compared  
✅ **Deterministic IDs** – Answer documents use stable UUIDs; safe retries without duplication  
✅ **Conflict Resolution** – 409 (Duplicate) errors gracefully become updates  
✅ **Sync Queue** – All jobs timestamped and replayed in order  

---

## Testing Checklist

- [ ] Register a child offline
- [ ] Complete baseline survey (56 questions)
- [ ] Verify child appears in profile with "baselineStatus": "submitted"
- [ ] Verify "Counselling" button is enabled
- [ ] Start counselling; answer 20 questions
- [ ] Verify "Endline" button is enabled
- [ ] Start endline; answer 24 questions including anthropometric data
- [ ] Go offline, complete surveys, verify data persists in Hive
- [ ] Go online; trigger sync via SyncManager.trySync()
- [ ] Verify Appwrite receives all three phase records
- [ ] Check multi-choice answers are stored as comma-separated strings
- [ ] Test that same answer submitted twice doesn't duplicate (409 → update)

---

## Future Enhancements

1. **Sync Conflict UI** – Show user which jobs failed and allow manual retry
2. **Offline Indicator** – Badge on child list showing "synced/pending"
3. **Analytics Dashboard** – Compare baseline↔endline metrics across cohorts
4. **Re-do Phases** – Allow field workers to redo survey if initial data was incorrect
5. **Signature/Photo Capture** – Add to endline for accountability
6. **Real-time Sync Progress** – Show a progress bar as Appwrite updates process

---

## Files Modified

1. [lib/services/appwrite_service.dart](lib/services/appwrite_service.dart) – Fixed ensureSession
2. [lib/utils/constants.dart](lib/utils/constants.dart) – Added phase constants
3. [lib/services/question_service.dart](lib/services/question_service.dart) – Generic phase support
4. [lib/screens/visits/baseline_visit_screen.dart](lib/screens/visits/baseline_visit_screen.dart) – Phase-aware + multi-choice
5. [lib/services/child_service.dart](lib/services/child_service.dart) – Three phase status fields + new methods
6. [lib/services/visit_service.dart](lib/services/visit_service.dart) – Multi-choice encoding
7. [lib/services/sync_manager.dart](lib/services/sync_manager.dart) – New sync job types
8. [lib/screens/children/child_list_screen.dart](lib/screens/children/child_list_screen.dart) – Navigation to profile

## Files Created

1. [lib/screens/children/child_profile_screen.dart](lib/screens/children/child_profile_screen.dart) – NEW: Child profile with 3 phase buttons
2. [lib/models/counselling_seeder.dart](lib/models/counselling_seeder.dart) – NEW: Counselling questions
3. [lib/models/endline_seeder.dart](lib/models/endline_seeder.dart) – NEW: Endline questions

---

## Support

For issues or questions:
- Check Hive box contents: `Hive.box('children_local').toMap()`
- Monitor sync queue: `Hive.box('sync_queue').toMap()`
- Verify question bank: `QuestionService.I.getQuestionsForPhase(projectId, phase)`
