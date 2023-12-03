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

            // Filter out accepted transactions
            final List<Map<String, dynamic>> filteredTransactions =
                List<Map<String, dynamic>>.from(transactionData)
                    .where((transaction) => !transaction["isApproved"])
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

  Future<void> updateOrderInDatabase(
    String id,
    bool isApproved,
    bool isDeleted,
  ) async {
    // Convert boolean to string
    String isApprovedString = isApproved.toString();
    String isDeletedString = isDeleted.toString();
    try {
      // Make an HTTP request or database query to update the value in the database
      final response = await http.patch(
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/transactions/$id'),
        body: {
          'isApproved': isApprovedString,
          'deleted': isDeletedString,
        },
      );

      if (response.statusCode == 200) {
        print('Order updated successfully');
        // print('Response body: ${response.body}');
        print(response.statusCode);
        print(response.body);
      } else {
        print('Failed to update order. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        // Handle error accordingly
      }
    } catch (e) {
      print('Error during update: $e');
    }
  }

  Future<void> refreshData() async {
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTransactions = transactions
        .where((transaction) =>
            !transaction["isApproved"] &&
            transaction["type"] == "Online" &&
            transaction["type"] != "Walkin" &&
            transaction["type"] != "")
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
          'Recent Orders',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
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
                            "Product Name",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Quantity: 1",
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
                        "Delivery Location: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${transaction['deliveryLocation']}',
                      ),
                      Text(
                        "House#/Lot/Blk:  ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${transaction['houseLotBlk']}',
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
                        "Payment Method: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${transaction['paymentMethod']}',
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
                          Text(
                            transaction['isApproved'] ? 'Approved' : 'Pending',
                            style: TextStyle(
                              color: transaction['isApproved']
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      // Text("Date: ${transaction['updatedAt']}"),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              // Show accept confirmation dialog
                              showConfirmationDialog(
                                context,
                                "Are you sure you want to accept the order for ${transaction['name']}?",
                                () async {
                                  // Handle accept logic here
                                  print(
                                      "Order Accepted: ${transaction['name']}");

                                  // Update isApproved to true in the local state
                                  setState(() {
                                    transaction['isApproved'] = true;
                                  });

                                  // Update isApproved to true in the database
                                  await updateOrderInDatabase(
                                    transaction['_id'].toString(),
                                    true,
                                    false,
                                  );

                                  // Remove the accepted transaction from the displayed list
                                  setState(() {
                                    transactions.removeWhere((item) =>
                                        item['_id'] == transaction['_id']);
                                  });

                                  Navigator.pop(context); // Close the dialog
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.black,
                            ),
                            child: Text("Accept"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // Show decline confirmation dialog
                              showConfirmationDialog(
                                context,
                                "Are you sure you want to decline the order for ${transaction['name']}?",
                                () async {
                                  // Handle decline logic here
                                  print(
                                      "Order Declined: ${transaction['name']}");

                                  // Update isApproved to false in the local state
                                  setState(() {
                                    transaction['isApproved'] = false;
                                  });

                                  // Update isApproved to false in the database
                                  await updateOrderInDatabase(
                                    transaction['_id'].toString(),
                                    false,
                                    true,
                                  );

                                  // Fetch data again to refresh the list
                                  await fetchData();

                                  Navigator.pop(context); // Close the dialog
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                            ),
                            child: Text("Decline"),
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
