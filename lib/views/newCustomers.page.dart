import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

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

  Future<void> archivedCustomer(String customerId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/users/$customerId'),
      );

      if (response.statusCode == 200) {
        print('Customer deleted successfully');
        await refreshData();
      } else {
        print('Error deleting customer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateVerificationStatus(
      String customerId, String userEmail) async {
    try {
      final response = await http.patch(
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/users/$customerId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'verified': 'true',
          '__t': 'Customer',
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        print('Updated User Data: ${responseData['data']}');
        print('Verification status updated successfully');
        refreshData();

        // Send confirmation email to the customer's email address
        await sendConfirmationEmail(userEmail);
      } else {
        print('Error updating verification status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> sendConfirmationEmail(String userEmail) async {
    String username =
        'madridanthonycharles@gmail.com'; // Update with your email address
    String password = 'lqllbqsftvgihlll'; // Update with your email password

    // Create a SMTP server configuration
    final smtpServer = gmail(username, password);

    // Create a plain text message
    final message = Message()
      ..from = Address(username, 'J.E. Moral LPG Dealer Store')
      ..subject = 'Account Verification'
      ..html = '''
      <p>Dear user,</p>
      <p>Your account has been successfully verified. You can now login to the application. Happy Shopping!</p>
      <p><img src="https://raw.githubusercontent.com/mrHeinrichh/J.E-Moral-cdn/main/assets/png/logo-main.png" alt="Verification Image" width="200" height="200"></p>

    ''';
    // Add recipient
    message.recipients
        .add(Address(userEmail)); // Send to the provided email address

    // Send the email
    try {
      final sendReport = await send(message, smtpServer);
      print('Email sent');
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> unverifiedCustomers =
        customers.where((customer) => customer['verified'] == false).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Pending Verification',
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
            itemCount: unverifiedCustomers.length,
            itemBuilder: (context, index) {
              final customer = unverifiedCustomers[index];
              return Card(
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
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: "Name: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "${customer['name']}",
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
                                    '${customer['contactNumber']}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(customer['image']),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Divider(),
                      ElevatedButton(
                        onPressed: () async {
                          await updateVerificationStatus(
                              customer['_id'], customer['email']);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Customer approved successfully'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color(0xFF232937),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text('Approve',
                            style: TextStyle(color: Colors.white)),
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
