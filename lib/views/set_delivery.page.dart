import 'package:admin_app/routes/app_routes.dart';
import 'package:admin_app/views/cart_provider.dart';
import 'package:admin_app/widgets/custom_button.dart';
// import 'package:admin_app/widgets/custom_timepicker.dart';
import 'package:admin_app/widgets/text_field.dart';
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
final formKey = GlobalKey<FormState>();
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
          "customerPrice": cartItem.customerPrice,
          "quantity": cartItem.quantity,
          "description": cartItem.description,
          "weight": cartItem.weight,
          "stock": cartItem.stock,
          "category": cartItem.category,
          "type": cartItem.type,
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
      "completed": "true",
      "type": "Transactions",
      "items": itemsList,
      "discounted": isDiscounted,
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
        // If the transaction is successful, you can proceed with navigation.
        Navigator.pushNamed(context, walkinRoute);
      } else {
        print('Transaction failed with status code: ${response.statusCode}');
        print('Response: ${response.body}');
        // You might want to display an error message to the user.
      }
    } catch (e) {
      print('Error: $e');
      // Handle other types of errors, if any.
      // You might want to display an error message to the user.
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
              Text('Contact Number: ${contactNumberController.text}'),
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
          title: const Text('Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Name:",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${nameController.text}",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Contact Number:",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${contactNumberController.text}",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Walkin Information',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, dashboardRoute);
          },
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  SetDeliveryText(
                    labelText: 'Name',
                    hintText: 'Enter Name',
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter the name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  SetDeliveryTextNumber(
                    labelText: 'Contact Number',
                    controller: contactNumberController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Number';
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    title: Text('Apply Discount'),
                    value: isDiscounted,
                    onChanged: (value) {
                      setState(() {
                        isDiscounted = value!;
                      });
                    },
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
                  if (formKey.currentState?.validate() == true) {
                    confirmDialog();
                  }
                },
                text: 'Save',
                height: 50,
                width: 180,
                fontz: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
