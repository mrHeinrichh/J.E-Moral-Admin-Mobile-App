import 'package:admin_app/routes/app_routes.dart';
import 'package:admin_app/views/accessory.page.dart';
import 'package:admin_app/views/active_orders.page.dart';
import 'package:admin_app/views/appointment.page.dart';
import 'package:admin_app/views/chat.page.dart';
import 'package:admin_app/views/customer.page.dart';
import 'package:admin_app/views/dashboard.page.dart';
import 'package:admin_app/views/drivers.page.dart';
import 'package:admin_app/views/ediIitems.dart';
import 'package:admin_app/views/editRetailerItems.dart';
import 'package:admin_app/views/newCustomers.page.dart';
import 'package:admin_app/views/product_details.page.dart';
import 'package:admin_app/views/products.page.dart';
import 'package:admin_app/views/login.page.dart';
import 'package:admin_app/views/set_delivery.page.dart';
import 'package:admin_app/views/transaction.page.dart';
import 'package:admin_app/views/user_provider.dart';
import 'package:admin_app/views/walkin.page.dart';
import 'package:admin_app/views/announcement.page.dart';
import 'package:admin_app/views/faq.page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_app/views/cart.page.dart' as CartView;
import 'package:admin_app/views/cart_provider.dart' as CartProviderView;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => UserProvider()), // Add UserProvider
        ChangeNotifierProvider(create: (context) => MessageProvider()),
        ChangeNotifierProvider(
            create: (context) => CartProviderView.CartProvider()),
      ],
      child: MyApp(),
    ),
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
        walkinRoute: (context) => WalkinPage(),
        cartRoute: (context) => CartView.CartPage(),
        setDeliveryPage: (context) => SetDeliveryPage(),
        editItemsPage: (context) => EditItemsPage(),
        editRetailerItemsPage: (context) => EditRetailerItemsPage(),

        transactionRoute: (context) => transactionPage(),
        appointmentRoute: (context) => AppointmentPage(),
        newCustomerRoute: (context) => NewCustomers(),
        activeOrdersRoute: (context) => ActiveOrders(),
        announcementRoute: (context) => AnnouncementPage(),

        faqRoute: (context) => FaqPage(),
        productDetailsPage: (context) {
          const productName = "Placeholder Name";
          const productPrice = "Placeholder Price";
          const productImageUrl = "Placeholder Image URL";
          const description = "Placeholder Description";
          const weight = "Placeholder Weight";
          const stock = "Placeholder Stock";

          return ProductDetailsPage(
            productName: productName,
            productPrice: productPrice,
            productImageUrl: productImageUrl,
            category: "Placeholder Category Name",
            description: description,
            weight: weight,
            stock: stock,
          );
        },
      },
    );
  }
}
