class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.image,
  });

  final String id;
  final String title;
  final double price;
  final String location;
  final String image;
}
