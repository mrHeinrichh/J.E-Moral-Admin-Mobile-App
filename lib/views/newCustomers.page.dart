import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class NewCustomers extends StatefulWidget {
  @override
  _NewCustomersState createState() => _NewCustomersState();
}

class _NewCustomersState extends State<NewCustomers> {
  List<Map<String, dynamic>> customers = [];
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> fetchCustomers() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://lpg-api-06n8.onrender.com/api/v1/users/?filter={"__t": "Customer"}&page=1&limit=300',
        ),
      );

      if (_mounted) {
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data.containsKey("data")) {
            final List<dynamic> customerData = data["data"];

            setState(() {
              customers = List<Map<String, dynamic>>.from(customerData);
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
    await fetchCustomers();
  }

  // Future<void> deleteCustomer(String customerId) async {
  //   try {
  //     final response = await http.delete(
  //       Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/users/$customerId'),
  //     );

  //     if (response.statusCode == 200) {
  //       print('Customer deleted successfully');
  //       await refreshData();
  //     } else {
  //       print('Error deleting customer: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  Future<void> updateVerificationStatus(String customerId) async {
    try {
      final response = await http.patch(
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/users/$customerId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'verified': true,
          'type': 'Customer',
        }),
      );

      print('Update Verification Status Response: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        print('Updated User Data: ${responseData['data']}');
        print(response.body);
        print('Verification status updated successfully');
        refreshData();
      } else {
        print('Error updating verification status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateVerificationStatusDiscount(String customerId) async {
    try {
      final response = await http.patch(
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/users/$customerId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'verified': true,
          'discounted': true,
          'type': 'Customer',
        }),
      );

      print('Update Verification Status Response: ${response.body}');

      if (response.statusCode == 200) {
        final int customerIndex =
            customers.indexWhere((customer) => customer['_id'] == customerId);
        if (customerIndex != -1) {
          customers[customerIndex]['verified'] = true;
          customers[customerIndex]['discounted'] = true;
        }
        setState(() {});
        print(response.body);

        print('Verification status updated successfully');
      } else {
        print('Error updating verification status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> unverifiedCustomers =
        customers.where((customer) => customer['verified'] == false).toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Unverified Customers',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: RefreshIndicator(
          onRefresh: refreshData,
          child: ListView.builder(
            itemCount: unverifiedCustomers.length,
            itemBuilder: (context, index) {
              final customer = unverifiedCustomers[index];
              return GestureDetector(
                onTap: () {
                  _showCustomerDetailsModal(customer);
                },
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Name: ${customer['name']}"),
                                Text(
                                    "Contact Number: ${customer['contactNumber']}"),
                              ],
                            ),
                            const Spacer(),
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(customer['image']),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () async {
                                await updateVerificationStatus(customer['_id']);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Customer approved successfully'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Text('Approve'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await updateVerificationStatusDiscount(
                                    customer['_id']);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Customer with discount approved successfully'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Text('Approve with Discount'),
                            ),
                            // TextButton(
                            //   onPressed: () async {
                            //     await deleteCustomer(customer['_id']);

                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       const SnackBar(
                            //         content:
                            //             Text('Customer deleted successfully'),
                            //         duration: Duration(seconds: 2),
                            //       ),
                            //     );
                            //   },
                            //   child: const Text('Delete'),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCustomerDetailsModal(Map<String, dynamic> customer) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Customer Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Name: ${customer['name']}'),
                Text('Contact Number: ${customer['contactNumber']}'),
                Text('Address: ${customer['address']}'),
                const Text('Discount ID:'),
                customer['discountIdImage'] != null
                    ? Image.network(
                        customer['discountIdImage'],
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      )
                    : Container(),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
