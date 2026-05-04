# Pomodoro Tasks - Shared Accountability App

## Overview

A Flutter macOS app (expandable to mobile) that combines Pomodoro timer, task management, and partner accountability. Two fixed partners can see each other's timelines, current focus status, and upcoming tasks in real-time. Features Bible quotes (English + Amharic) and deep customizability.

## Tech Stack

- **Framework:** Flutter (macOS primary, iOS/Android/web future)
- **Architecture:** Clean Architecture (Domain/Data/Presentation layers)
- **State Management:** BLoC pattern
- **Backend:** Firebase (Spark free tier)
  - Firebase Auth (email/password)
  - Cloud Firestore (real-time sync)
  - Firestore offline persistence
- **Local Storage:** Hive (quotes cache, settings)
- **DI:** get_it + injectable
- **Error Handling:** Either type (fpdart)

## Architecture

### Project Structure

```
lib/
  core/
    error/             - failures, exceptions
    usecases/          - base UseCase class
    theme/             - design system, gradient tokens, customizable themes
    constants/         - app-wide constants

  features/
    auth/
      domain/          - entities (User), repos (abstract), usecases
      data/            - Firebase Auth implementation, models
      presentation/    - AuthBloc, login/signup/pairing pages

    timer/
      domain/          - entities (PomodoroSession, TimerConfig), usecases
      data/            - local timer logic, Firestore session sync
      presentation/    - TimerBloc, timer UI, circular progress animations

    tasks/
      domain/          - entities (Task, TaskList), usecases (CRUD, reorder)
      data/            - Firestore repository implementation
      presentation/    - TasksBloc, task list UI, drag-to-reorder

    timeline/
      domain/          - entities (DaySchedule, PartnerActivity)
      data/            - Firestore streams for partner data
      presentation/    - TimelineBloc, shared day view, stats

    quotes/
      domain/          - entities (Quote, QuoteSource), usecases
      data/            - English API + Amharic API adapters (pluggable)
      presentation/    - QuotesBloc, quote card, browse/refresh UI

    settings/
      domain/          - entities (AppSettings, TimerPrefs, ThemePrefs)
      data/            - Hive local storage + Firestore user settings
      presentation/    - SettingsBloc, settings pages

  injection_container.dart  - dependency injection setup
  main.dart
```

### Key Patterns

- Domain layer is pure Dart (no Flutter/Firebase imports)
- Data layer implements abstract repository contracts from domain
- Presentation uses BLoC, emitting states that UI reacts to
- Either<Failure, T> for all usecase return types
- Repository pattern with pluggable implementations (especially for quotes)

## Data Model

### Firestore Structure

```
users/
  {userId}/
    email, displayName, partnerId, createdAt
    settings/ (subcollection)
      preferences -> timer config, theme, quote prefs

pairs/
  {pairId}/
    user1Id, user2Id, createdAt, pairCode

    tasks/ (subcollection)
      {taskId}/
        title, description, estimatedPomodoros, completedPomodoros
        status: todo | in_progress | done
        ownerId, createdAt, order

    sessions/ (subcollection)
      {sessionId}/
        userId, taskId, type: work | short_break | long_break
        startedAt, duration, completedAt, status: active | completed | cancelled

    daily_schedules/ (subcollection)
      {date}/
        {userId}/
          plannedTasks[], completedTasks[], totalFocusMinutes
```

### Security Rules

- Only paired users can read/write their pair document and subcollections
- Users can only modify their own tasks and sessions
- Settings are per-user only

### Pairing Flow

1. User A signs up -> app generates a 6-digit pair code
2. User B signs up -> enters pair code
3. System creates pairs/ document linking both users
4. Pairing is permanent (no re-pairing needed)

## Timer Engine

### Modes

- **Classic:** 25min work, 5min short break, 15min long break, 4 rounds per cycle
- **Flexible:** User-defined durations, same cycle logic
- **Task-linked:** Timer auto-advances through tasks based on estimated pomodoros

### Domain Entities

```
PomodoroConfig:
  workDuration (default 25min)
  shortBreakDuration (default 5min)
  longBreakDuration (default 15min)
  roundsBeforeLongBreak (default 4)
  mode: classic | flexible | task_linked

TimerState:
  status: idle | running | paused
  type: work | short_break | long_break
  remaining: Duration
  currentRound: 1-4
  linkedTaskId: nullable
```

### Sync Behavior

