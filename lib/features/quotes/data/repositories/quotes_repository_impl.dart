import 'package:fpdart/fpdart.dart';
import 'package:pomodoro_tasks/core/error/failures.dart';
import 'package:pomodoro_tasks/features/quotes/data/datasources/quotes_remote_datasource.dart';
import 'package:pomodoro_tasks/features/quotes/domain/entities/quote.dart';
import 'package:pomodoro_tasks/features/quotes/domain/repositories/quotes_repository.dart';

class QuotesRepositoryImpl implements QuotesRepository {
  final QuotesRemoteDatasource remoteDatasource;

  QuotesRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, Quote>> getDailyQuote({String language = 'en'}) async {
    try {
      final quote = await remoteDatasource.getDailyQuote(language: language);
      return Right(quote);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Quote>>> browseQuotes({
    String? category,
    String language = 'en',
  }) async {
    try {
      final quotes = await remoteDatasource.browseQuotes(
        category: category,
        language: language,
      );
      return Right(quotes);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
