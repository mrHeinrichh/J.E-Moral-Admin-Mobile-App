import 'package:admin_app/routes/app_routes.dart';
import 'package:admin_app/widgets/circle_card.dart';
import 'package:admin_app/widgets/custom_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> transactions = [];
  String selectedRange = 'Today';

  List<Map<String, dynamic>> selectedTransactions = [];
  int currentPage = 1;
  int transactionsPerPage = 10;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (!mounted) {
      return; // Check if the widget is still mounted
    }

    final response = await http.get(
      Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/transactions'),
    );

    if (!mounted) {
      return; // Check again after the asynchronous operation
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      setState(() {
        transactions = List<Map<String, dynamic>>.from(
          data.where((item) => item['__t'] == 'Delivery'),
        );
      });
    }
  }

  int targetStock = 10;
  int outOfStock = 0;

  Future<int> fetchStock() async {
    final response = await http
        .get(Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/items/'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> allProductData = data['data'] as List<dynamic>;

      final int lowStockCount = allProductData.where((productData) {
        if (productData is Map<String, dynamic>) {
          final int stock = productData['stock'] ?? 0;
          return stock >= outOfStock && stock <= targetStock;
        }
        return false;
      }).length;

      return lowStockCount;
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

//TODAY
  double calculateTotalSumToday() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    double sum = 0.0;
    for (var transaction in transactions) {
      DateTime transactionDate = DateTime.parse(transaction['createdAt']);

      // Check if the transaction is on the current day and is approved
      if (transactionDate.year == today.year &&
          transactionDate.month == today.month &&
          transactionDate.day == today.day &&
          transaction['status'] == "Completed" &&
          transaction['__t'] == "Delivery" &&
          // transaction['__t'] == "Walkin" &&
          transaction['completed'] == true) {
        sum += (transaction['total'] ?? 0.0);
      }
    }
    return sum;
  }

//THIS MONTH
  int calculateTotalOnlineTransactionsNotApproved() {
    int count = 0;
    for (var transaction in transactions) {
      // Check if the transaction is of type "Online" and is not approved
      if (transaction['__t'] == "Delivery" &&
          transaction['status'] == "Pending") {
        count++;
      }
    }
    return count;
  }

//NUMBER OF TOTAL ONLINE TRANSACTIONS
  int calculateNumberOfOnlineTransactions() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    int onlineTransactionCount = 0;
    for (var transaction in transactions) {
      // Check if the transaction has type "Online"
      if (transaction['__t'] == 'Delivery') {
        onlineTransactionCount++;
      }
    }
    return onlineTransactionCount;
  }

  int calculateNumberOfOnlineTransactionsToday() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    int onlineTransactionCount = 0;
    for (var transaction in transactions) {
      DateTime transactionDate = DateTime.parse(transaction['createdAt']);

      // Check if the transaction has type "Online"
      if (transaction['__t'] == "Delivery" &&
          transaction['status'] == "Completed" &&
          transaction['completed'] == true &&
          transactionDate.year == today.year &&
          transactionDate.month == today.month &&
          transactionDate.day == today.day) {
        onlineTransactionCount++;
      }
    }
    return onlineTransactionCount;
  }

//DATATABLE TODAY
  List<Map<String, dynamic>> filterTransactionsForPeriod(
      List<Map<String, dynamic>> transactions, int periodInDays) {
    DateTime now = DateTime.now();
    DateTime cutoffDate = now.subtract(Duration(days: periodInDays));

    List<Map<String, dynamic>> filteredTransactions =
        transactions.where((transaction) {
      DateTime transactionDate = DateTime.parse(transaction['createdAt']);
      return transactionDate.isAfter(cutoffDate) &&
              transactionDate.year == now.year &&
              transaction['__t'] == 'Delivery' ||
          transaction['__t'] == 'Walkin' &&
              transaction['status'] == 'Completed';
    }).toList();

    // Sort the filtered transactions in descending order based on createdAt
    filteredTransactions.sort((a, b) {
      DateTime dateA = DateTime.parse(a['createdAt']);
      DateTime dateB = DateTime.parse(b['createdAt']);
      return dateB.compareTo(dateA);
    });

    return filteredTransactions;
  }

