import 'package:admin_app/views/transact_completed.page.dart';
import 'package:admin_app/views/transact_walkin.page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TransactionCompletedPage(),
    );
  }
}

class TransactionCompletedPage extends StatefulWidget {
  @override
  _TransactionCompletedPageState createState() =>
      _TransactionCompletedPageState();
}

class _TransactionCompletedPageState extends State<TransactionCompletedPage> {
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
          'Transaction List',
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
          ? Transaction_CompletedPage()
          : Transaction_WalkinPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.done_all_rounded,
                color: const Color(0xFF050404).withOpacity(0.9)),
            label: 'Completed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk,
                color: const Color(0xFF050404).withOpacity(0.9)),
            label: 'Walk-ins',
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
