class ProductItem {
  final String name;
  final String imageUrl;
  final String categoryLabel;
  final String categoryEmoji;
  final String? brandName;
  final String description;

  ProductItem({
    required this.name,
    required this.imageUrl,
    required this.categoryLabel,
    required this.categoryEmoji,
    this.brandName,
    this.description = '',
  });
}
