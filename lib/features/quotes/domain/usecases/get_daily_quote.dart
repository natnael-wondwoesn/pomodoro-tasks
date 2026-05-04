import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/core/usecases/usecase.dart';
import 'package:pomodoro_tasks/features/quotes/domain/entities/quote.dart';
import 'package:pomodoro_tasks/features/quotes/domain/repositories/quotes_repository.dart';

class GetDailyQuote implements UseCase<Quote, GetDailyQuoteParams> {
  final QuotesRepository repository;

  GetDailyQuote(this.repository);

  @override
  Future<Either<Failure, Quote>> call(GetDailyQuoteParams params) {
    return repository.getDailyQuote(language: params.language);
  }
}

class GetDailyQuoteParams {
  final String language;

  const GetDailyQuoteParams({this.language = 'en'});
}
