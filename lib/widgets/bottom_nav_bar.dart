import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        unselectedItemColor: const Color(0xFF050404).withOpacity(0.3),
        selectedItemColor: const Color(0xFF050404).withOpacity(0.8),
        iconSize: 30,
        selectedLabelStyle: const TextStyle(
          fontSize: 0,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 0,
        ),
        items: [
          BottomNavigationBarItem(
            icon: PendingCustomer(
              fetchCustomerCount: fetchCustomers,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: PendingOrder(
              fetchOrderCount: fetchOrders,
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: OngoingOrder(
              fetchOngoingOrderCount: fetchOngoingOrders,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.wechat_rounded,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}

// ERROR
Future<int> fetchCustomers() async {
  final response = await http
      .get(Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/users'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> allUserData = data['data'];

    final List<Map<String, dynamic>> unverifiedCustomers =
        List<Map<String, dynamic>>.from(allUserData.where((userData) =>
            userData is Map<String, dynamic> &&
            userData['__t'] == 'Customer' &&
            userData['verified'] == false));

    return unverifiedCustomers.length;
  } else {
    throw Exception('Failed to load data from the API');
  }
}

// Future<int> fetchCustomers() async {
//   final response = await http.get(Uri.parse(
//       'https://lpg-api-06n8.onrender.com/api/v1/transactions/?filter={"__t": "Customer", "verified": false}&limit=300'));

//   if (response.statusCode == 200) {
//     final Map<String, dynamic> data = json.decode(response.body);
//     final List<dynamic> unverifiedCustomers = data['data'];

//     return unverifiedCustomers.length;
//   } else {
//     throw Exception('Failed to load data from the API');
//   }
// }

Future<int> fetchOrders() async {
  final response = await http.get(Uri.parse(
      'https://lpg-api-06n8.onrender.com/api/v1/transactions/?filter={"status": "Pending","__t": "Delivery"}&limit=300'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> allTransactionsData = data['data'];

    return allTransactionsData.length;
  } else {
    throw Exception('Failed to load data from the API');
  }
}

Future<int> fetchOngoingOrders() async {
  final response = await http.get(Uri.parse(
      'https://lpg-api-06n8.onrender.com/api/v1/transactions/?filter={"status": "On Going","__t": "Delivery"}&limit=300'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> allTransactionsData = data['data'];

    return allTransactionsData.length;
  } else {
    throw Exception('Failed to load data from the API');
  }
}

class PendingCustomer extends StatelessWidget {
  final Future<int> Function() fetchCustomerCount;

  PendingCustomer({required this.fetchCustomerCount});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: fetchCustomerCount(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildIconWithCount(context, 0);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          int customerCount = snapshot.data ?? 0;
          return _buildIconWithCount(context, customerCount);
        }
      },
    );
  }

  Widget _buildIconWithCount(BuildContext context, int customerCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: GestureDetector(
        child: Column(
          children: [
            Stack(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.person_add_alt_1_sharp, size: 30),
                ),
                if (customerCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFd41111).withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        customerCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
  }
}

class PendingOrder extends StatelessWidget {
  final Future<int> Function() fetchOrderCount;

  PendingOrder({required this.fetchOrderCount});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: fetchOrderCount(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildIconWithCount(context, 0);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          int orderCount = snapshot.data ?? 0;
          return _buildIconWithCount(context, orderCount);
        }
      },
    );
  }

  Widget _buildIconWithCount(BuildContext context, int orderCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: GestureDetector(
        child: Column(
          children: [
            Stack(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.pending_actions_rounded, size: 30),
                ),
                if (orderCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFd41111).withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        orderCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
  }
}

class OngoingOrder extends StatelessWidget {
  final Future<int> Function() fetchOngoingOrderCount;

  OngoingOrder({required this.fetchOngoingOrderCount});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: fetchOngoingOrderCount(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildIconWithCount(context, 0);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          int orderCount = snapshot.data ?? 0;
          return _buildIconWithCount(context, orderCount);
        }
      },
    );
  }

  Widget _buildIconWithCount(BuildContext context, int orderCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: GestureDetector(
        child: Column(
          children: [
            Stack(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.location_history, size: 30),
                ),
                if (orderCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFd41111).withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        orderCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
  }
}
