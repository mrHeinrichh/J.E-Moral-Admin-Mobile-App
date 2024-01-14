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
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
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
              Icons.chat,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
