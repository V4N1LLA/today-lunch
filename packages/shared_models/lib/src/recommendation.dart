import 'place.dart';

class Recommendation {
  const Recommendation({
    required this.place,
    required this.reason,
    required this.generatedAt,
  });

  final Place place;
  final String reason;
  final DateTime generatedAt;
}
