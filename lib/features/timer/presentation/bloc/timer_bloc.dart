import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/core/notifications/notification_service.dart';
import 'package:pomodoro_tasks/core/services/streak_service.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/pomodoro_config.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/timer_state_entity.dart';
import 'package:pomodoro_tasks/features/timer/domain/usecases/start_session.dart';
import 'package:pomodoro_tasks/features/timer/domain/usecases/end_session.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerBlocState> {
  final StartSession startSession;
  final EndSession endSession;

  Timer? _ticker;
  PomodoroConfig _config = const PomodoroConfig();
  String? _currentSessionId;
  String? _userId;
  String? _pairId;

  TimerBloc({
    required this.startSession,
    required this.endSession,
  }) : super(TimerBlocState.initial()) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<TimerTicked>(_onTicked);
    on<TimerConfigUpdated>(_onConfigUpdated);
    on<TimerSkipped>(_onSkipped);
    on<TimerTaskLinked>(_onTaskLinked);
    on<TimerUserSet>(_onUserSet);
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }

  void _onTaskLinked(TimerTaskLinked event, Emitter<TimerBlocState> emit) {
    if (state.timerState.status != TimerStatus.idle) return;
    emit(state.copyWith(
      timerState: state.timerState.copyWith(
        linkedTaskId: event.taskId,
        totalRounds: event.totalRounds,
        currentRound: 1,
      ),
    ));
  }

  void _onUserSet(TimerUserSet event, Emitter<TimerBlocState> emit) {
    _userId = event.userId;
    _pairId = event.pairId;
  }

  void _onConfigUpdated(TimerConfigUpdated event, Emitter<TimerBlocState> emit) {
    _config = event.config;
    if (state.timerState.status == TimerStatus.idle) {
      emit(state.copyWith(
        timerState: state.timerState.copyWith(
          remaining: _config.workDuration,
          total: _config.workDuration,
          totalRounds: _config.roundsBeforeLongBreak,
        ),
      ));
    }
  }

  Future<void> _onStarted(TimerStarted event, Emitter<TimerBlocState> emit) async {
    final duration = _getDurationForType(state.timerState.type);

    emit(state.copyWith(
      timerState: state.timerState.copyWith(
        status: TimerStatus.running,
        remaining: duration,
        total: duration,
      ),
    ));

    // Sync to Firestore
    if (_userId != null && _pairId != null) {
      final result = await startSession(StartSessionParams(
        userId: _userId!,
        pairId: _pairId!,
        type: state.timerState.type,
        duration: duration,
        taskId: event.taskId,
      ));
      result.fold(
        (_) {},
        (session) => _currentSessionId = session.id,
      );
    }

    _startTicker();
  }

  void _onPaused(TimerPaused event, Emitter<TimerBlocState> emit) {
    _ticker?.cancel();
    emit(state.copyWith(
      timerState: state.timerState.copyWith(status: TimerStatus.paused),
    ));
  }

  void _onResumed(TimerResumed event, Emitter<TimerBlocState> emit) {
    emit(state.copyWith(
      timerState: state.timerState.copyWith(status: TimerStatus.running),
    ));
    _startTicker();
  }

  void _onReset(TimerReset event, Emitter<TimerBlocState> emit) {
    _ticker?.cancel();
    _endCurrentSession('cancelled');
    emit(TimerBlocState.initial().copyWith(
      timerState: TimerStateEntity(
        remaining: _config.workDuration,
        total: _config.workDuration,
        totalRounds: _config.roundsBeforeLongBreak,
      ),
    ));
  }

  void _onSkipped(TimerSkipped event, Emitter<TimerBlocState> emit) {
    _ticker?.cancel();
    _endCurrentSession('completed');
    _advanceToNext(emit);
  }

  void _onTicked(TimerTicked event, Emitter<TimerBlocState> emit) {
    final newRemaining = state.timerState.remaining - const Duration(seconds: 1);

    if (newRemaining.inSeconds <= 0) {
      _ticker?.cancel();
      _endCurrentSession('completed');
      _advanceToNext(emit);
    } else {
      emit(state.copyWith(
        timerState: state.timerState.copyWith(remaining: newRemaining),
      ));
    }
  }

  void _advanceToNext(Emitter<TimerBlocState> emit) {
    final current = state.timerState;

    // Notify user that the session completed
    final title = switch (current.type) {
      SessionType.work => 'Focus session complete!',
      SessionType.shortBreak => 'Break is over!',
      SessionType.longBreak => 'Long break is over!',
    };
    final body = switch (current.type) {
      SessionType.work =>
        'Round ${current.currentRound}/${current.totalRounds} done. Time for a break!',
      SessionType.shortBreak => 'Ready to focus again?',
      SessionType.longBreak => 'Recharged! Start a new cycle.',
    };
    NotificationService.instance.showTimerComplete(
      title: title,
      body: body,
    );

    // Update streak on work session completion
    debugPrint('TimerBloc._advanceToNext: type=${current.type} pairId=$_pairId userId=$_userId');
    if (current.type == SessionType.work && _pairId != null && _userId != null) {
      debugPrint('TimerBloc: Recording pomodoro for streak');
      StreakService.instance.recordPomodoroCompleted(
        pairId: _pairId!,
        userId: _userId!,
      );
    }

    SessionType nextType;
    int nextRound = current.currentRound;

    if (current.type == SessionType.work) {
      if (current.currentRound >= _config.roundsBeforeLongBreak) {
        nextType = SessionType.longBreak;
      } else {
        nextType = SessionType.shortBreak;
      }
    } else {
      nextType = SessionType.work;
      if (current.type == SessionType.longBreak) {
        nextRound = 1;
      } else {
        nextRound = current.currentRound + 1;
      }
    }

    final nextDuration = _getDurationForType(nextType);

    emit(state.copyWith(
      timerState: TimerStateEntity(
        status: TimerStatus.idle,
        type: nextType,
        remaining: nextDuration,
        total: nextDuration,
        currentRound: nextRound,
        totalRounds: _config.roundsBeforeLongBreak,
        linkedTaskId: current.linkedTaskId,
      ),
    ));
  }

  Duration _getDurationForType(SessionType type) {
    switch (type) {
      case SessionType.work:
        return _config.workDuration;
      case SessionType.shortBreak:
        return _config.shortBreakDuration;
      case SessionType.longBreak:
        return _config.longBreakDuration;
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      add(TimerTicked());
    });
  }

  Future<void> _endCurrentSession(String status) async {
    if (_currentSessionId != null && _pairId != null) {
      await endSession(EndSessionParams(
        pairId: _pairId!,
        sessionId: _currentSessionId!,
        status: status,
      ));
      _currentSessionId = null;
    }
  }
}
