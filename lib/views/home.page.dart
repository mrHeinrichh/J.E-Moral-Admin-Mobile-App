import 'package:admin_app/routes/app_routes.dart';
import 'package:admin_app/widgets/circle_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> transactions = [];
  String selectedRange = 'Today';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/transactions'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      setState(() {
        transactions = List<Map<String, dynamic>>.from(
          data.where(
              (item) => item['type'] == 'Walkin' || item['type'] == 'Online'),
        );
      });
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
          transaction['isApproved'] == true &&
          transaction['completed'] == true) {
        sum += (transaction['total'] ?? 0.0);
      }
    }
    return sum;
  }

//THIS MONTH
  double calculateTotalSumThisMonth() {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);

    double sum = 0.0;
    for (var transaction in transactions) {
      DateTime transactionDate = DateTime.parse(transaction['createdAt']);

      // Check if the transaction is within the current month
      if (transactionDate.isAfter(startOfMonth.subtract(Duration(days: 1)))) {
        sum += (transaction['total'] ?? 0.0);
      }
    }
    return sum;
  }

//NUMBER OF TRANSACTION TODAY
  int calculateNumberOfTransactionsToday() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    int transactionCount = 0;
    for (var transaction in transactions) {
      DateTime transactionDate = DateTime.parse(transaction['createdAt']);

      // Check if the transaction is on the current day
      if (transactionDate.year == today.year &&
          transactionDate.month == today.month &&
          transactionDate.day == today.day) {
        transactionCount++;
      }
    }
    return transactionCount;
  }

//DATATABLE TODAY
  List<Map<String, dynamic>> filterTransactionsForPeriod(
      List<Map<String, dynamic>> transactions, int periodInDays) {
    DateTime now = DateTime.now();
    DateTime cutoffDate = now.subtract(Duration(days: periodInDays));

    List<Map<String, dynamic>> filteredTransactions =
        transactions.where((transaction) {
      DateTime transactionDate = DateTime.parse(transaction['createdAt']);
      return transactionDate.isAfter(cutoffDate);
    }).toList();

    // Sort the filtered transactions in descending order based on createdAt
    filteredTransactions.sort((a, b) {
      DateTime dateA = DateTime.parse(a['createdAt']);
      DateTime dateB = DateTime.parse(b['createdAt']);
      return dateB.compareTo(dateA);
    });

    return filteredTransactions;
  }

  List<Map<String, dynamic>> filterTransactionsForTodayAndMonth(
      List<Map<String, dynamic>> transactions) {
    DateTime now = DateTime.now();
    int currentDay = now.day;

    List<Map<String, dynamic>> filteredTransactions =
        transactions.where((transaction) {
      DateTime transactionDate = DateTime.parse(transaction['createdAt']);
      return transactionDate.month == now.month &&
          transactionDate.day == currentDay;
    }).toList();

    // Sort the filtered transactions in descending order based on createdAt
    filteredTransactions.sort((a, b) {
      DateTime dateA = DateTime.parse(a['createdAt']);
      DateTime dateB = DateTime.parse(b['createdAt']);
      return dateB.compareTo(dateA);
    });

    return filteredTransactions;
  }

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

    if (selectedRange == 'Today') {
      selectedTransactions = filterTransactionsForPeriod(transactions, 1);
    } else if (selectedRange == 'This Month') {
      selectedTransactions = filterTransactionsForTodayAndMonth(transactions);
    } else if (selectedRange == 'This Year') {
      selectedTransactions = filterTransactionsForThisYear(transactions);
    }

    List<PieChartSectionData> selectedSections =
        createPieChartSections(selectedTransactions);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Dashboard",
          style: TextStyle(color: Colors.black),
        ),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      WalkInIcon(
                        onTap: () {
                          Navigator.pushNamed(context, walkinRoute);
                        },
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
                      TransactionsIcon(
                        onTap: () {
                          Navigator.pushNamed(context, transactionRoute);
                        },
                      ),
                      AppointmentIcon(
                        onTap: () {
                          Navigator.pushNamed(context, appointmentRoute);
                        },
                      ),
                      FeedbackIcon(
                        onTap: () {
                          // Action to perform when the card is clicked
                        },
                      ),
                    ],
                  ),
                ),
              ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RectangleCard(
                      title: 'Total Revenue',
                      value: '\₱${calculateTotalSumToday().toStringAsFixed(2)}',
                    ),
                    RectangleCard(
                      title: 'Total Profit',
                      value:
                          '\₱${calculateTotalSumThisMonth().toStringAsFixed(2)}',
                    ),
                    RectangleCard(
                      title: 'Transaction',
                      value: '\₱${calculateNumberOfTransactionsToday()}',
                    ),
                  ],
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                height: 400,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Total')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Date')),
                  ],
                  rows: selectedTransactions
                      .where((transaction) =>
                          transaction['isApproved'] == true &&
                          transaction['completed'] == true)
                      .map((transaction) {
                    return DataRow(
                      cells: [
                        DataCell(Text(transaction['name'])),
                        DataCell(Text(
                            '\₱${(transaction['total'] ?? 0.0).toStringAsFixed(2)}')),
                        DataCell(Text(transaction['type'])),
                        DataCell(
                          Text(transaction['createdAt']),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> createPieChartSections(
      List<Map<String, dynamic>> transactions) {
    List<Map<String, dynamic>> transactionTypes = [];

    for (var transaction in transactions) {
      final type = transaction['type'];
      if (type != null) {
        if (transactionTypes.any((element) => element['type'] == type)) {
          final index =
              transactionTypes.indexWhere((element) => element['type'] == type);
          transactionTypes[index]['count']++;
        } else {
          transactionTypes.add({'type': type, 'count': 1});
        }
      }
    }

    double totalTransactionCount = transactionTypes.fold(
        0, (sum, transaction) => sum + (transaction['count'] ?? 0));

    return transactionTypes.map((transaction) {
      double percentage = (transaction['count'] ?? 0) / totalTransactionCount;

      String sectionTitle = '';
      Color sectionColor = Colors.black; // Default color

      if (transaction['type'] == 'Walkin') {
        sectionTitle = 'Walkin ${percentage.toStringAsFixed(2)}%';
        sectionColor = Colors.grey; // Black color for Walkin
      } else if (transaction['type'] == 'Online') {
        sectionTitle = 'Online ${percentage.toStringAsFixed(2)}%';
        sectionColor = Colors.lime;
      }

      return PieChartSectionData(
        color: sectionColor,
        value: percentage * 100,
        title: sectionTitle,
        radius: 75,
        titleStyle: TextStyle(
          color: Colors.black, // Text color
        ),
      );
    }).toList();
  }
}

class RectangleCard extends StatelessWidget {
  final String title;
  final String value;

  RectangleCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0), // Make the card circular
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
