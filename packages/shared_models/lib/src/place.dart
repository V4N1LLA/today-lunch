class Place {
  const Place({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.distanceMeters,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String category;
  final int distanceMeters;
}
