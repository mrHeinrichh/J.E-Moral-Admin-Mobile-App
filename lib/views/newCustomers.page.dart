import 'package:admin_app/widgets/custom_text.dart';
import 'package:admin_app/widgets/fullscreen_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';
import 'dart:async';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class NewCustomers extends StatefulWidget {
  @override
  _NewCustomersState createState() => _NewCustomersState();
}

class _NewCustomersState extends State<NewCustomers> {
  List<Map<String, dynamic>> userDataList = [];
  bool _mounted = true;
  bool loadingData = false;

  @override
  void initState() {
    super.initState();
    loadingData = true;
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
        Uri.parse(
          'https://lpg-api-06n8.onrender.com/api/v1/users/?filter={"__t":{"\$in":["Customer","Retailer"]}}&limit=300',
        ),
      );

      if (_mounted) {
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data.containsKey("data")) {
            final List<dynamic> userData = data["data"];

            setState(() {
              userDataList = List<Map<String, dynamic>>.from(userData);
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

  Future<void> verifiedCustomers(String customerId, String userEmail) async {
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

        await sendConfirmationEmail(userEmail);

        fetchData();
      } else {
        print('Error updating verification status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> verifiedRetailers(String customerId, String userEmail) async {
    try {
      final response = await http.patch(
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/users/$customerId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'verified': 'true',
          '__t': 'Retailer',
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        print('Updated User Data: ${responseData['data']}');
        print('Verification status updated successfully');

        await sendConfirmationEmail(userEmail);

        fetchData();
      } else {
        print('Error updating verification status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> sendConfirmationEmail(String userEmail) async {
    String username = 'madridanthonycharles@gmail.com';
    String password = 'lqllbqsftvgihlll';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'J.E. Moral LPG Dealer Store')
      ..subject = 'Account Verification'
      ..html = '''
      <p>Dear user,</p>
      <p>Your account has been successfully verified. You can now login to the application. Happy Shopping!</p>
      <p><img src="https://raw.githubusercontent.com/mrHeinrichh/J.E-Moral-cdn/main/assets/png/logo-main.png" alt="Verification Image" width="200" height="200"></p>

    ''';

    message.recipients.add(Address(userEmail));

    try {
      final sendReport = await send(message, smtpServer);
      print('Email sent');
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> unverifiedUsers =
        userDataList.where((user) => user['verified'] == false).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Pending Verification',
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
                  itemCount: unverifiedUsers.length,
                  itemBuilder: (context, index) {
                    final user = unverifiedUsers[index];
                    String userType = user['__t'];

                    return Column(
                      children: [
                        if (userType == 'Customer')
                          GestureDetector(
                            onTap: () {
                              showCustomerDetailsModal(user);
                            },
                            child: Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TitleMedium(
                                      text: 'Type: ${user['__t']}',
                                    ),
                                    const Divider(),
                                    BodyMediumOver(
                                      text: 'Name: ${user['name']}',
                                    ),
                                    BodyMediumText(
                                      text:
                                          'Mobile Number: ${user['contactNumber']}',
                                    ),
                                    BodyMediumOver(
                                      text: 'Email Address: ${user['email']}',
                                    ),
                                    BodyMediumOver(
                                      text: 'Full Address: ${user['address']}',
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                  'Approve Confirmation',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                content: const Text(
                                                  'Are you sure you want to approve this Customer?',
                                                  textAlign: TextAlign.center,
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          const Color(
                                                                  0xFF050404)
                                                              .withOpacity(0.8),
                                                    ),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      await verifiedCustomers(
                                                          user['_id'],
                                                          user['email']);
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          const Color(
                                                                  0xFF050404)
                                                              .withOpacity(0.9),
                                                    ),
                                                    child: const Text(
                                                      'Approve',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF050404)
                                                  .withOpacity(0.9),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                        ),
                                        child: const Text('Approve',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (userType == 'Retailer')
                          GestureDetector(
                            onTap: () {
                              showCustomerDetailsModal(user);
                            },
                            child: Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TitleMedium(
                                      text: 'Type: ${user['__t']}',
                                    ),
                                    const Divider(),
                                    BodyMediumOver(
                                      text: 'Name: ${user['name']}',
                                    ),
                                    BodyMediumText(
                                      text:
                                          'Mobile Number: ${user['contactNumber']}',
                                    ),
                                    BodyMediumOver(
                                      text: 'Email Address: ${user['email']}',
                                    ),
                                    BodyMediumOver(
                                      text: 'Full Address: ${user['address']}',
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                  'Approve Confirmation',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                content: const Text(
                                                  'Are you sure you want to approve this Retailer?',
                                                  textAlign: TextAlign.center,
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          const Color(
                                                                  0xFF050404)
                                                              .withOpacity(0.8),
                                                    ),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      await verifiedRetailers(
                                                          user['_id'],
                                                          user['email']);
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          const Color(
                                                                  0xFF050404)
                                                              .withOpacity(0.9),
                                                    ),
                                                    child: const Text(
                                                      'Approve',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF050404)
                                                  .withOpacity(0.9),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                        ),
                                        child: const Text('Approve',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }

  void showCustomerDetailsModal(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: TitleMedium(
                    text: 'User Information',
                  ),
                ),
                const Divider(),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => FullScreenImageView(
                            imageUrl: user['image'],
                            onClose: () => Navigator.of(context).pop()),
                      ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF050404).withOpacity(0.9),
                          width: 0.2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(user['image']),
                      ),
                    ),
                  ),
                ),
                TitleMediumText(
                  text: 'Type: ${user['__t']}',
                ),
                const Divider(),
                BodyMediumOver(
                  text: 'Name: ${user['name']}',
                ),
                BodyMediumText(
                  text: 'Mobile Number: ${user['contactNumber']}',
                ),
                BodyMediumOver(
                  text: 'Email Address: ${user['email']}',
                ),
                BodyMediumOver(
                  text: 'Full Address: ${user['address']}',
                ),
                if (user['__t'] == "Retailer")
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'DOE:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => FullScreenImageView(
                                        imageUrl: user['doe'],
                                        onClose: () =>
                                            Navigator.of(context).pop()),
                                  ));
                                },
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFF050404)
                                          .withOpacity(0.9),
                                      width: 0.2,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(user['doe'] ?? ''),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                'Business Permit:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => FullScreenImageView(
                                        imageUrl: user['businessPermit'],
                                        onClose: () =>
                                            Navigator.of(context).pop()),
                                  ));
                                },
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFF050404)
                                          .withOpacity(0.9),
                                      width: 0.2,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          user['businessPermit'] ?? ''),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Fire Safety Permit:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => FullScreenImageView(
                                        imageUrl: user['fireSafetyPermit'],
                                        onClose: () =>
                                            Navigator.of(context).pop()),
                                  ));
                                },
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFF050404)
                                          .withOpacity(0.9),
                                      width: 0.2,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          user['fireSafetyPermit'] ?? ''),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                'Agreement:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => FullScreenImageView(
                                        imageUrl: user['agreement'],
                                        onClose: () =>
                                            Navigator.of(context).pop()),
                                  ));
                                },
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFF050404)
                                          .withOpacity(0.9),
                                      width: 0.2,
                                    ),
                                    image: DecorationImage(
                                      image:
                                          NetworkImage(user['agreement'] ?? ''),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
