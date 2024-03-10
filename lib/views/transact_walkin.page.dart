import 'package:admin_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Transaction_WalkinPage extends StatefulWidget {
  @override
  _Transaction_WalkinPageState createState() => _Transaction_WalkinPageState();
}

class _Transaction_WalkinPageState extends State<Transaction_WalkinPage> {
  List<Map<String, dynamic>> transactionDataList = [];
  TextEditingController searchController = TextEditingController();
  bool loadingData = false;
  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadingData = true;
    fetchData();
  }

  int currentPage = 1;
  int limit = 10;

  Future<void> fetchData({int page = 1}) async {
    try {
      final response = await http.get(Uri.parse(
          'https://lpg-api-06n8.onrender.com/api/v1/transactions/?page=$page&limit=$limit'));

      if (_mounted) {
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<Map<String, dynamic>> transactionData = (data['data']
                  as List)
              .where(
                  (transactionData) => transactionData is Map<String, dynamic>)
              .where((transactionData) => transactionData['__t'] != 'Delivery')
              .map((transactionData) => transactionData as Map<String, dynamic>)
              .toList();

          setState(() {
            transactionDataList.clear();
            transactionDataList.addAll(transactionData);
            currentPage = page;
            loadingData = false;
          });
        } else {
          throw Exception('Failed to load data from the API');
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      if (_mounted) {
        print("Error: $e");
      }
    }
  }

  Future<void> search(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://lpg-api-06n8.onrender.com/api/v1/transactions/?search=$query&limit=10000'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> filteredData = (data['data'] as List)
          .where((transactionData) =>
              transactionData is Map<String, dynamic> &&
              transactionData.containsKey('__t') &&
              (transactionData['_id']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  transactionData['name']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  transactionData['contactNumber']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  transactionData['items']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  transactionData['total']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  (_isDiscountedQuery(query) &&
                      transactionData['discounted'] == true)))
          .map((transactionData) => transactionData as Map<String, dynamic>)
          .toList();

      setState(() {
        transactionDataList = filteredData;
      });
    } else {
      // Handle error
    }
  }

  bool _isDiscountedQuery(String query) {
    return query.toLowerCase() == 'discounted';
  }

  void archiveData(String id) async {
    Map<String, dynamic> transactionToEdit =
        transactionDataList.firstWhere((data) => data['_id'] == id);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Archive Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyMediumOver(
                    text: 'Transaction ID: ${transactionToEdit['_id']}',
                  ),
                  const Divider(),
                  BodyMediumOver(
                    text:
                        'Date Ordered: ${DateFormat('MMMM d, y - h:mm a ').format(DateTime.parse(transactionToEdit['createdAt']))}',
                  ),
                  BodyMediumText(
                    text:
                        'Discounted: ${transactionToEdit['discountIdImage'] != null ? 'Yes' : 'No'}',
                  ),
                  BodyMediumOver(
                    text: 'Items: ${transactionToEdit['items']!.map((item) {
                      if (item is Map<String, dynamic> &&
                          item.containsKey('name') &&
                          item.containsKey('quantity') &&
                          item.containsKey('customerPrice')) {
                        final itemName = item['name'];
                        final quantity = item['quantity'];
                        final price = NumberFormat.decimalPattern().format(
                            double.parse(
                                (item['customerPrice']).toStringAsFixed(2)));

                        return '$itemName (₱$price x $quantity)';
                      }
                    }).join(', ')}',
                  ),
                  BodyMediumText(
                    text:
                        'Total: ₱${NumberFormat.decimalPattern().format(double.parse((transactionToEdit['total']).toStringAsFixed(2)))}',
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    'Are you sure you want to Archive this data?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFd41111).withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF050404).withOpacity(0.8),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final url = Uri.parse(
                    'https://lpg-api-06n8.onrender.com/api/v1/faqs/$id');
                final response = await http.delete(url);

                if (response.statusCode == 200) {
                  setState(() {
                    transactionDataList
                        .removeWhere((data) => data['_id'] == id);
                  });

                  fetchData();
                  Navigator.pop(context);
                } else {
                  print(
                      'Failed to archive the data. Status code: ${response.statusCode}');
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFd41111).withOpacity(0.9),
              ),
              child: const Text(
                'Archive',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loadingData
          ? Center(
              child: LoadingAnimationWidget.flickr(
                leftDotColor: const Color(0xFF050404).withOpacity(0.8),
                rightDotColor: const Color(0xFFd41111).withOpacity(0.8),
                size: 40,
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF050404),
              strokeWidth: 2.5,
              onRefresh: () async {
                await fetchData();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: IntrinsicWidth(
                              child: TextField(
                                controller: searchController,
                                onChanged: (query) {
                                  search(query);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF050404)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF050404)),
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      search(searchController.text);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        Icons.search,
                                        color: Color(0xFF050404),
                                      ),
                                    ),
                                  ),
                                ),
                                cursorColor: const Color(0xFF050404),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (transactionDataList.isEmpty && !loadingData)
                      const Center(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 40),
                              Text(
                                'No walkins to display.',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                              reverse: true,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: transactionDataList.length,
                              itemBuilder: (BuildContext context, int index) {
                                final userData = transactionDataList[index];
                                final id = userData['_id'];

                                return Card(
                                  color: Colors.white,
                                  elevation: 4,
                                  child: ListTile(
                                    title: BodyMediumOver(
                                      text:
                                          'Transaction ID: ${userData['_id']}',
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Divider(),
                                        BodyMediumOver(
                                          text: 'Name: ${userData['name']}',
                                        ),
                                        BodyMediumText(
                                          text:
                                              'Mobile Number: ${userData['contactNumber'] ?? ''}',
                                        ),
                                        const Divider(),
                                        BodyMediumText(
                                          text:
                                              'Discounted: ${userData['discounted'] != false ? 'Yes' : 'No'}',
                                        ),
                                        BodyMediumOver(
                                          text:
                                              'Items: ${userData['items']!.map((item) {
                                            if (item is Map<String, dynamic> &&
                                                item.containsKey('name') &&
                                                item.containsKey('quantity') &&
                                                item.containsKey(
                                                    'customerPrice')) {
                                              final itemName = item['name'];
                                              final quantity = item['quantity'];
                                              final price =
                                                  item['customerPrice'];

                                              return '$itemName ₱${NumberFormat.decimalPattern().format(price)} (x$quantity)';
                                            }
                                          }).join(', ')}',
                                        ),
                                        BodyMediumText(
                                          text:
                                              'Total: ₱${NumberFormat.decimalPattern().format(userData['total'])}',
                                        ),
                                      ],
                                    ),
                                    trailing: SizedBox(
                                      width: 25,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.archive,
                                          color: const Color(0xFF050404)
                                              .withOpacity(0.9),
                                        ),
                                        onPressed: () => archiveData(id),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (currentPage > 1)
                                  ElevatedButton(
                                    onPressed: () {
                                      fetchData(page: currentPage - 1);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF050404)
                                          .withOpacity(0.9),
                                    ),
                                    child: const Text(
                                      'Previous',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    fetchData(page: currentPage + 1);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF050404)
                                        .withOpacity(0.9),
                                  ),
                                  child: const Text(
                                    'Next',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
