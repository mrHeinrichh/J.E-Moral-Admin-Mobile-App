import 'package:admin_app/routes/app_routes.dart';
import 'package:admin_app/views/accessory.page.dart';
import 'package:admin_app/views/appointment.page.dart';
import 'package:admin_app/views/customer.page.dart';
import 'package:admin_app/views/dashboard.page.dart';
import 'package:admin_app/views/drivers.page.dart';
import 'package:admin_app/views/products.page.dart';
import 'package:admin_app/views/login.page.dart';
import 'package:admin_app/views/transaction.page.dart';
import 'package:admin_app/views/walkin.page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      initialRoute: loginRoute, // Set the initial route
      routes: {
        loginRoute: (context) => LoginPage(), // Use the imported route
        dashboardRoute: (context) => DashboardPage(),
        customerRoute: (context) => CustomerPage(),
        driversRoute: (context) => DriversPage(),
        productsRoute: (context) => ProductsPage(),
        accessoriesRoute: (context) => AccessoryPage(),
        walkinRoute: (context) => walkinPage(),
        transactionRoute: (context) => transactionPage(),
        appointmentRoute: (context) => AppointmentPage(),
      },
    );
  }
}
