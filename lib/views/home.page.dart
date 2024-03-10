import 'package:admin_app/routes/app_routes.dart';
import 'package:admin_app/views/retailer.page.dart';
import 'package:admin_app/widgets/circle_card.dart';
import 'package:admin_app/widgets/custom_card.dart';
import 'package:admin_app/widgets/custom_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> transactions = [];
  String selectedRange = 'Today';
  bool loadingData = false;
  List<Map<String, dynamic>> selectedTransactions = [];
  int currentPage = 1;
  int transactionsPerPage = 10;

  @override
  void initState() {
    super.initState();
    loadingData = true;
    fetchData();
    totalRevenueToday();
    numberofTransactionsToday();
    fetchStock();
    fetchAppointment();
  }

  int targetStock = 7;
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

  Future<int> fetchAppointment() async {
    final response = await http.get(Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/users/?filter={"__t":"Customer","appointmentStatus":"Pending"}'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<Map<String, dynamic>> customerData = (data['data'] as List)
          .where((customerData) => customerData is Map<String, dynamic>)
          .map((customerData) => customerData as Map<String, dynamic>)
          .toList();

      final int appointmentCount = customerData.length;
      return appointmentCount;
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://lpg-api-06n8.onrender.com/api/v1/transactions?limit=10000'),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<Map<String, dynamic>> transactionData = (data['data']
                  as List)
              .where(
                  (transactionData) => transactionData is Map<String, dynamic>)
              .map((transactionData) => transactionData as Map<String, dynamic>)
              .toList();

          setState(() {
            transactions.clear();
            transactions.addAll(transactionData);
          });
        } else {}
      }
    } catch (e) {
      if (mounted) {
        print("Error: $e");
      }
    } finally {
      loadingData = false;
    }
  }

  double totalRevenueToday() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    double total = 0;
    for (var transaction in transactions) {
      try {
        DateTime transactionDate = DateTime.parse(transaction['updatedAt']);
        String? transactionType = transaction['__t'];

        if ((!transaction.containsKey('__t') &&
                    transaction['completed'] == true ||
                transactionType == "Delivery" &&
                    transaction['status'] == 'Completed' &&
                    transaction['completed'] == true) &&
            transactionDate.year == today.year &&
            transactionDate.month == today.month &&
            transactionDate.day == today.day) {
          total += transaction['total'];
        }
      } catch (e) {}
    }
    return total;
  }

  int numberofTransactionsToday() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    int transactionCount = 0;
    for (var transaction in transactions) {
      try {
        DateTime transactionDate = DateTime.parse(transaction['updatedAt']);
        String? transactionType = transaction['__t'];

        if ((!transaction.containsKey('__t') &&
                    transaction['completed'] == true ||
                transactionType == "Delivery" &&
                    transaction['status'] == 'Completed' &&
                    transaction['completed'] == true) &&
            transactionDate.year == today.year &&
            transactionDate.month == today.month &&
            transactionDate.day == today.day) {
          transactionCount++;
        }
      } catch (e) {}
    }
    return transactionCount;
  }

  List<Map<String, dynamic>> filterTransactionsForPeriod(
      List<Map<String, dynamic>> transactions, int periodInDays) {
    DateTime now = DateTime.now();
    DateTime cutoffDate = now.subtract(Duration(days: periodInDays));

    List<Map<String, dynamic>> filteredTransactions =
        transactions.where((transaction) {
      DateTime transactionDate = DateTime.parse(transaction['updatedAt']);
      String? transactionType = transaction['__t'];

      bool isTodayTransaction = transactionDate.year == now.year &&
          transactionDate.month == now.month &&
          transactionDate.day == now.day;

      return isTodayTransaction &&
          (!transaction.containsKey('__t') &&
                  transaction['completed'] == true ||
              transactionType == "Delivery" &&
                  transaction['status'] == 'Completed' &&
                  transaction['completed'] == true);
    }).toList();

    filteredTransactions.sort((a, b) {
      DateTime dateA = DateTime.parse(a['updatedAt']);
      DateTime dateB = DateTime.parse(b['updatedAt']);
      return dateB.compareTo(dateA);
    });

    return filteredTransactions;
  }

  List<Map<String, dynamic>> filterTransactionsForCurrentMonth(
      List<Map<String, dynamic>> transactions) {
    DateTime now = DateTime.now();

    List<Map<String, dynamic>> filteredTransactions =
        transactions.where((transaction) {
      DateTime transactionDate = DateTime.parse(transaction['updatedAt']);
      String? transactionType = transaction['__t'];

      bool isCurrentMonthTransaction = transactionDate.month == now.month &&
          transactionDate.year == now.year;

      return isCurrentMonthTransaction &&
          (!transaction.containsKey('__t') &&
                  transaction['completed'] == true ||
              transactionType == "Delivery" &&
                  transaction['status'] == 'Completed' &&
                  transaction['completed'] == true);
    }).toList();

    filteredTransactions.sort((a, b) {
      DateTime dateA = DateTime.parse(a['updatedAt']);
      DateTime dateB = DateTime.parse(b['updatedAt']);
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
      DateTime transactionDate = DateTime.parse(transaction['updatedAt']);
      String? transactionType = transaction['__t'];

      bool isCurrentYearTransaction = transactionDate.year == currentYear;

      return isCurrentYearTransaction &&
          (!transaction.containsKey('__t') &&
                  transaction['completed'] == true ||
              transactionType == "Delivery" &&
                  transaction['status'] == 'Completed' &&
                  transaction['completed'] == true);
    }).toList();

    filteredTransactions.sort((a, b) {
      DateTime dateA = DateTime.parse(a['updatedAt']);
      DateTime dateB = DateTime.parse(b['updatedAt']);
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
      selectedTransactions = filterTransactionsForCurrentMonth(transactions);
    } else if (selectedRange == 'This Year') {
      selectedTransactions = filterTransactionsForThisYear(transactions);
    }

    double calculateTotalRevenueForToday() {
      DateTime now = DateTime.now();
      DateTime pickedDate = DateTime(now.year, now.month, now.day);

      if (selectedRange == 'This Month') {
        pickedDate = DateTime(now.year, now.month, 1);
      } else if (selectedRange == 'This Year') {
        pickedDate = DateTime(now.year, 1, 1);
      }

      double totalRevenue = 0.0;

      for (var transaction in transactions) {
        try {
          DateTime transactionDate = DateTime.parse(transaction['updatedAt']);

          String? transactionType = transaction['__t'];

          bool isPickedYearTransaction =
              transactionDate.year == pickedDate.year;
          bool isPickedMonthTransaction =
              transactionDate.month == pickedDate.month &&
                  transactionDate.year == pickedDate.year;
          bool isPickedDayTransaction =
              transactionDate.year == pickedDate.year &&
                  transactionDate.month == pickedDate.month &&
                  transactionDate.day == pickedDate.day;

          if ((!transaction.containsKey('__t') &&
                      transaction['completed'] == true ||
                  transactionType == "Delivery" &&
                      transaction['status'] == 'Completed' &&
                      transaction['completed'] == true) &&
              (selectedRange == 'Today' && isPickedDayTransaction ||
                  selectedRange == 'This Month' && isPickedMonthTransaction ||
                  selectedRange == 'This Year' && isPickedYearTransaction)) {
            totalRevenue += transaction['total'];
          }
        } catch (e) {
          print('Error processing transaction: $e');
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
        elevation: 1,
        title: Text(
          "Dashboard",
          style: TextStyle(
            color: const Color(0xFF050404).withOpacity(0.9),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: const Color(0xFF050404).withOpacity(0.8),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.black,
            height: 0.2,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: loadingData
          ? Center(
              child: LoadingAnimationWidget.flickr(
                leftDotColor: const Color(0xFF050404).withOpacity(0.8),
                rightDotColor: const Color(0xFFd41111).withOpacity(0.8),
                size: 40,
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await fetchData();
                totalRevenueToday();
                numberofTransactionsToday();
                await fetchStock();
                await fetchAppointment();
              },
              color: const Color(0xFF050404),
              strokeWidth: 2.5,
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
                          backgroundColor:
                              const Color(0xFF050404).withOpacity(0.9),
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
                                fetchAppointments: fetchAppointment,
                              ),
                              UpdatePriceIcon(
                                onTap: () {
                                  Navigator.pushNamed(context, editItemsPage);
                                },
                              ),
                              CustomerIcon(
                                onTap: () {
                                  Navigator.pushNamed(context, customerRoute);
                                },
                              ),
                              RetailerIcon(
                                onTap: () {
                                  Navigator.pushNamed(context, retailerRoute);
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
                                  Navigator.pushNamed(
                                      context, accessoriesRoute);
                                },
                              ),
                              AnnouncementIcon(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, announcementRoute);
                                },
                              ),
                              FaqIcon(
                                onTap: () {
                                  Navigator.pushNamed(context, faqRoute);
                                },
                              ),
                              TransactionsIcon(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, transactionCompletedRoute);
                                },
                              ),
                              FailedTransactionsIcon(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, transactionCancelledRoute);
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
                            title: 'Today\'s Revenue',
                            value:
                                '₱${NumberFormat.decimalPattern().format(double.parse((totalRevenueToday()).toStringAsFixed(2)))}',
                          ),
                          RectangleCard(
                            title: 'Completed Today',
                            value: '${numberofTransactionsToday()}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
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
                          child: DataTable(
                            dataRowMaxHeight: double.infinity,
                            columns: const [
                              DataColumn(label: Text('Ordered by')),
                              DataColumn(label: Text('Type')),
                              DataColumn(label: Text('Item/s')),
                              DataColumn(label: Text('Discount')),
                              DataColumn(label: Text('Total')),
                              DataColumn(label: Text('Date Delivered')),
                            ],
                            rows: [
                              ...selectedTransactions
                                  .where((transaction) => (!transaction
                                              .containsKey('__t') &&
                                          transaction['completed'] == true ||
                                      transaction['__t'] == "Delivery" &&
                                          transaction['status'] ==
                                              'Completed' &&
                                          transaction['completed'] == true))
                                  .map((transaction) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      !transaction.containsKey('__t')
                                          ? const BodyMedium(text: "Customer")
                                          : (!transaction.containsKey(
                                                      'discountIdImage') &&
                                                  transaction['discounted'] ==
                                                      false)
                                              ? const BodyMedium(
                                                  text: "Retailer")
                                              : const BodyMedium(
                                                  text: "Customer"),
                                    ),
                                    DataCell(
                                      !transaction.containsKey('__t')
                                          ? const BodyMedium(text: "Walkins")
                                          : const BodyMedium(text: "Delivery"),
                                    ),
                                    DataCell(
                                      transaction.containsKey(
                                                  'discountIdImage') ||
                                              !transaction.containsKey('__t')
                                          ? DataCellMedium(
                                              text: '${transaction['items']!.map((item) {
                                                    if (item is Map<String,
                                                            dynamic> &&
                                                        item.containsKey(
                                                            'name') &&
                                                        item.containsKey(
                                                            'quantity') &&
                                                        item.containsKey(
                                                            'customerPrice')) {
                                                      final itemName =
                                                          item['name'];
                                                      final quantity =
                                                          item['quantity'];
                                                      final price = NumberFormat
                                                              .decimalPattern()
                                                          .format(double.parse(
                                                              (item['customerPrice'])
                                                                  .toStringAsFixed(
                                                                      2)));

                                                      return '$itemName ₱$price (x$quantity)';
                                                    }
                                                  }).join(', ').replaceAll(', ', ',\n')}',
                                            )
                                          : (!transaction.containsKey(
                                                      'discountIdImage') &&
                                                  transaction['discounted'] ==
                                                      false)
                                              ? DataCellMedium(
                                                  text: '${transaction['items']!.map((item) {
                                                        if (item is Map<String,
                                                                dynamic> &&
                                                            item.containsKey(
                                                                'name') &&
                                                            item.containsKey(
                                                                'quantity') &&
                                                            item.containsKey(
                                                                'retailerPrice')) {
                                                          final itemName =
                                                              item['name'];
                                                          final quantity =
                                                              item['quantity'];
                                                          final price = NumberFormat
                                                                  .decimalPattern()
                                                              .format(double
                                                                  .parse((item[
                                                                          'retailerPrice'])
                                                                      .toStringAsFixed(
                                                                          2)));

                                                          return '$itemName ₱$price (x$quantity)';
                                                        }
                                                      }).join(', ').replaceAll(', ', ',\n')}',
                                                )
                                              : const SizedBox.shrink(),
                                    ),
                                    DataCell(
                                      (transaction.containsKey(
                                                  'discountIdImage') ||
                                              !transaction.containsKey('__t'))
                                          ? (!transaction.containsKey('__t')
                                              ? PlainBodyMedium(
                                                  text: transaction[
                                                              'discounted'] ==
                                                          true
                                                      ? 'Discounted'
                                                      : 'Not Discounted')
                                              : PlainBodyMedium(
                                                  text: transaction[
                                                                  'discountIdImage'] !=
                                                              null ||
                                                          transaction[
                                                                  'discountIdImage'] !=
                                                              ""
                                                      ? 'Discounted'
                                                      : 'Not Discounted'))
                                          : ((!transaction.containsKey(
                                                      'discountIdImage')) &&
                                                  (transaction['discounted'] ==
                                                      false)
                                              ? const SizedBox.shrink()
                                              : const SizedBox.shrink()),
                                    ),
                                    DataCell(
                                      PlainBodyMedium(
                                          text:
                                              '₱${NumberFormat.decimalPattern().format(double.parse((transaction['total'] ?? 0.0).toStringAsFixed(2)))}'),
                                    ),
                                    DataCell(
                                      PlainBodyMedium(
                                        text: DateFormat('MMMM d, y').format(
                                            DateTime.parse(
                                                transaction['updatedAt'])),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              DataRow(
                                cells: [
                                  const DataCell(Text('')),
                                  const DataCell(Text('')),
                                  const DataCell(Text('')),
                                  const DataCell(
                                    BodyMedium(
                                      text: 'Total:',
                                    ),
                                  ),
                                  DataCell(
                                    BodyMedium(
                                      text:
                                          '₱${NumberFormat.decimalPattern().format(double.parse((calculateTotalRevenueForToday()).toStringAsFixed(2)))}',
                                    ),
                                  ),
                                  const DataCell(Text('')),
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

      if (type == 'Delivery' &&
          type == 'Delivery' &&
          completed == true &&
          status == 'Completed') {
        deliveryTransactions.add(transaction);
      } else if (walk == 0) {
        walkinTransactions.add(transaction);
      }
    }

    double totalDeliveryCount = deliveryTransactions.length.toDouble();
    double totalWalkinCount = walkinTransactions.length.toDouble();
    double totalTransactionCount = totalDeliveryCount + totalWalkinCount;

    if (totalTransactionCount == 0) {
      return [];
    }

    return [
      PieChartSectionData(
        color: const Color(0xFF050404).withOpacity(0.8),
        value: totalDeliveryCount / totalTransactionCount * 100,
        title:
            'Delivery: ${totalDeliveryCount.toInt()} \n ${(totalDeliveryCount / totalTransactionCount * 100).toStringAsFixed(2)}%',
        radius: 110,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFFA81616).withOpacity(0.8),
        value: totalWalkinCount / totalTransactionCount * 100,
        title:
            'Walkin: ${totalWalkinCount.toInt()} \n ${(totalWalkinCount / totalTransactionCount * 100).toStringAsFixed(2)}%',
        radius: 110,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }
}
