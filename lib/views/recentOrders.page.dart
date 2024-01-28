import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class RecentOrders extends StatefulWidget {
  @override
  _RecentOrdersState createState() => _RecentOrdersState();
}

class _RecentOrdersState extends State<RecentOrders> {
  List<Map<String, dynamic>> transactions = [];
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> showConfirmationDialog(
    BuildContext context,
    String message,
    VoidCallback onConfirm,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateTransactionStatus(String transactionId) async {
    try {
      Map<String, dynamic> updateData = {
        "status": "Approved",
        "__t": "Delivery"
      };

      final String apiUrl =
          'https://lpg-api-06n8.onrender.com/api/v1/transactions/$transactionId';
      final http.Response response = await http.patch(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        print('Transaction updated successfully');
        print('Response: ${response.body}');
        print(response.statusCode);
        await refreshData();
      } else {
        print(
            'Failed to update transaction. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (error) {
      print('Error updating transaction: $error');
    }
  }

  Future<void> declineTransactionStatus(String transactionId) async {
    try {
      Map<String, dynamic> updateData = {
        "status": "Declined",
        "deleted": "true",
        "__t": "Delivery"
      };

      final String apiUrl =
          'https://lpg-api-06n8.onrender.com/api/v1/transactions/$transactionId';
      final http.Response response = await http.patch(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        print('Transaction updated successfully');
        print('Response: ${response.body}');
        print(response.statusCode);
        await refreshData();
      } else {
        print(
            'Failed to update transaction. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (error) {
      print('Error updating transaction: $error');
    }
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/transactions'),
      );

      if (_mounted) {
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data.containsKey("data")) {
            final List<dynamic> transactionData = data["data"];

            // Remove isApproved condition from filtering
            final List<Map<String, dynamic>> filteredTransactions =
                List<Map<String, dynamic>>.from(transactionData)
                    .where((transaction) => transaction["status"] == "Pending")
                    .toList();

            setState(() {
              transactions = filteredTransactions;
            });
          } else {
            // Handle data format issues if needed
          }
        } else {
          print("Error: ${response.statusCode}");
        }
      }
    } catch (e) {
      // Handle network request errors
      if (_mounted) {
        print("Error: $e");
      }
    }
  }

  Future<void> refreshData() async {
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTransactions = transactions
        .where((transaction) => transaction["status"] == "Pending")
        .toList();

    filteredTransactions.sort((b, a) {
      DateTime dateTimeA = DateTime.parse(a["updatedAt"]);
      DateTime dateTimeB = DateTime.parse(b["updatedAt"]);

      return dateTimeB.compareTo(dateTimeA);
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Pending Delivery Orders',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: RefreshIndicator(
          onRefresh: refreshData,
          child: ListView.builder(
            reverse: false, // Display the latest data at the top

            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Transaction ID: ${transaction['_id']}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Text(
                          //   "Quantity: 1",
                          //   style: TextStyle(fontWeight: FontWeight.bold),
                          // ),
                        ],
                      ),
                      Divider(
                        thickness: 1,
                        color: Colors.black,
                      ),
                      Row(
                        children: [
                          Text(
                            "Name: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${transaction['name']}',
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Contact Number: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${transaction['contactNumber']}',
                          ),
                        ],
                      ),
                      Text(
                        "Delivery Location: ${transaction['deliveryLocation']}' ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "House#/Lot/Blk: ${transaction['houseLotBlk']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "Barangay: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${transaction['barangay']}',
                          ),
                        ],
                      ),
                      Text(
                        "Payment Method: ${transaction['paymentMethod']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "Needs to be assembled: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${transaction['assembly']}',
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Delivery Time: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${transaction['deliveryTime']}',
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Date Ordered: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${transaction['updatedAt']}',
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Total Price: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${transaction['total']}',
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Order Status: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 45,
                            width: 150,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Show confirmation dialog before updating the status
                                await showConfirmationDialog(
                                  context,
                                  'Are you sure you want to approve this transaction?',
                                  () {
                                    updateTransactionStatus(transaction['_id']);
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF232937),
                              ),
                              child: Text(
                                "Accept",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          Container(
                            height: 45,
                            width: 150,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Show confirmation dialog before updating the status
                                await showConfirmationDialog(
                                  context,
                                  'Are you sure you want to decline this transaction?',
                                  () {
                                    declineTransactionStatus(
                                        transaction['_id']);
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                              ),
                              child: Text(
                                "Decline",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
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
