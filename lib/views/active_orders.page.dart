import 'package:admin_app/views/maps.page.dart';
import 'package:admin_app/widgets/custom_text.dart';
import 'package:admin_app/widgets/fullscreen_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ActiveOrders extends StatefulWidget {
  @override
  _ActiveOrdersState createState() => _ActiveOrdersState();
}

class _ActiveOrdersState extends State<ActiveOrders> {
  List<Map<String, dynamic>> transactions = [];
  bool _mounted = true;
  bool loadingData = false;

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
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/transactions'),
      );

      if (_mounted) {
        if (response.statusCode == 200) {
          print(response.body);
          final Map<String, dynamic> data = json.decode(response.body);
          if (data.containsKey("data")) {
            final List<dynamic> transactionData = data["data"];

            final List<Map<String, dynamic>> filteredTransactions =
                List<Map<String, dynamic>>.from(transactionData)
                    .where((transaction) => transaction["status"] == 'On Going')
                    .toList();

            setState(() {
              transactions = filteredTransactions;
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

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTransactions = transactions
        .where((transaction) => transaction["pickedUp"] == true)
        .toList();

    filteredTransactions.sort((b, a) {
      DateTime dateTimeA = DateTime.parse(a["updatedAt"]);
      DateTime dateTimeB = DateTime.parse(b["updatedAt"]);

      return dateTimeB.compareTo(dateTimeA);
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Active Orders',
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
                padding: const EdgeInsets.all(20.0),
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
                              BodyMediumOver(
                                text:
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
                              BodyMediumOver(
                                text:
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
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MapsPage(
                                          transactionId: transaction['_id'],
                                          deliveryLocation:
                                              transaction['deliveryLocation'],
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF050404)
                                        .withOpacity(0.9),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    textStyle: const TextStyle(fontSize: 18),
                                  ),
                                  child: const Text(
                                    'Track Order',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                ),
                              ),
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
