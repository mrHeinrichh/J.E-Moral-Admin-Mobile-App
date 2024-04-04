import 'package:admin_app/widgets/custom_text.dart';
import 'package:admin_app/widgets/fullscreen_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RecentOrders extends StatefulWidget {
  @override
  _RecentOrdersState createState() => _RecentOrdersState();
}

class _RecentOrdersState extends State<RecentOrders> {
  List<Map<String, dynamic>> transactions = [];
  final formKey = GlobalKey<FormState>();
  bool loadingData = false;
  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadingData = true;
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://lpg-api-06n8.onrender.com/api/v1/transactions/?filter={"status":"Pending","__t":"Delivery"}&page=1&limit=300',
        ),
      );

      if (_mounted) {
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data.containsKey("data")) {
            final List<dynamic> transactionData = data["data"];

            setState(() {
              transactions = List<Map<String, dynamic>>.from(transactionData);
            });
          } else {}
        } else {
          print("Error: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (_mounted) {
        print("Error: $e");
      }
    } finally {
      loadingData = false;
    }
  }

  void approveOrder(String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Approve Confirmation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: const SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Are you sure you want to approve this transaction?",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF050404).withOpacity(0.8),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final String apiUrl =
                      'https://lpg-api-06n8.onrender.com/api/v1/transactions/$id/approve';
                  final http.Response response = await http.patch(
                    Uri.parse(apiUrl),
                    headers: {'Content-Type': 'application/json'},
                  );

                  if (response.statusCode == 200) {
                    print('Transaction updated successfully');
                    fetchData();
                    Navigator.of(context).pop();
                  }
                } catch (error) {
                  print('Error updating transaction: $error');
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF050404).withOpacity(0.9),
              ),
              child: const Text(
                'Approve',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void declineOrder(String id) async {
    Map<String, dynamic> transactionToEdit =
        transactions.firstWhere((data) => data['_id'] == id);

    TextEditingController cancelReasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Decline Confirmation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Are you sure you want to decline this transaction?",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  EditTextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: cancelReasonController,
                    labelText: "Reason for Cancelling Order",
                    hintText: 'Enter the Reason for Cancelling Order',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Reason for Cancelling Order';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF050404).withOpacity(0.8),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  transactionToEdit['status'] = "Declined";
                  transactionToEdit['cancelReason'] =
                      cancelReasonController.text;
                  transactionToEdit['__t'] = "Delivery";

                  final url = Uri.parse(
                      'https://lpg-api-06n8.onrender.com/api/v1/transactions/$id');
                  final headers = {'Content-Type': 'application/json'};

                  final response = await http.patch(
                    url,
                    headers: headers,
                    body: jsonEncode(transactionToEdit),
                  );

                  if (response.statusCode == 200) {
                    fetchData();
                    Navigator.pop(context);
                  } else {
                    print(
                        'Failed to update the customer. Status code: ${response.statusCode}');
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFd41111).withOpacity(0.9),
              ),
              child: const Text(
                'Decline',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Pending Orders',
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
      body: loadingData
          ? Center(
              child: LoadingAnimationWidget.flickr(
                leftDotColor: const Color(0xFF050404).withOpacity(0.8),
                rightDotColor: const Color(0xFFd41111).withOpacity(0.8),
                size: 40,
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF050404),
              strokeWidth: 2.5,
              onRefresh: () async {
                await fetchData();
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: ListView.builder(
                  reverse: false,
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];

                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  const BodyMedium(
                                    text: "Transaction ID:",
                                  ),
                                  BodyMedium(
                                    text: transaction['_id'],
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            const Center(
                              child: BodyMedium(text: "Receiver Infomation"),
                            ),
                            const SizedBox(height: 5),
                            BodyMediumText(
                                text: "Name: ${transaction['name']}"),
                            BodyMediumText(
                                text:
                                    "Mobile Number: ${transaction['contactNumber']}"),
                            BodyMediumOver(
                                text:
                                    "House Number: ${transaction['houseLotBlk']}"),
                            BodyMediumText(
                                text: "Barangay: ${transaction['barangay']}"),
                            BodyMediumOver(
                                text:
                                    "Delivery Location: ${transaction['deliveryLocation']}"),
                            const Divider(),
                            BodyMediumText(
                                text:
                                    'Payment Method: ${transaction['paymentMethod'] == 'COD' ? 'Cash on Delivery' : transaction['paymentMethod']}'),
                            if (transaction.containsKey('discountIdImage'))
                              BodyMediumText(
                                text:
                                    'Assemble Option: ${transaction['installed'] ? 'Yes' : 'No'}',
                              ),
                            BodyMediumOver(
                              text:
                                  'Delivery Date and Time: ${DateFormat('MMMM d, y - h:mm a').format(DateTime.parse(transaction['deliveryDate']))}',
                            ),
                            if (transaction.containsKey('discountIdImage'))
                              Text(
                                'Items: ${transaction['items']!.map((item) {
                                  if (item is Map<String, dynamic> &&
                                      item.containsKey('name') &&
                                      item.containsKey('quantity') &&
                                      item.containsKey('customerPrice')) {
                                    final itemName = item['name'];
                                    final quantity = item['quantity'];
                                    final price = NumberFormat.decimalPattern()
                                        .format(double.parse(
                                            (item['customerPrice'])
                                                .toStringAsFixed(2)));

                                    return '$itemName ₱$price (x$quantity)';
                                  }
                                }).join(', ')}',
                              ),
                            if (!transaction.containsKey('discountIdImage') &&
                                transaction['discounted'] == false)
                              Text(
                                'Items: ${transaction['items']!.map((item) {
                                  if (item is Map<String, dynamic> &&
                                      item.containsKey('name') &&
                                      item.containsKey('quantity') &&
                                      item.containsKey('retailerPrice')) {
                                    final itemName = item['name'];
                                    final quantity = item['quantity'];
                                    final price = NumberFormat.decimalPattern()
                                        .format(double.parse(
                                            (item['retailerPrice'])
                                                .toStringAsFixed(2)));

                                    return '$itemName ₱$price (x$quantity)';
                                  }
                                }).join(', ')}',
                              ),
                            BodyMediumText(
                              text:
                                  'Total: ₱${NumberFormat.decimalPattern().format(double.parse((transaction['total']).toStringAsFixed(2)))}',
                            ),
                            const Divider(),
                            if (transaction.containsKey('discountIdImage'))
                              Center(
                                child: BodyMediumText(
                                  text:
                                      'Discount: ${transaction['discounted'] != false ? 'Applying for Discount' : 'Not Applying for Discount'}',
                                ),
                              ),
                            if (!transaction.containsKey('discountIdImage') &&
                                transaction['discounted'] == false)
                              const Center(
                                child: BodyMedium(
                                  text: 'Ordered by Retailer',
                                ),
                              ),
                            if (transaction['discountIdImage'] != null &&
                                transaction['discountIdImage'] != "")
                              Column(
                                children: [
                                  const SizedBox(height: 5),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            FullScreenImageView(
                                                imageUrl: transaction[
                                                    'discountIdImage'],
                                                onClose: () =>
                                                    Navigator.of(context)
                                                        .pop()),
                                      ));
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 300,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                              transaction['discountIdImage'] ??
                                                  '',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 45,
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      declineOrder(transaction['_id']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF050404)
                                          .withOpacity(0.4),
                                    ),
                                    child: const Text(
                                      "Decline",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  height: 45,
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      approveOrder(transaction['_id']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF050404)
                                          .withOpacity(0.9),
                                    ),
                                    child: const Text(
                                      "Approve",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
