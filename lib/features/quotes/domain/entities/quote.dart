import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  final String text;
  final String reference;
  final String language;
  final String? category;

  const Quote({
    required this.text,
    required this.reference,
    this.language = 'en',
    this.category,
  });

  @override
  List<Object?> get props => [text, reference, language, category];
}
