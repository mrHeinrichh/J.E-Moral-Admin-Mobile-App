import 'dart:convert';
import 'package:admin_app/routes/app_routes.dart';
import 'package:admin_app/widgets/custom_button.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        // title: const Padding(
        //   padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        //   child: Text(
        //     'Cart',
        //     style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        //   ),
        // ),
        title: const Text('Cart'),
      ),
      body: Consumer2<CartProvider, UserProvider>(
        builder: (context, cartProvider, userProvider, child) {
          String? userId = userProvider.userId;
          print('User ID: $userId');
          List<CartItem> cartItems = cartProvider.cartItems;

          double _calculateTotalPrice() {
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
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                Map<String, dynamic> userData = snapshot.data!;
                print('User ID: $userId');

                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 5, 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: cartItems.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          return CartItemWidget(cartItem: cartItems[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Price:"),
                              Text(
                                "₱${_calculateTotalPrice()}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          CustomizedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, setDeliveryPage);
                            },
                            text: 'Checkout',
                            height: 60,
                            width: 200,
                            fontz: 20,
                          ),
                        ],
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

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        subtitle: IntrinsicHeight(
          child: Row(
            children: [
              Checkbox(
                value: cartItem.isSelected,
                onChanged: (value) {
                  Provider.of<CartProvider>(context, listen: false)
                      .toggleSelection(cartItem);
                },
              ),
              const SizedBox(width: 10), // Add some spacing

              Image.network(
                cartItem.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
              const SizedBox(width: 10), // Add some spacing

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.name,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 5), // Add some vertical spacing
                    Text(
                      '₱${cartItem.customerPrice * cartItem.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5), // Add some vertical spacing

                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            Provider.of<CartProvider>(context, listen: false)
                                .decrementQuantity(cartItem);
                          },
                        ),
                        Text('${cartItem.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            Provider.of<CartProvider>(context, listen: false)
                                .incrementQuantity(cartItem);
                          },
                        ),
                        const Spacer(), // Use Spacer to push the following IconButton to the right
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            Provider.of<CartProvider>(context, listen: false)
                                .removeFromCart(cartItem);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
