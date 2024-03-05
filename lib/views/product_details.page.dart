import 'package:admin_app/routes/app_routes.dart';
import 'package:admin_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class ProductDetailsPage extends StatefulWidget {
  String productName;
  String productPrice;
  String showProductPrice;
  String productImageUrl;
  String category;
  String description;
  String weight;
  String stock;
  int quantity;
  String id;
  String itemType;

  ProductDetailsPage({
    required this.productName,
    required this.productPrice,
    required this.showProductPrice,
    required this.productImageUrl,
    required this.category,
    required this.description,
    required this.weight,
    required this.stock,
    required this.quantity,
    required this.id,
    required this.itemType,
  });

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 0;

  @override
  void initState() {
    super.initState();
    if (int.parse(widget.stock) <= 0) {
      quantity = 0;
    } else {
      quantity = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final titleText = widget.category;

    final totalPrice = double.parse(widget.productPrice) * quantity;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          titleText,
          style: TextStyle(
            color: const Color(0xFF050404).withOpacity(0.9),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: const Color(0xFF050404).withOpacity(0.8),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.black,
            height: 0.2,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF050404),
                    width: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.productImageUrl,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  widget.productName,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Description:",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
                    children: [
                      Text(
                        "Price: ",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        "₱${widget.showProductPrice}",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFd41111).withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                widget.description,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              if (widget.category != "Accessories")
                Row(
                  children: [
                    Text(
                      "Weight: ",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${widget.weight} kg.",
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 175,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: const Color(0xFF050404).withOpacity(0.8),
                width: 0.2,
              ),
            ),
          ),
          child: BottomAppBar(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Stock Available: ",
                            style: TextStyle(
                              color: const Color(0xFF050404).withOpacity(0.8),
                            ),
                          ),
                          Text(
                            widget.stock,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF050404).withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: 30,
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFF050404).withOpacity(0.8),
                                width: 0.8,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.remove, size: 15),
                              onPressed: () {
                                setState(() {
                                  if (quantity > 1) {
                                    quantity--;
                                  }
                                });
                              },
                              color: const Color(0xFF050404).withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "$quantity",
                            style: TextStyle(
                              fontSize: 18,
                              color: const Color(0xFF050404).withOpacity(0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            height: 30,
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFF050404).withOpacity(0.8),
                                width: 0.8,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add, size: 15),
                              onPressed: () {
                                setState(() {
                                  if (quantity < int.parse(widget.stock)) {
                                    quantity++;
                                  }
                                });
                              },
                              color: const Color(0xFF050404).withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Price: ",
                        style: TextStyle(
                          fontSize: 18,
                          color: const Color(0xFF050404).withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        totalPrice % 1 == 0
                            ? '₱${totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}'
                            : totalPrice.toStringAsFixed(
                                        totalPrice.truncateToDouble() ==
                                                totalPrice
                                            ? 0
                                            : 2) ==
                                    totalPrice.toStringAsFixed(0)
                                ? '₱${totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}'
                                : '₱${totalPrice.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}',
                        style: TextStyle(
                          fontSize: 18,
                          color: const Color(0xFFd41111).withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: CartButton(
                      onPressed: quantity > 0
                          ? () {
                              if (quantity > 0) {
                                cartProvider.addToCart(
                                  cartItem: CartItem(
                                    id: widget.id,
                                    name: widget.productName,
                                    description: widget.description,
                                    category: widget.category,
                                    weight: widget.weight,
                                    customerPrice:
                                        double.parse(widget.productPrice),
                                    quantity: quantity,
                                    imageUrl: widget.productImageUrl,
                                    stock: int.parse(widget.stock),
                                    itemType: widget.itemType,
                                  ),
                                  context: context,
                                );
                              }
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Product is out of stock.'),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                      text: 'Add to Cart',
                      height: 50,
                      width: 220,
                      fontz: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
