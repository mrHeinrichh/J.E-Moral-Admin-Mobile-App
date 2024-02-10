import 'package:admin_app/views/maps.page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ActiveOrders extends StatefulWidget {
  @override
  _ActiveOrdersState createState() => _ActiveOrdersState();
}

class _ActiveOrdersState extends State<ActiveOrders> {
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

            // Filter out transactions where "active" is false
            final List<Map<String, dynamic>> filteredTransactions =
                List<Map<String, dynamic>>.from(transactionData)
                    .where((transaction) => transaction["status"] == 'On Going')
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
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Active Orders',
          style: TextStyle(
            color: Color(0xFF232937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
                            "Transaction ID: ${transaction['_id']}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 1,
                        color: Colors.black,
                      ),
                      Row(
                        children: [
                          const Text(
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
                      Text(
                        "Delivery Location: ${transaction['deliveryLocation']}' ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "House#/Lot/Blk: ${transaction['houseLotBlk']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
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
                      Text(
                        "Payment Method: ${transaction['paymentMethod']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
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
                            '${transaction['assembly']}',
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            "Delivery Date/Time: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${transaction['deliveryDate']}',
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
                            '${transaction['total']}',
                          ),
                        ],
                      ),
                      SizedBox(
                          width: 200,
                          height: 50,
                          child: TextButton(
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
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.all(16.0),
                              textStyle: const TextStyle(fontSize: 20),
                            ),
                            child: const Text('Track Order'),
                          ))
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