- Session start/end writes to pairs/{pairId}/sessions/
- Partner's TimelineBloc listens to that collection for real-time status
- Timer runs locally (not server-dependent); Firestore sync is fire-and-forget
- Partner sees: "Nate is focusing - 18 min left"

## Bible Quotes System

### Architecture (Pluggable Sources)

```dart
abstract class QuoteRepository {
  Future<Either<Failure, Quote>> getDailyQuote(String language);
  Future<Either<Failure, List<Quote>>> browseQuotes({category, language});
}

// Two implementations:
// - EnglishQuoteRepository (free API like bible-api.com)
// - AmharicQuoteRepository (user's existing Amharic Bible API)
```

### Display Logic

- **Daily featured quote:** Fetched once/day, cached locally, seeded by date (same for both users)
- **Browse/refresh:** Swipe or tap for more quotes
- **Categories:** Motivation, peace, wisdom, perseverance, gratitude
- **Language toggle:** English / Amharic, switchable in settings
- **Offline cache:** Last 30 quotes stored locally via Hive

### Placement

Always visible at top of main screen (above timer). Subtle warm-toned card with verse reference. Persists across all tabs except Settings.

## UI/UX Design

### Layout: Split Dashboard

Two-column main view:
- **Left column:** Timer (circular progress) + current task + my task list
- **Right column:** Partner's live status + their upcoming tasks + day timeline

### Visual Style: Warm & Cozy with Gradient Utilities

```
Colors:
  background:      linear-gradient(135deg, #f5e6d3, #fdf2e9)
  surface:         rgba(255,255,255,0.6) with subtle gradient overlays
  primary:         #c47f52 (warm amber)
  text-primary:    #5a3e2b (deep brown)
  text-secondary:  #8b6f47 (muted brown)
  accent:          linear-gradient(135deg, #c47f52, #d4956a)
  partner:         #7b9e6b (sage green)

Gradient tokens (per state):
  focus-gradient:   linear-gradient(135deg, rgba(196,127,82,0.2), rgba(212,149,106,0.1))
  break-gradient:   linear-gradient(135deg, rgba(123,158,107,0.2), rgba(123,158,107,0.1))
  surface-gradient: linear-gradient(135deg, rgba(255,255,255,0.7), rgba(255,255,255,0.4))
  timer-ring:       conic gradient with amber fill

Dark mode:
  background:      linear-gradient(135deg, #2c1f14, #1a1208)
  surface:         rgba(255,255,255,0.06)
  primary:         #d4956a (lighter amber)
  text-primary:    #f0e6d3

Typography:
  headings:        Georgia / serif
  body:            System default (SF Pro on macOS, Roboto on Android)
  quotes:          Georgia italic

Shapes:
  border-radius:   10-12px
  shadows:         subtle, warm-toned
```

### Navigation

Bottom nav bar (mobile) / sidebar (desktop):
- **Home** - Split dashboard (timer + partner)
- **Tasks** - Full task management (add/edit/delete, drag reorder, filters)
- **Together** - Expanded partner view (full day timeline, shared stats)
- **Settings** - All customization options

Behavior:
- Quote card persists across Home, Tasks, Together tabs
- Timer continues across all screens (mini indicator in nav when not on Home)
- Partner status dot in nav bar (green/amber/grey)

### Screens

1. **Home (Split Dashboard)** - Default view, timer + tasks left, partner right
2. **Tasks** - Full CRUD, drag reorder, estimated pomodoros, filters (today/upcoming/done)
3. **Together** - Partner's full day timeline, completed tasks, shared focus stats
4. **Settings** - Profile, timer prefs, theme, quotes, notifications, pairing
5. **Auth** - Sign in, sign up, pair with partner (enter/show code)

## Customization Options

- **Theme mode:** Light (warm default) / Dark (deep brown) / System
- **Accent color:** 8 preset warm tones or custom picker
- **Font size:** Small / Medium / Large
- **Layout density:** Compact / Comfortable / Spacious
- **Timer style:** Circular progress / Linear bar / Minimal digits
- **Sound:** Selectable notification sounds for work end / break end (or silent)
- **Preset palettes:** Warm Default, Dark Warm, Forest, Ocean
- **Custom gradients:** Users can tweak individual gradient stops

All preferences stored locally (Hive) + synced to Firestore user settings.

## Constraints

- **Entirely free:** Firebase Spark plan only (50K reads/20K writes per day, 1GB storage)
- **Two users:** Fixed pair, connected once during setup
- **Offline-first:** Timer and cached data work without internet; syncs when reconnected
- **macOS primary:** Flutter desktop, but architecture supports future mobile/web expansion
