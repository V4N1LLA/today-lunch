class NearbySearchCriteria {
  const NearbySearchCriteria({
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.category,
  });

  final double latitude;
  final double longitude;
  final int radiusMeters;
  final String? category;
}
