import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        unselectedItemColor: const Color(0xFFB3B3B3),
        selectedItemColor: const Color(0xFF232937),
        iconSize: 30,
        selectedLabelStyle: const TextStyle(
          fontSize: 0,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 0,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Image.network(
              'https://raw.githubusercontent.com/mrHeinrichh/J.E-Moral-cdn/main/assets/png/add_customer.png',
              width: 24,
              height: 24,
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.delivery_dining_outlined,
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.chat,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
