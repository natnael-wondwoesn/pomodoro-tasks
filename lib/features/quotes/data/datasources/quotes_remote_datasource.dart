import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_tasks/features/quotes/domain/entities/quote.dart';

abstract class QuotesRemoteDatasource {
  Future<Quote> getDailyQuote({String language = 'en'});
  Future<List<Quote>> browseQuotes({String? category, String language = 'en'});
}

class QuotesRemoteDatasourceImpl implements QuotesRemoteDatasource {
  final SharedPreferences preferences;

  static const _dailyQuoteKey = 'daily_quote';
  static const _dailyQuoteDateKey = 'daily_quote_date';

  // Curated Bible verses for daily quotes (seeded by date)
  static const List<Map<String, String>> _curatedVerses = [
    {'text': 'For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.', 'ref': 'Jeremiah 29:11'},
    {'text': 'Commit your work to the Lord, and your plans will be established.', 'ref': 'Proverbs 16:3'},
    {'text': 'Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.', 'ref': 'Joshua 1:9'},
    {'text': 'I can do all things through Christ who strengthens me.', 'ref': 'Philippians 4:13'},
    {'text': 'Trust in the Lord with all your heart and lean not on your own understanding.', 'ref': 'Proverbs 3:5'},
    {'text': 'The Lord is my shepherd; I shall not want.', 'ref': 'Psalm 23:1'},
    {'text': 'But those who hope in the Lord will renew their strength. They will soar on wings like eagles.', 'ref': 'Isaiah 40:31'},
    {'text': 'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.', 'ref': 'Philippians 4:6'},
    {'text': 'And we know that in all things God works for the good of those who love him.', 'ref': 'Romans 8:28'},
    {'text': 'The Lord bless you and keep you; the Lord make his face shine on you and be gracious to you.', 'ref': 'Numbers 6:24-25'},
    {'text': 'Whatever you do, work at it with all your heart, as working for the Lord, not for human masters.', 'ref': 'Colossians 3:23'},
    {'text': 'Be still, and know that I am God.', 'ref': 'Psalm 46:10'},
    {'text': 'The joy of the Lord is your strength.', 'ref': 'Nehemiah 8:10'},
    {'text': 'Let us not become weary in doing good, for at the proper time we will reap a harvest if we do not give up.', 'ref': 'Galatians 6:9'},
    {'text': 'Delight yourself in the Lord, and he will give you the desires of your heart.', 'ref': 'Psalm 37:4'},
    {'text': 'He gives strength to the weary and increases the power of the weak.', 'ref': 'Isaiah 40:29'},
    {'text': 'Cast all your anxiety on him because he cares for you.', 'ref': '1 Peter 5:7'},
    {'text': 'This is the day the Lord has made; let us rejoice and be glad in it.', 'ref': 'Psalm 118:24'},
    {'text': 'For God has not given us a spirit of fear, but of power and of love and of a sound mind.', 'ref': '2 Timothy 1:7'},
    {'text': 'The Lord is near to all who call on him, to all who call on him in truth.', 'ref': 'Psalm 145:18'},
    {'text': 'Have I not commanded you? Be strong and courageous. Do not be afraid; do not be discouraged.', 'ref': 'Joshua 1:9'},
    {'text': 'Great is his faithfulness; his mercies begin afresh each morning.', 'ref': 'Lamentations 3:23'},
    {'text': 'Come to me, all who are weary and burdened, and I will give you rest.', 'ref': 'Matthew 11:28'},
    {'text': 'He who began a good work in you will carry it on to completion until the day of Christ Jesus.', 'ref': 'Philippians 1:6'},
    {'text': 'The Lord your God is with you, the Mighty Warrior who saves. He will take great delight in you.', 'ref': 'Zephaniah 3:17'},
    {'text': 'In their hearts humans plan their course, but the Lord establishes their steps.', 'ref': 'Proverbs 16:9'},
    {'text': 'Peace I leave with you; my peace I give you. I do not give to you as the world gives.', 'ref': 'John 14:27'},
    {'text': 'The name of the Lord is a fortified tower; the righteous run to it and are safe.', 'ref': 'Proverbs 18:10'},
    {'text': 'Wait for the Lord; be strong and take heart and wait for the Lord.', 'ref': 'Psalm 27:14'},
    {'text': 'If God is for us, who can be against us?', 'ref': 'Romans 8:31'},
    {'text': 'Every good and perfect gift is from above, coming down from the Father of the heavenly lights.', 'ref': 'James 1:17'},
  ];

  QuotesRemoteDatasourceImpl({required this.preferences});

  @override
  Future<Quote> getDailyQuote({String language = 'en'}) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final cachedDate = preferences.getString(_dailyQuoteDateKey);

    if (cachedDate == today) {
      final cached = preferences.getString(_dailyQuoteKey);
      if (cached != null) {
        final data = jsonDecode(cached);
        return Quote(
          text: data['text'],
          reference: data['reference'],
          language: data['language'] ?? 'en',
        );
      }
    }

    // Use date as seed for consistent daily quote
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final index = dayOfYear % _curatedVerses.length;
    final verse = _curatedVerses[index];

    final quote = Quote(
      text: verse['text']!,
      reference: verse['ref']!,
      language: language,
    );

    // Cache it
    await preferences.setString(_dailyQuoteDateKey, today);
    await preferences.setString(_dailyQuoteKey, jsonEncode({
      'text': quote.text,
      'reference': quote.reference,
      'language': quote.language,
    }));

    return quote;
  }

  @override
  Future<List<Quote>> browseQuotes({String? category, String language = 'en'}) async {
    // For now, return curated list. Can be replaced with API call later.
    return _curatedVerses
        .map((v) => Quote(text: v['text']!, reference: v['ref']!, language: language))
        .toList();
  }
}
