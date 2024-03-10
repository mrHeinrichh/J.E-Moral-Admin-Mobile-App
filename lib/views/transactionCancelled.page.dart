import 'package:admin_app/views/transact_cancelled_customer.page.dart';
import 'package:admin_app/views/transact_cancelled_retailer.page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TransactionCancelledPage(),
    );
  }
}

class TransactionCancelledPage extends StatefulWidget {
  @override
  _TransactionCancelledPageState createState() =>
      _TransactionCancelledPageState();
}

class _TransactionCancelledPageState extends State<TransactionCancelledPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Failed Transactions',
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
      body: _selectedIndex == 0
          ? TransactionCancelledCustomerPage()
          : TransactionCancelledRetailerPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.supervisor_account_rounded,
                color: const Color(0xFF050404).withOpacity(0.9)),
            label: 'Customer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle_rounded,
                color: const Color(0xFF050404).withOpacity(0.9)),
            label: 'Retailer',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF050404).withOpacity(0.9),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