//DATATABLE MONTH
  List<Map<String, dynamic>> filterTransactionsForCurrentMonth(
      List<Map<String, dynamic>> transactions) {
    DateTime now = DateTime.now();

    List<Map<String, dynamic>> filteredTransactions =
        transactions.where((transaction) {
      DateTime transactionDate = DateTime.parse(transaction['createdAt']);
      return transactionDate.month == now.month &&
          transactionDate.year == now.year;
    }).toList();

    // Sort the filtered transactions in descending order based on createdAt
    filteredTransactions.sort((a, b) {
      DateTime dateA = DateTime.parse(a['createdAt']);
      DateTime dateB = DateTime.parse(b['createdAt']);
      return dateB.compareTo(dateA);
    });

    return filteredTransactions;
  }

//DATATABLE YEAR
  List<Map<String, dynamic>> filterTransactionsForThisYear(
      List<Map<String, dynamic>> transactions) {
    DateTime now = DateTime.now();
    int currentYear = now.year;

    List<Map<String, dynamic>> filteredTransactions =
        transactions.where((transaction) {
      DateTime transactionDate = DateTime.parse(transaction['createdAt']);
      return transactionDate.year == currentYear;
    }).toList();

    // Sort the filtered transactions in descending order based on createdAt
    filteredTransactions.sort((a, b) {
      DateTime dateA = DateTime.parse(a['createdAt']);
      DateTime dateB = DateTime.parse(b['createdAt']);
      return dateB.compareTo(dateA);
    });

    return filteredTransactions;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> selectedTransactions = [];
    List<Map<String, dynamic>> chartData = [];

    if (selectedRange == 'Today') {
      selectedTransactions = filterTransactionsForPeriod(transactions, 1);
    } else if (selectedRange == 'This Month') {
      selectedTransactions = filterTransactionsForCurrentMonth(transactions);
    } else if (selectedRange == 'This Year') {
      selectedTransactions = filterTransactionsForThisYear(transactions);
    }
    //TOTAL UNDER DATATABLE
    double calculateTotalRevenueForToday() {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      double totalRevenue = 0.0;

      for (var transaction in selectedTransactions) {
        DateTime transactionDate = DateTime.parse(transaction['createdAt']);

        // Check if the transaction is on the current day and is approved
        if (transaction['__t'] == "Delivery" &&
            transaction['status'] != "Declined" &&
            transaction['status'] != "Cancelled" &&
            transaction['status'] != "On Going" &&
            transaction['status'] != "Pending" &&
            transaction['completed'] == true) {
          totalRevenue += (transaction['total'] ?? 0.0);
        }
      }

      return totalRevenue;
    }

    List<PieChartSectionData> selectedSections =
        createPieChartSections(selectedTransactions);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchData();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, walkinRoute);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF232937),
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_walk,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Walk-Ins',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        StocksIcon(
                          fetchLowStockCount: fetchStock,
                        ),
                        AppointmentIcon(
                          onTap: () {
                            Navigator.pushNamed(context, appointmentRoute);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Container(
                            width: 1,
                            height: 40,
                            color: const Color(0xFF232937),
                          ),
                        ),
                        EditProductIcon(
                          onTap: () {
                            Navigator.pushNamed(context, editItemsPage);
                          },
                        ),
                        EditRetailerProductIcon(
                          onTap: () {
                            Navigator.pushNamed(context, editRetailerItemsPage);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Container(
                            width: 1,
                            height: 40,
                            color: const Color(0xFF232937),
                          ),
                        ),
                        CustomerIcon(
                          onTap: () {
                            Navigator.pushNamed(context, customerRoute);
                          },
                        ),
                        RiderIcon(
                          onTap: () {
                            Navigator.pushNamed(context, driversRoute);
                          },
                        ),
                        ProductsIcon(
                          onTap: () {
                            Navigator.pushNamed(context, productsRoute);
                          },
                        ),
                        AccessoriesIcon(
                          onTap: () {
                            Navigator.pushNamed(context, accessoriesRoute);
                          },
                        ),
                        AnnouncementIcon(
                          onTap: () {
                            Navigator.pushNamed(context, announcementRoute);
                          },
                        ),
                        FaqIcon(
                          onTap: () {
                            Navigator.pushNamed(context, faqRoute);
                          },
                        ),
                        // FeedbackIcon(
                        //   onTap: () {
                        //     // Action to perform when the card is clicked
                        //   },
                        // ),
                        TransactionsIcon(
                          onTap: () {
                            Navigator.pushNamed(context, transactionRoute);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RectangleCard(
                      title: 'Today Revenue',
                      value: '\₱${calculateTotalSumToday().toStringAsFixed(2)}',
                    ),
                    RectangleCard(
                      title: 'Pending Online Orders',
                      value: '${calculateTotalOnlineTransactionsNotApproved()}',
                    ),
                    RectangleCard(
                      title: 'Completed Online Today',
                      value: '${calculateNumberOfOnlineTransactionsToday()}',
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    DropdownButton<String>(
                      value: selectedRange,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedRange = newValue!;
                        });
                      },
                      items: ['Today', 'This Month', 'This Year']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sections: selectedSections,
                          borderData: FlBorderData(show: false),
                          centerSpaceRadius: 40,
                          sectionsSpace: 0,
                          startDegreeOffset: -90,
                        ),
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    // height: 400,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Barangay')),
                        DataColumn(label: Text('Total')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Date')),
                      ],
                      rows: [
                        ...selectedTransactions
                            .where((transaction) =>
                                transaction['__t'] == "Delivery" &&
                                transaction['completed'] == true)
                            .map((transaction) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  transaction['name'].length > 10
                                      ? '${transaction['name'].substring(0, 10)}...'
                                      : transaction['name'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                Text(
                                  transaction['status'].length > 10
                                      ? '${transaction['status'].substring(0, 10)}...'
                                      : transaction['status'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                Text(
                                  transaction['barangay'].length > 10
                                      ? '${transaction['barangay'].substring(0, 10)}...'
                                      : transaction['barangay'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(Text(
                                  '\₱${(transaction['total'] ?? 0.0).toStringAsFixed(2)}')),
                              DataCell(Text(transaction['__t'])),
                              DataCell(
                                Text(
                                  DateFormat('MMM d, y - h:mm a').format(
                                      DateTime.parse(transaction['updatedAt'])),
                                ),
                              ),
                            ],
                          );
                        }),
                        DataRow(
                          cells: [
                            DataCell(Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataCell(Text(
                              '\₱${calculateTotalRevenueForToday().toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> createPieChartSections(
      List<Map<String, dynamic>> transactions) {
    List<Map<String, dynamic>> deliveryTransactions = [];
    List<Map<String, dynamic>> walkinTransactions = [];

    for (var transaction in transactions) {
      final type = transaction['__t'];
      final completed = transaction['completed'];
      final status = transaction['status'];
      final walk = transaction['__v'];

      if (type == 'Delivery' && completed == true && status == 'Completed') {
        deliveryTransactions.add(transaction);
      } else if (walk == 0) {
        walkinTransactions.add(transaction);
      }
    }

    double totalDeliveryCount = deliveryTransactions.length.toDouble();
    double totalWalkinCount = walkinTransactions.length.toDouble();
    double totalTransactionCount = totalDeliveryCount + totalWalkinCount;

    // Handle division by zero
    if (totalTransactionCount == 0) {
      return [];
    }

    return [
      PieChartSectionData(
        color: Colors.lime,
        value: totalDeliveryCount / totalTransactionCount * 100,
        title:
            'Delivery: ${totalDeliveryCount.toInt()} \n ${(totalDeliveryCount / totalTransactionCount * 100).toStringAsFixed(2)}%',
        radius: 80,
        titleStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: Colors.grey,
        value: totalWalkinCount / totalTransactionCount * 100,
        title:
            'Walkin: ${totalWalkinCount.toInt()} \n ${(totalWalkinCount / totalTransactionCount * 100).toStringAsFixed(2)}%',
        radius: 80,
        titleStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }
}
