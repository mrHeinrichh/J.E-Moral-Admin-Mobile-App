import 'package:flutter/material.dart';

class WalkInIcon extends StatelessWidget {
  final VoidCallback onTap;

  WalkInIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(25.0), // Make the card circular
              ),
              elevation: 4, // Add a shadow to the card
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.directions_walk_outlined, size: 30),
              ),
            ),
          ),
          const Text(
            "Walk-Ins",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class CustomerIcon extends StatelessWidget {
  final VoidCallback onTap;

  CustomerIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(25.0), // Make the card circular
              ),
              elevation: 4, // Add a shadow to the card
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.account_circle, size: 30),
              ),
            ),
          ),
          const Text(
            "Customers",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class RiderIcon extends StatelessWidget {
  final VoidCallback onTap;

  RiderIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(25.0), // Make the card circular
              ),
              elevation: 4, // Add a shadow to the card
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.motorcycle_outlined, size: 30),
              ),
            ),
          ),
          const Text(
            "Drivers",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class ProductsIcon extends StatelessWidget {
  final VoidCallback onTap;

  ProductsIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(25.0), // Make the card circular
              ),
              elevation: 4, // Add a shadow to the card
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.receipt_long_outlined, size: 30),
              ),
            ),
          ),
          const Text(
            "Products",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class AccessoriesIcon extends StatelessWidget {
  final VoidCallback onTap;

  AccessoriesIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(25.0), // Make the card circular
              ),
              elevation: 4, // Add a shadow to the card
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.receipt_long_outlined, size: 30),
              ),
            ),
          ),
          const Text(
            "Accessories",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class TransactionsIcon extends StatelessWidget {
  final VoidCallback onTap;

  TransactionsIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(25.0), // Make the card circular
              ),
              elevation: 4, // Add a shadow to the card
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.payment_outlined, size: 30),
              ),
            ),
          ),
          const Text(
            "Transactions",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class AppointmentIcon extends StatelessWidget {
  final VoidCallback onTap;

  AppointmentIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(25.0), // Make the card circular
              ),
              elevation: 4, // Add a shadow to the card
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.calendar_month_outlined, size: 30),
              ),
            ),
          ),
          const Text(
            "Appointment",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class FeedbackIcon extends StatelessWidget {
  final VoidCallback onTap;

  FeedbackIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(25.0), // Make the card circular
              ),
              elevation: 4, // Add a shadow to the card
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.message_outlined, size: 30),
              ),
            ),
          ),
          const Text(
            "Feedback",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class AnnouncementIcon extends StatelessWidget {
  final VoidCallback onTap;

  AnnouncementIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(25.0), // Make the card circular
              ),
              elevation: 4, // Add a shadow to the card
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.announcement_outlined, size: 30),
              ),
            ),
          ),
          const Text(
            "Announcement",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class FaqIcon extends StatelessWidget {
  final VoidCallback onTap;

  FaqIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(25.0), // Make the card circular
              ),
              elevation: 4, // Add a shadow to the card
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.question_answer_sharp, size: 30),
              ),
            ),
          ),
          const Text(
            "FAQs",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
