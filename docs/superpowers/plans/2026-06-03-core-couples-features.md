# Core Couples Features Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Add Daily Questions (blind reveal), Nudge Notifications, and Streaks/Badges to the couples pomodoro app.

**Architecture:** Three independent features sharing Firestore pair document. Daily Questions gets its own feature directory. Nudges are a lightweight service. Streaks piggyback on existing TimerBloc completion flow.

**Tech Stack:** Flutter, BLoC/StreamBuilder, Firestore, flutter_local_notifications

---

## Task 1: Daily Questions Pool
## Task 2: Daily Question Domain + Data Layer
## Task 3: Daily Question UI (Card + Page)
## Task 4: Nudge Service
## Task 5: Nudge UI (Partner Panel Button)
## Task 6: Streak Data + Update Logic
## Task 7: Streak UI (Home Page Card)
## Task 8: Wire Everything into App Shell + Home
## Task 9: Final Verification
