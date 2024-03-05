import 'dart:convert';
import 'package:admin_app/routes/app_routes.dart';
import 'package:admin_app/widgets/checkout_cart.dart';
import 'package:admin_app/widgets/custom_button.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'user_provider.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<Map<String, dynamic>> userData;
  bool isDiscountApplied = false;

  @override
  void initState() {
    super.initState();
    final String? userId =
        Provider.of<UserProvider>(context, listen: false).userId;
    userData = fetchUserData(userId);
  }

  Future<Map<String, dynamic>> fetchUserData(String? userId) async {
    try {
      final response = await http.get(
          Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/users/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        print('User ID: $userId');
        print('Response Body: $userData');
        return userData;
      } else {
        print('Failed to load user data. Status code: ${response.statusCode}');
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      print('Error: $error');
      throw error;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Cart",
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart_rounded),
            onPressed: () {
              Navigator.pushReplacementNamed(context, walkinRoute);
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Consumer2<CartProvider, UserProvider>(
        builder: (context, cartProvider, userProvider, child) {
          String? userId = userProvider.userId;
          print('User ID: $userId');
          List<CartItem> cartItems = cartProvider.cartItems;

          double calculateTotalPrice() {
            double totalPrice = 0.0;
            for (var cartItem in cartItems) {
              if (cartItem.isSelected) {
                totalPrice += cartItem.customerPrice * cartItem.quantity;
              }
            }
            return totalPrice;
          }

          return FutureBuilder<Map<String, dynamic>>(
            future: userData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: LoadingAnimationWidget.flickr(
                    leftDotColor: const Color(0xFF050404).withOpacity(0.8),
                    rightDotColor: const Color(0xFFd41111).withOpacity(0.8),
                    size: 40,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                Map<String, dynamic> userData = snapshot.data!;
                print('User ID: $userId');

                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 5, 5),
                      child: SizedBox(
                        height: 20,
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: cartItems.length,
                        separatorBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(),
                        ),
                        itemBuilder: (context, index) {
                          return CartItemWidget(cartItem: cartItems[index]);
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(
                            color: const Color(0xFF050404).withOpacity(0.8),
                            width: 0.2,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Selected Item${cartItems.where((item) => item.isSelected).length > 1 ? 's' : ''}: (${cartItems.where((item) => item.isSelected).length})",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF050404).withOpacity(0.8),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total Price:",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF050404)
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                    Text(
                                      calculateTotalPrice() % 1 == 0
                                          ? '₱${calculateTotalPrice().toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}'
                                          : '₱${calculateTotalPrice().toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: const Color(0xFFd41111)
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                Center(
                                  child: CartButton(
                                    onPressed: cartItems.isNotEmpty
                                        ? () {
                                            Navigator.pushNamed(
                                                context, setDeliveryPage);
                                          }
                                        : null,
                                    text: 'Checkout',
                                    height: 50,
                                    width: 220,
                                    fontz: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }
}
