import 'package:admin_app/views/editCustomerItems.page.dart';
import 'package:admin_app/views/editRetailerItems.page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: EditItemsPage(),
    );
  }
}

class EditItemsPage extends StatefulWidget {
  @override
  _EditItemsPageState createState() => _EditItemsPageState();
}

class _EditItemsPageState extends State<EditItemsPage> {
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
          'Update Prices',
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
          ? EditPricesForCustomersPage()
          : EditPricesForRetailersPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people,
                color: const Color(0xFF050404).withOpacity(0.9)),
            label: 'Customers Price',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center_rounded,
                color: const Color(0xFF050404).withOpacity(0.9)),
            label: 'Retailers Price',
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
