# Core Couples Features Design

## Feature 1: Daily Questions (Blind Reveal)

### Concept
Each day, both partners get the same question. They answer independently. Once both have answered, answers are revealed simultaneously. Creates daily connection ritual.

### Data Model
Firestore path: `/pairs/{pairId}/dailyQuestions/{dateKey}` (dateKey = YYYY-MM-DD)

```
{
  questionText: string,
  questionId: int,
  answers: {
    [userId]: {
      text: string,
      answeredAt: timestamp
    }
  },
  revealedAt: timestamp | null  // set when both answers exist
}
```

### Question Pool
Hardcoded list of 100+ relationship questions, cycled by day number. Categories: fun, deep, memories, dreams, preferences. Example questions:
- "What's one thing I do that always makes you smile?"
- "If we could travel anywhere tomorrow, where would you pick?"
- "What's a small thing I did recently that meant a lot to you?"
- "What song reminds you of us?"

### UI Flow
1. Home tab shows a card "Today's Question" below the timer section
2. Tap to open full-screen question view
3. User types answer and submits
4. If partner hasn't answered yet: shows "Waiting for Partner..." with a gentle pulse animation
5. Once both answered: reveal animation — both answers slide in side by side
6. Past questions viewable in a scrollable history (last 7 days)

### Architecture
- Domain: `DailyQuestion` entity, `DailyQuestionRepository`
- Data: `DailyQuestionModel`, Firestore datasource (no BLoC — lightweight StreamBuilder)
- Presentation: `DailyQuestionCard` (home widget), `DailyQuestionPage` (full view)

## Feature 2: Nudge Notifications

### Concept
Send partner a push notification with a pre-written message. Mix of playful and sweet.

### Message Pool
Playful:
- "Hey, your pomodoros miss you!"
- "I see someone's taking a looong break..."
- "Race you to the next pomodoro?"
- "Your tasks are getting lonely over here"

Sweet:
- "You've got this! I believe in you"
- "Thinking of you, go crush that task!"
- "Proud of how hard you're working"
- "Sending focus energy your way"

### Implementation
- Button on Home page partner panel: "Send Nudge" icon button
- Writes a nudge doc to Firestore: `/pairs/{pairId}/nudges/{autoId}`
- Cloud Function (or local notification on partner's device via Firestore listener) delivers the notification
- For MVP: use Firestore listener on partner's device — when a new nudge doc appears with `targetUserId == currentUser`, show local notification
- Cooldown: 1 nudge per 30 minutes max (enforced client-side)

### Data Model
```
{
  fromUserId: string,
  targetUserId: string,
  message: string,
  sentAt: timestamp,
  seen: bool
}
```

### Architecture
- No separate feature directory — lives in notification_service.dart + partner_panel.dart
- NudgeService class handles Firestore listener + showing notification
- Cooldown tracked in local state

## Feature 3: Streaks & Badges

### Concept
Individual streaks (each partner) + shared couple streak. Visual display on Home page.

### Streak Logic
- **Individual streak**: User completed >= 1 pomodoro today. Streak increments daily. Missing a day resets to 0.
- **Couple streak**: Both partners completed >= 1 pomodoro on the same day. Shared counter.
- Streak data stored on the pair document for easy access.

### Data Model
Firestore path: `/pairs/{pairId}` (additional fields on existing pair doc)

```
{
  streaks: {
    [userId]: {
      current: int,
      best: int,
      lastActiveDate: string (YYYY-MM-DD)
    },
    couple: {
      current: int,
      best: int,
      lastActiveDate: string (YYYY-MM-DD)
    }
  }
}
```

### Streak Update Trigger
When `endSession` is called with status 'completed' in TimerBloc, update streak in Firestore:
1. Check if lastActiveDate == today → already counted, skip
2. If lastActiveDate == yesterday → increment current streak
3. If lastActiveDate < yesterday → reset current to 1
4. Update best if current > best
5. For couple streak: check if partner also has lastActiveDate == today

### UI
- Home page: streak display below progress strip
- Shows fire emoji + number for individual streak
- Shows heart emoji + number for couple streak
- Best streak shown as small "best: N" label
- Milestone badges at 7, 30, 100 days (just visual celebration, no separate system)

### Architecture
- Domain: `StreakData` entity (simple data class)
- Data: Read/write directly on pair document (no separate collection)
- Presentation: `StreakCard` widget on home page
- Update logic: in `TimerBloc` or dedicated `StreakService`

## Files to Create/Modify

### New Files
- `lib/features/daily_question/` — full feature directory
  - `domain/entities/daily_question.dart`
  - `data/models/daily_question_model.dart`
  - `presentation/widgets/daily_question_card.dart`
  - `presentation/pages/daily_question_page.dart`
- `lib/core/data/daily_questions_pool.dart` — hardcoded question list
- `lib/core/services/nudge_service.dart` — nudge listener + sender
- `lib/features/timer/presentation/widgets/streak_card.dart`

### Modified Files
- `lib/features/timer/presentation/pages/home_page.dart` — add DailyQuestionCard + StreakCard
- `lib/features/timeline/presentation/widgets/partner_panel.dart` — add nudge button
- `lib/core/notifications/notification_service.dart` — add nudge notification channel
- `lib/app_shell.dart` — initialize nudge listener
- `lib/features/timer/presentation/bloc/timer_bloc.dart` — trigger streak update on session complete
