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
              color: Colors.white,
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
              color: Colors.white,
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
              color: Colors.white,
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
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 4,
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.propane_tank_rounded, size: 30),
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
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 4,
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.trolley, size: 30),
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

class StocksIcon extends StatelessWidget {
  final Future<int> Function() fetchLowStockCount;

  StocksIcon({required this.fetchLowStockCount});

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
            stocksRoute,
            arguments: lowStockCount,
          );
        },
        child: Column(
          children: [
            Stack(
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  elevation: 4,
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.inventory_rounded, size: 30),
                  ),
                ),
                if (lowStockCount <= 9 && lowStockCount > 0)
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
                        lowStockCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (lowStockCount >= 10)
                  Positioned(
                    top: 3.8,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1.4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFd41111).withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        lowStockCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const Text(
              "Stocks",
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
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 4,
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

class FailedTransactionsIcon extends StatelessWidget {
  final VoidCallback onTap;

  FailedTransactionsIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 4,
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.error_outline, size: 30),
              ),
            ),
          ),
          const Text(
            "Failed Transactions",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class AppointmentIcon extends StatelessWidget {
  final Future<int> Function() fetchAppointments;

  AppointmentIcon({required this.fetchAppointments});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: fetchAppointments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildIconWithCount(context, 0);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          int appointmentCount = snapshot.data ?? 0;
          return _buildIconWithCount(context, appointmentCount);
        }
      },
    );
  }

  Widget _buildIconWithCount(BuildContext context, int appointmentCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            appointmentRoute,
            arguments: appointmentCount,
          );
        },
        child: Column(
          children: [
            Stack(
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  elevation: 4,
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.edit_calendar_rounded, size: 30),
                  ),
                ),
                if (appointmentCount <= 9 && appointmentCount > 0)
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
                        appointmentCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (appointmentCount >= 10)
                  Positioned(
                    top: 3.8,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1.4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFd41111).withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        appointmentCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const Text(
              "Appointments",
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
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
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 4,
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.announcement_outlined, size: 30),
              ),
            ),
          ),
          const Text(
            "Announcements",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class UpdatePriceIcon extends StatelessWidget {
  final VoidCallback onTap;

  UpdatePriceIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 4,
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.price_change_outlined, size: 30),
              ),
            ),
          ),
          const Text(
            "Update Price",
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
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 4,
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
