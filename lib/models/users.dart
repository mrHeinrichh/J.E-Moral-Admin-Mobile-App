class User {
  final String name;
  final String contactNumber;
  final String address;
  final bool verified;
  final bool discounted;
  final String type;
  final String discountIdImage;
  final String email;
  final String password;
  final String image;
  final String gcash;

  final String gcashQr;

  final String license;
  final String seminarCert;

  User({
    required this.name,
    required this.contactNumber,
    required this.address,
    required this.verified,
    required this.discounted,
    required this.type,
    required this.discountIdImage,
    required this.email,
    required this.password,
    required this.image,
    required this.gcash,
    required this.gcashQr,
    required this.license,
    required this.seminarCert,
  });
}

class Customer {
  final String id;
  final String name;
  final String contactNumber;
  final String address;
  final bool verified;
  final bool discounted;
  final String type;
  final String discountIdImage;
  final String email;
  final String password;
  final String image;

  Customer({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.address,
    required this.verified,
    required this.discounted,
    required this.type,
    required this.discountIdImage,
    required this.email,
    required this.password,
    required this.image,
  });

  // Factory method to create a Customer object from a JSON map
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['_id'],
      name: json['name'],
      contactNumber: json['contactNumber'],
      address: json['address'],
      verified: json['verified'],
      discounted: json['discounted'],
      type: json['__t'],
      discountIdImage: json['discountIdImage'],
      email: json['email'],
      password: json['password'],
      image: json['image'],
    );
  }

  // Convert a Customer object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'contactNumber': contactNumber,
      'address': address,
      'verified': verified,
      'discounted': discounted,
      '__t': type,
      'discountIdImage': discountIdImage,
      'email': email,
      'password': password,
      'image': image,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'contactNumber': contactNumber,
      'address': address,
      'verified': verified,
      'discounted': discounted,
      '__t': type,
      'discountIdImage': discountIdImage,
      'email': email,
      'password': password,
      'image': image,
    };
  }
}
