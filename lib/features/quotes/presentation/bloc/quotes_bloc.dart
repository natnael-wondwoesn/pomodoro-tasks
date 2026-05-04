import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro_tasks/features/quotes/domain/entities/quote.dart';
import 'package:pomodoro_tasks/features/quotes/domain/usecases/get_daily_quote.dart';

part 'quotes_event.dart';
part 'quotes_state.dart';

class QuotesBloc extends Bloc<QuotesEvent, QuotesState> {
  final GetDailyQuote getDailyQuote;

  QuotesBloc({required this.getDailyQuote}) : super(QuotesInitial()) {
    on<QuotesLoadDaily>(_onLoadDaily);
    on<QuotesRefresh>(_onRefresh);
  }

  Future<void> _onLoadDaily(QuotesLoadDaily event, Emitter<QuotesState> emit) async {
    emit(QuotesLoading());
    final result = await getDailyQuote(GetDailyQuoteParams(language: event.language));
    result.fold(
      (failure) => emit(QuotesError(failure.message)),
      (quote) => emit(QuotesLoaded(quote)),
    );
  }

  Future<void> _onRefresh(QuotesRefresh event, Emitter<QuotesState> emit) async {
    final result = await getDailyQuote(GetDailyQuoteParams(language: event.language));
    result.fold(
      (failure) => emit(QuotesError(failure.message)),
      (quote) => emit(QuotesLoaded(quote)),
    );
  }
}
