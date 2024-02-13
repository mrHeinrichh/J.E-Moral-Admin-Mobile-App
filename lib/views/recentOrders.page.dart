import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';

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
          title: const Text('Decline Confirmation'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: 10),
                TextFormField(
                  controller: cancelReasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for Cancelling Order',
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onDecline(cancelReasonController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Decline'),
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
          title: const Text('Approve Confirmation'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onApprove();
                Navigator.of(context).pop();
              },
              child: const Text('Approve'),
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
          title: const Text('Confirmation'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              const SizedBox(height: 10),
              const Text('State the Reason for Cancelling the Order:'),
              TextField(
                controller: cancelReasonController,
                decoration: const InputDecoration(
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onConfirm(cancelReasonController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateTransactionStatus(String transactionId) async {
    try {
      final String apiUrl =
          'https://lpg-api-06n8.onrender.com/api/v1/transactions/$transactionId/approve';
      final http.Response response = await http.patch(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
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

            final List<Map<String, dynamic>> filteredTransactions =
                List<Map<String, dynamic>>.from(transactionData)
                    .where((transaction) => transaction["status"] == "Pending")
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
        title: const Text(
          'Pending Orders',
          style: TextStyle(
            color: Color(0xFF232937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: RefreshIndicator(
          onRefresh: refreshData,
          child: ListView.builder(
            reverse: false,
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: "Receiver Name: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "${transaction['name']}",
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
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
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: "Delivery Location: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "${transaction['deliveryLocation']}",
                            ),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: "House#/Lot/Blk: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "${transaction['houseLotBlk']}",
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
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
                      Row(
                        children: [
                          const Text(
                            "Payment Method: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${transaction['paymentMethod'] == 'COD' ? 'Cash on Delivery' : transaction['paymentMethod']}",
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            "Needs to be assembled: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            transaction['assembly'] ? 'Yes' : 'No',
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            "Date and Time: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              DateFormat('h:mm a | MMM d, y').format(
                                  DateTime.parse(transaction['updatedAt'])),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            "Total Price: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₱${NumberFormat.decimalPattern().format(transaction['total'])}',
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Discount: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            transaction['discounted']
                                ? 'Applying for Discount'
                                : 'Not Applying for Discount',
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
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 45,
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: ElevatedButton(
                              onPressed: () async {
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
                                primary: Colors.grey,
                              ),
                              child: const Text(
                                "Decline",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            height: 45,
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: ElevatedButton(
                              onPressed: () async {
                                await showApproveDialog(
                                  context,
                                  'Are you sure you want to approve this transaction?',
                                  () {
                                    updateTransactionStatus(transaction['_id']);
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                primary: const Color(0xFF232937),
                              ),
                              child: const Text(
                                "Approve",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      //   child: SizedBox(
                      //     height: 45,
                      //     width: MediaQuery.of(context).size.width * 0.90,
                      //     child: ElevatedButton(
                      //       onPressed: () async {
                      //         await showConfirmationDialog(
                      //           context,
                      //           'Are you sure you want to Approve this transaction with discount?',
                      //           (String cancelReason) {
                      //             updateTransactionStatuswithDiscount(
                      //                 transaction['_id']);
                      //             Navigator.of(context).pop();
                      //           },
                      //         );
                      //       },
                      //       style: ElevatedButton.styleFrom(
                      //         primary: Colors.green,
                      //       ),
                      //       child: const Text(
                      //         "Approve with Discount",
                      //         style: TextStyle(
                      //           color: Color.fromARGB(255, 255, 255, 255),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
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

  // void _showCustomerDetailsModal(Map<String, dynamic> customer) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SingleChildScrollView(
  //         child: Container(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               const Text(
  //                 'Customer Details',
  //                 style: TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //               Text('Name: ${customer['name']}'),
  //               Text('Contact Number: ${customer['contactNumber']}'),
  //               Text('Address: ${customer['address']}'),
  //               customer['image'] != null
  //                   ? Image.network(
  //                       customer['image'],
  //                       width: 300,
  //                       height: 300,
  //                       fit: BoxFit.cover,
  //                     )
  //                   : Container(),
  //               const SizedBox(height: 16),
  //               Align(
  //                 alignment: Alignment.center,
  //                 child: ElevatedButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: const Text('Close'),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
