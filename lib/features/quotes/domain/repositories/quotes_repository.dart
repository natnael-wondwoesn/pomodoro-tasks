import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/features/quotes/domain/entities/quote.dart';

abstract class QuotesRepository {
  Future<Either<Failure, Quote>> getDailyQuote({String language = 'en'});
  Future<Either<Failure, List<Quote>>> browseQuotes({
    String? category,
    String language = 'en',
  });
}
