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

  Future<void> showDeclineDialog(
    BuildContext context,
    String message,
    Function(String) onDecline,
  ) async {
    TextEditingController cancelReasonController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Decline Confirmation'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              SizedBox(height: 10),
              Text('Cancel Reason:'),
              TextField(
                controller: cancelReasonController,
                decoration: InputDecoration(
                  hintText: 'Enter cancel reason',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onDecline(cancelReasonController.text);
                Navigator.of(context)
                    .pop(); // Close the dialog after confirming
              },
              child: Text('Decline'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showApproveDialog(
    BuildContext context,
    String message,
    Function() onApprove,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Approve Confirmation'),
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
                onApprove();
                Navigator.of(context)
                    .pop(); // Close the dialog after confirming
              },
              child: Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showConfirmationDialog(
    BuildContext context,
    String message,
    Function(String) onConfirm,
  ) async {
    TextEditingController cancelReasonController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              SizedBox(height: 10),
              Text('Cancel Reason:'),
              TextField(
                controller: cancelReasonController,
                decoration: InputDecoration(
                  hintText: 'Enter cancel reason',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onConfirm(cancelReasonController.text);
                Navigator.of(context)
                    .pop(); // Close the dialog after confirming
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

  Future<void> updateTransactionStatuswithDiscount(String transactionId) async {
    try {
      Map<String, dynamic> updateData = {
        "status": "Approved",
        "discounted": true,
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

  Future<void> declineTransactionStatus(
      String transactionId, String cancelReason) async {
    try {
      Map<String, dynamic> updateData = {
        "status": "Cancelled",
        "cancelReason": cancelReason,
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
                            "ID: ${transaction['_id']}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
                            "Date/Time: ",
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
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Discounted: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${transaction['discounted']}',
                          ),
                        ],
                      ),
                      if (transaction['discountIdImage'] != null)
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                transaction['discountIdImage'] ??
                                    'URL_TO_FALLBACK_IMAGE',
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 45,
                            width: MediaQuery.of(context).size.width * 0.30,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Show confirmation dialog before updating the status
                                await showApproveDialog(
                                  context,
                                  'Are you sure you want to approve this transaction?',
                                  () {
                                    updateTransactionStatus(transaction['_id']);
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF232937),
                              ),
                              child: Text(
                                "Approve",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          Container(
                            height: 45,
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Show confirmation dialog before declining the transaction
                                await showDeclineDialog(
                                  context,
                                  'Are you sure you want to decline this transaction?',
                                  (String cancelReason) {
                                    declineTransactionStatus(
                                        transaction['_id'], cancelReason);
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width * 0.90,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Show confirmation dialog before updating the status
                              await showConfirmationDialog(
                                context,
                                'Are you sure you want to Approve this transaction with discount?',
                                (String cancelReason) {
                                  updateTransactionStatuswithDiscount(
                                      transaction['_id']);
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                            ),
                            child: Text(
                              "Approve with Discount",
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
