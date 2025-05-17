// Domain layer entity for Promotions (Placeholder)
class Promotion {
  final String id;
  final String vendorId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;

  Promotion({
    required this.id,
    required this.vendorId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
  });
}
