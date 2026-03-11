String normalizeCategory(String? category) {
  if (category == null || category.trim().isEmpty) {
    return 'all';
  }

  return category.trim().toLowerCase();
}
