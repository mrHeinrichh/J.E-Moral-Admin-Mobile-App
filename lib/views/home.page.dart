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
              (item) => item['type'] == 'Walkin' || item['type'] == '{Online}'),
        );
      });
    }
  }

  double calculateTotalSum() {
    double sum = 0.0;
    for (var transaction in transactions) {
      sum += (transaction['total'] ?? 0.0);
    }
    return sum;
  }

  List<Map<String, dynamic>> filterTransactionsForPeriod(
      List<Map<String, dynamic>> transactions, int periodInDays) {
    DateTime now = DateTime.now();
    DateTime cutoffDate = now.subtract(Duration(days: periodInDays));
    return transactions.where((transaction) {
      DateTime transactionDate = DateTime.parse(transaction['createdAt']);
      return transactionDate.isAfter(cutoffDate);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> selectedTransactions = [];

    if (selectedRange == 'Today') {
      selectedTransactions = filterTransactionsForPeriod(transactions, 1);
    } else if (selectedRange == 'Monthly') {
      selectedTransactions = filterTransactionsForPeriod(transactions, 30);
    } else if (selectedRange == 'Yearly') {
      selectedTransactions = filterTransactionsForPeriod(transactions, 365);
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
                  items: ['Today', 'Monthly', 'Yearly']
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
                      title: 'Total',
                      value: '\₱${calculateTotalSum().toStringAsFixed(2)}',
                    ),
                    RectangleCard(
                      title: 'Total',
                      value: '\₱${calculateTotalSum().toStringAsFixed(2)}',
                    ),
                    RectangleCard(
                      title: 'Total',
                      value: '\₱${calculateTotalSum().toStringAsFixed(2)}',
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
                  rows: selectedTransactions.map((transaction) {
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
      Color textColor = Colors.black; // Default text color

      if (transaction['type'] == 'Walkin') {
        sectionTitle = 'Walkin ${percentage.toStringAsFixed(2)}%';
        textColor = Colors.black;
      } else if (transaction['type'] == '{Online}') {
        sectionTitle = 'Online ${percentage.toStringAsFixed(2)}%';
        textColor = Colors.black; // Customize text color for Online
      }

      return PieChartSectionData(
        color: Color(int.parse(
          '0xFF${(transaction['count'] * 25).toRadixString(16).padLeft(2, '0')}434931',
        )),
        value: percentage * 100, // Percentage value
        title: sectionTitle,
        radius: 75,
        titleStyle: TextStyle(
          color: textColor, // Apply the customized text color
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
        borderRadius: BorderRadius.circular(25.0), // Make the card circular
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
