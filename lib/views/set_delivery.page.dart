import 'package:admin_app/routes/app_routes.dart';
import 'package:admin_app/views/cart_provider.dart';
import 'package:admin_app/widgets/custom_button.dart';
import 'package:admin_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class SetDeliveryPage extends StatefulWidget {
  @override
  _SetDeliveryPageState createState() => _SetDeliveryPageState();
}

DateTime? selectedDateTime;

bool isDiscounted = false;

class _SetDeliveryPageState extends State<SetDeliveryPage> {
  List<String> searchResults = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();

  List<Map<String, dynamic>> convertCartItems(List<CartItem> cartItems) {
    List<Map<String, dynamic>> itemsList = [];
    for (var cartItem in cartItems) {
      if (cartItem.isSelected) {
        itemsList.add({
          "_id": cartItem.id,
          "name": cartItem.name,
          "category": cartItem.category,
          "description": cartItem.description,
          "weight": cartItem.weight,
          "stock": cartItem.stock,
          "customerPrice": cartItem.customerPrice,
          // "retailerPrice": cartItem.retailerPrice,
          "image": cartItem.imageUrl,
          "type": cartItem.itemType,
          "quantity": cartItem.quantity,
          // "totalPrice": cartItem.customerPrice * cartItem.quantity,
        });
      }
    }
    return itemsList;
  }

  Future<void> sendTransactionData() async {
    const apiUrl = 'https://lpg-api-06n8.onrender.com/api/v1/transactions';
    final CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: false);
    final List<Map<String, dynamic>> itemsList =
        convertCartItems(cartProvider.cartItems);
    final Map<String, dynamic> requestData = {
      "name": nameController.text,
      "contactNumber": contactNumberController.text,
      "items": itemsList,
      "discounted": isDiscounted,
      "completed": "true",
      "__t": null,
      "priceType": "Customer",
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(requestData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Transaction successful');
        print('Response: ${response.body}');
        Navigator.pushNamed(context, walkinRoute);
      } else {
        print('Transaction failed with status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> showConfirmationDialog() async {
    BuildContext currentContext = context;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${nameController.text}'),
              Text('Mobile Number: ${contactNumberController.text}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await sendTransactionData();
                Provider.of<CartProvider>(currentContext, listen: false)
                    .clearCart();
                Navigator.pushNamed(currentContext, walkinRoute);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmDialog() async {
    selectedDateTime = DateTime.now();
    BuildContext currentContext = context;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'Confirmation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Name: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: nameController.text,
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Mobile Number: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: contactNumberController.text,
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Discounted: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: isDiscounted != false ? 'Yes' : 'No',
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF050404).withOpacity(0.7),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await sendTransactionData();
                Provider.of<CartProvider>(currentContext, listen: false)
                    .clearCart();
                Navigator.pushNamed(currentContext, dashboardRoute);
                isDiscounted = false;
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF050404).withOpacity(0.9),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Walkin Information',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, cartRoute);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextField(
                    labelText: 'Name',
                    hintText: 'Enter the Name',
                    controller: nameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the Name";
                      } else {
                        return null;
                      }
                    },
                  ),
                  CustomTextField(
                    labelText: 'Mobile Number',
                    hintText: 'Enter the Mobile Number',
                    controller: contactNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the Mobile Number";
                      } else if (value.length != 11) {
                        return "Please Enter the Correct Mobile Number";
                      } else if (!value.startsWith('09')) {
                        return "Please Enter the Correct Mobile Number";
                      } else {
                        return null;
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Apply Discount: ',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF050404).withOpacity(0.9),
                          ),
                        ),
                        Theme(
                          data: ThemeData(
                            unselectedWidgetColor: Colors.white,
                            checkboxTheme: CheckboxThemeData(
                              fillColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return const Color(0xFF050404)
                                        .withOpacity(0.9);
                                  }
                                  return Colors.white;
                                },
                              ),
                            ),
                          ),
                          child: Checkbox(
                            value: isDiscounted,
                            onChanged: (value) {
                              setState(() {
                                isDiscounted = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomizedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    confirmDialog();
                  }
                },
                text: 'Save',
                height: 50,
                width: 200,
                fontz: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
