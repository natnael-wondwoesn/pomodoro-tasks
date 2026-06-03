# Big Features Design — Spec 3

## Feature 1: Shared Calendar (Simple Events)

### Concept
Create shared events (date nights, appointments, milestones). Both partners see all events. Reminders via local notifications.

### Data Model
Firestore: `/pairs/{pairId}/events/{eventId}`

```
{
  title: string,
  description: string?,
  dateTime: timestamp,
  category: string (dateNight, appointment, milestone, other),
  createdBy: string (userId),
  createdAt: timestamp,
  reminderMinutesBefore: int? (null = no reminder)
}
```

### UI
- New tab? No — accessible from Home via a calendar icon button in the app bar, opens as pushed page
- Event list view sorted by date (upcoming first)
- FAB to add new event
- Event card shows: emoji by category, title, date/time, countdown ("in 3 days")
- Tap event to see details / delete
- Category emojis: dateNight=💑, appointment=📋, milestone=⭐, other=📌

### Architecture
- `lib/features/calendar/` — full feature directory
- Domain: `SharedEvent` entity
- Data: `SharedEventModel` with Firestore serialization
- Presentation: `CalendarPage` (event list), `AddEventSheet` (bottom sheet form)
- Schedule local notification via NotificationService when reminder is set

## Feature 2: Memory Timeline (Manual)

### Concept
Shared journal of memories. Add a note with optional photo and date. Displayed as a vertical timeline.

### Data Model
Firestore: `/pairs/{pairId}/memories/{memoryId}`

```
{
  title: string,
  note: string?,
  imageUrl: string?,
  date: timestamp,
  createdBy: string (userId),
  createdAt: timestamp
}
```

### UI
- Accessible from Home via a heart/book icon in the app bar, opens as pushed page
- Vertical timeline with date headers
- Memory card: photo (if any), title, note preview, date
- FAB to add memory (title, note, optional photo upload, date picker)
- Empty state: "No memories yet — capture your first moment together!"

### Architecture
- `lib/features/memories/` — full feature directory
- Reuses existing Firebase Storage upload pattern from canvas feature
- Domain: `Memory` entity
- Data: `MemoryModel` with Firestore serialization
- Presentation: `MemoryTimelinePage`, `AddMemorySheet`

## Feature 3: Date Night Ideas (Curated Pool)

### Concept
Browse or get random date ideas from a categorized pool. Save favorites.

### Categories & Ideas
- Adventure (hiking, road trip, stargazing, escape room, bike ride...)
- Cozy (movie marathon, cook together, puzzle night, board games, blanket fort...)
- Creative (paint night, pottery, write letters, scrapbook, learn a dance...)
- Foodie (try a new cuisine, bake together, picnic, food truck tour, breakfast for dinner...)
- Free (sunset walk, park visit, home spa, photo walk, volunteer together...)

50+ ideas total, hardcoded.

### UI
- Accessible from Home via a lightbulb icon in the app bar OR from a card on home page
- Main view: "Get a Random Idea" button (big, fun, gradient) + category filter chips
- Idea card: emoji, title, short description, category tag
- Tap heart to save as favorite
- Saved favorites tab at top
- Saved favorites stored in Firestore: `/pairs/{pairId}/savedDateIdeas/{ideaId}`

### Architecture
- `lib/features/date_ideas/` — lightweight feature
- `lib/core/data/date_ideas_pool.dart` — hardcoded pool
- Presentation: `DateIdeasPage`, idea card widget
- Minimal data layer (just favorites in Firestore)

## Feature 4: Couple Quizzes (Multiple)

### Quizzes
1. **Love Languages** — 15 questions, determines primary love language (Words of Affirmation, Acts of Service, Receiving Gifts, Quality Time, Physical Touch)
2. **Communication Style** — 10 questions (Direct, Diplomatic, Analytical, Expressive)
3. **Conflict Style** — 10 questions (Compromiser, Avoider, Competitor, Collaborator, Accommodator)
4. **Fun Compatibility** — 12 questions (light-hearted preferences: morning/night, plan/spontaneous, etc.)

### Data Model
Firestore: `/pairs/{pairId}/quizResults/{quizId}`

```
{
  quizId: string,
  results: {
    [userId]: {
      answers: List<int>,
      result: string (e.g. "Quality Time"),
      completedAt: timestamp
    }
  }
}
```

### UI
- Accessible from Home via a quiz/brain icon, opens as pushed page
- Quiz list: cards showing quiz name, description, completion status for each partner
- Quiz flow: one question at a time, progress bar, select answer
- Results page: both partners' results side by side with descriptions
- If partner hasn't taken quiz yet: "Waiting for Partner" state

### Architecture
- `lib/features/quizzes/` — full feature directory
- `lib/core/data/quiz_pool.dart` — all quiz data hardcoded
- Domain: `QuizResult` entity
- Presentation: `QuizListPage`, `QuizFlowPage`, `QuizResultsPage`

## Navigation Update
These 4 features are accessed from the Home page app bar. Add a row of icon buttons or an overflow menu:
- Calendar icon → CalendarPage
- Heart/book icon → MemoryTimelinePage
- Lightbulb icon → DateIdeasPage
- Brain/quiz icon → QuizListPage

Alternative: Add a "More" section on the home page with cards linking to each feature.

## Files to Create
```
lib/features/calendar/domain/entities/shared_event.dart
lib/features/calendar/data/models/shared_event_model.dart
lib/features/calendar/presentation/pages/calendar_page.dart

lib/features/memories/domain/entities/memory.dart
lib/features/memories/data/models/memory_model.dart
lib/features/memories/presentation/pages/memory_timeline_page.dart

lib/core/data/date_ideas_pool.dart
lib/features/date_ideas/presentation/pages/date_ideas_page.dart

lib/core/data/quiz_pool.dart
lib/features/quizzes/domain/entities/quiz_result.dart
lib/features/quizzes/data/models/quiz_result_model.dart
lib/features/quizzes/presentation/pages/quiz_list_page.dart
lib/features/quizzes/presentation/pages/quiz_flow_page.dart
lib/features/quizzes/presentation/pages/quiz_results_page.dart
```
