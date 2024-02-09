import 'package:admin_app/routes/app_routes.dart';
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
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 4,
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
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 4,
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.groups_2_rounded,
                    size: 30), //supervised_user_circle_rounded
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
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 4,
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.delivery_dining_rounded, size: 30),
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
  final Future<int> Function() fetchLowStockCount;

  ProductsIcon({required this.fetchLowStockCount});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: fetchLowStockCount(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildIconWithCount(context, 0);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          int lowStockCount = snapshot.data ?? 0;
          return _buildIconWithCount(context, lowStockCount);
        }
      },
    );
  }

  Widget _buildIconWithCount(BuildContext context, int lowStockCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            productsRoute,
            arguments: lowStockCount,
          );
        },
        child: Column(
          children: [
            Stack(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  elevation: 4,
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.propane_tank_rounded, size: 30),
                  ),
                ),
                if (lowStockCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        lowStockCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const Text(
              "Products",
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class AccessoriesIcon extends StatelessWidget {
  final Future<int> Function() fetchLowStockCount;

  AccessoriesIcon({required this.fetchLowStockCount});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: fetchLowStockCount(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildIconWithCount(context, 0);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          int lowStockCount = snapshot.data ?? 0;
          return _buildIconWithCount(context, lowStockCount);
        }
      },
    );
  }

  Widget _buildIconWithCount(BuildContext context, int lowStockCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            accessoriesRoute,
            arguments: lowStockCount,
          );
        },
        child: Column(
          children: [
            Stack(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  elevation: 4,
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.trolley, size: 30),
                  ),
                ),
                if (lowStockCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        lowStockCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const Text(
              "Accessories",
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
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
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 4,
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.edit_calendar_rounded, size: 30),
              ),
            ),
          ),
          const Text(
            "Appointments",
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

class EditProductIcon extends StatelessWidget {
  final VoidCallback onTap;

  EditProductIcon({required this.onTap});

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
                child: Icon(Icons.edit, size: 30),
              ),
            ),
          ),
          const Text(
            "Customer Prices",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class EditRetailerProductIcon extends StatelessWidget {
  final VoidCallback onTap;

  EditRetailerProductIcon({required this.onTap});

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
                child: Icon(Icons.edit, size: 30),
              ),
            ),
          ),
          const Text(
            "Retailer Prices",
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
