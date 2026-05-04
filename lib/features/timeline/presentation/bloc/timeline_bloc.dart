import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/features/tasks/domain/entities/task_entity.dart';
import 'package:pomodoro_tasks/features/timeline/domain/repositories/timeline_repository.dart';
import 'package:pomodoro_tasks/features/timer/domain/entities/pomodoro_session.dart';

part 'timeline_event.dart';
part 'timeline_state.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  final TimelineRepository repository;

  StreamSubscription<PomodoroSession?>? _sessionSub;
  StreamSubscription<List<TaskEntity>>? _tasksSub;

  TimelineBloc({required this.repository}) : super(TimelineInitial()) {
    on<TimelineLoadRequested>(_onLoadRequested);
    on<TimelineSessionUpdated>(_onSessionUpdated);
    on<TimelineTasksUpdated>(_onTasksUpdated);
  }

  @override
  Future<void> close() {
    _sessionSub?.cancel();
    _tasksSub?.cancel();
    return super.close();
  }

  void _onLoadRequested(TimelineLoadRequested event, Emitter<TimelineState> emit) {
    _sessionSub?.cancel();
    _tasksSub?.cancel();

    _sessionSub = repository
        .getPartnerActiveSession(pairId: event.pairId, partnerId: event.partnerId)
        .listen((session) => add(TimelineSessionUpdated(session)));

    _tasksSub = repository
        .getPartnerTasks(pairId: event.pairId, partnerId: event.partnerId)
        .listen((tasks) => add(TimelineTasksUpdated(tasks)));
  }

  void _onSessionUpdated(TimelineSessionUpdated event, Emitter<TimelineState> emit) {
    final current = state;
    if (current is TimelineLoaded) {
      emit(current.copyWith(partnerSession: event.session));
    } else {
      emit(TimelineLoaded(partnerSession: event.session, partnerTasks: const []));
    }
  }

  void _onTasksUpdated(TimelineTasksUpdated event, Emitter<TimelineState> emit) {
    final current = state;
    if (current is TimelineLoaded) {
      emit(current.copyWith(partnerTasks: event.tasks));
    } else {
      emit(TimelineLoaded(partnerTasks: event.tasks));
    }
  }
}
