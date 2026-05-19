class AppConstants {
  AppConstants._();

  // Pomodoro defaults
  static const int defaultWorkDuration = 25;
  static const int defaultShortBreakDuration = 5;
  static const int defaultLongBreakDuration = 15;
  static const int defaultRoundsBeforeLongBreak = 4;

  // Firestore collections
  static const String usersCollection = 'users';
  static const String pairsCollection = 'pairs';
  static const String tasksCollection = 'tasks';
  static const String sessionsCollection = 'sessions';
  static const String dailySchedulesCollection = 'daily_schedules';
  static const String canvasesCollection = 'canvases';
  static const String strokesCollection = 'strokes';

  // Pair code
  static const int pairCodeLength = 6;

  // Quotes cache
  static const int maxCachedQuotes = 30;
}
