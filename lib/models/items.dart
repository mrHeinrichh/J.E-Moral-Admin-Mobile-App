class Product {
  final String name;
  final String category;
  final String description;
  final String weight;
  final String quantity;
  final String customerPrice;
  final String retailerPrice;
  final String image;
  final String type;

  Product({
    required this.name,
    required this.category,
    required this.description,
    required this.weight,
    required this.quantity,
    required this.customerPrice,
    required this.retailerPrice,
    required this.image,
    required this.type,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      category: json['category'],
      description: json['description'],
      weight: json['weight'],
      quantity: json['quantity'],
      customerPrice: json['customerPrice'],
      retailerPrice: json['retailerPrice'],
      image: json['image'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'weight': weight,
      'quantity': quantity,
      'customerPrice': customerPrice,
      'retailerPrice': retailerPrice,
      'image': image,
      'type': type,
    };
  }
}
