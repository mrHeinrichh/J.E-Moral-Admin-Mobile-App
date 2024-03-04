import 'package:admin_app/views/transact_completed.page.dart';
import 'package:admin_app/views/transact_cancelled.page.dart';
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
      home: TransactionPage(),
    );
  }
}

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget selectedWidget;
    switch (_selectedIndex) {
      case 0:
        selectedWidget = TransactionCompletedPage();
        break;
      case 1:
        selectedWidget = TransactionCancelledPage();
        break;
      case 2:
        selectedWidget = TransactionWalkinPage();
        break;
      default:
        selectedWidget = TransactionCompletedPage();
    }

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
      body: selectedWidget,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.done_all_rounded,
                color: const Color(0xFF050404).withOpacity(0.9)),
            label: 'Completed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.close_rounded,
                color: const Color(0xFF050404).withOpacity(0.9)),
            label: 'Cancelled',
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
