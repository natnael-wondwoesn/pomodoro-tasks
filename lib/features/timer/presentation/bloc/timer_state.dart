part of 'timer_bloc.dart';

class TimerBlocState extends Equatable {
  final TimerStateEntity timerState;

  const TimerBlocState({required this.timerState});

  factory TimerBlocState.initial() {
    return const TimerBlocState(
      timerState: TimerStateEntity(
        remaining: Duration(minutes: 25),
        total: Duration(minutes: 25),
      ),
    );
  }

  TimerBlocState copyWith({TimerStateEntity? timerState}) {
    return TimerBlocState(timerState: timerState ?? this.timerState);
  }

  @override
  List<Object?> get props => [timerState];
}
