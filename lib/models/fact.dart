class DailyFact {
  final int year;
  final String text;
  final String? pageTitle;
  final String? thumbnailUrl;
  final DateTime date;

  DailyFact({
    required this.year,
    required this.text,
    required this.date,
    this.pageTitle,
    this.thumbnailUrl,
  });

  /// "3 сентября 1783 года" — красивая подпись под фактом
  String get yearLabel => year > 0 ? '$year год' : '${-year} год до н.э.';

  Map<String, dynamic> toJson() => {
        'year': year,
        'text': text,
        'pageTitle': pageTitle,
        'thumbnailUrl': thumbnailUrl,
        'date': date.toIso8601String(),
      };

  factory DailyFact.fromJson(Map<String, dynamic> json) => DailyFact(
        year: json['year'] as int,
        text: json['text'] as String,
        pageTitle: json['pageTitle'] as String?,
        thumbnailUrl: json['thumbnailUrl'] as String?,
        date: DateTime.parse(json['date'] as String),
      );
}
