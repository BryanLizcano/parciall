class ServiceItem {
  final String title;
  final String category;
  final String description;
  final String provider;
  final String price;
  final double rating;
  final String imageUrl;
  final String location;
  final bool active;

  const ServiceItem({
    required this.title,
    required this.category,
    required this.description,
    required this.provider,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.location,
    required this.active,
  });
}
