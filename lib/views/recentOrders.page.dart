import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecentOrders extends StatefulWidget {
  @override
  _RecentOrdersState createState() => _RecentOrdersState();
}

class _RecentOrdersState extends State<RecentOrders> {
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/transactions'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey("data")) {
        final List<dynamic> transactionData = data["data"];
        setState(() {
          transactions = List<Map<String, dynamic>>.from(transactionData);
        });
      } else {
        // Handle the case where the "data" key is missing in the response.
      }
    } else {
      // Handle error here, e.g., show an error message
      print("Error: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    transactions.sort((a, b) => DateTime.parse(b["updatedAt"])
        .compareTo(DateTime.parse(a["updatedAt"])));

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
        child: ListView.builder(
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
                    // Replace this with the actual list of products
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("Product Name"), Text("Quantity: 1")],
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                    Text("Name: ${transaction['name']}"),
                    Text("Contact: ${transaction['contactNumber']}"),
                    Text("House#/Lot/Blk: ${transaction['houseLotBlk']}"),
                    Text("Barangay: ${transaction['barangay']}"),
                    Text("Payment Method: ${transaction['paymentMethod']}"),
                    Text("Needs to be assembled?: ${transaction['assembly']}"),
                    Text("Delivery Time: ${transaction['deliveryTime']}"),
                    Text("Total Price: ${transaction['total']}"),
                    Text("Date: ${transaction['updatedAt']}"),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
