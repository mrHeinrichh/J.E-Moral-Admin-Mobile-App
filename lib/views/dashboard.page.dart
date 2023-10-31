import 'package:admin_app/views/chat.page.dart';
import 'package:admin_app/views/home.page.dart';
import 'package:admin_app/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            buildTopBar(),
            Expanded(
              child: _currentIndex == 3
                  ? ChatPage()
                  : _currentIndex == 2
                      ? HomePage() // Display HomePage when index is 2
                      : Center(
                          child: Text('Welcome to Page $_currentIndex'),
                        ),
            ),
            BottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopBar() {
    return const Column(
      children: [],
    );
  }
}
