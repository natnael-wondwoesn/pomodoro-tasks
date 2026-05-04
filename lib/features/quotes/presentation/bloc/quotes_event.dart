part of 'quotes_bloc.dart';

abstract class QuotesEvent extends Equatable {
  const QuotesEvent();

  @override
  List<Object?> get props => [];
}

class QuotesLoadDaily extends QuotesEvent {
  final String language;

  const QuotesLoadDaily({this.language = 'en'});

  @override
  List<Object?> get props => [language];
}

class QuotesRefresh extends QuotesEvent {
  final String language;

  const QuotesRefresh({this.language = 'en'});

  @override
  List<Object?> get props => [language];
}
