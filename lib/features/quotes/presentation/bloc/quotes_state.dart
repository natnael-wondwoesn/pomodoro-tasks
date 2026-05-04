part of 'quotes_bloc.dart';

abstract class QuotesState extends Equatable {
  const QuotesState();

  @override
  List<Object?> get props => [];
}

class QuotesInitial extends QuotesState {}

class QuotesLoading extends QuotesState {}

class QuotesLoaded extends QuotesState {
  final Quote quote;

  const QuotesLoaded(this.quote);

  @override
  List<Object?> get props => [quote];
}

class QuotesError extends QuotesState {
  final String message;

  const QuotesError(this.message);

  @override
  List<Object?> get props => [message];
}
