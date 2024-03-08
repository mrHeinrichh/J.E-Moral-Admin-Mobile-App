import 'package:admin_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TransactionWalkinPage extends StatefulWidget {
  @override
  _TransactionWalkinPageState createState() => _TransactionWalkinPageState();
}

class _TransactionWalkinPageState extends State<TransactionWalkinPage> {
  List<Map<String, dynamic>> transactionDataList = [];
  TextEditingController searchController = TextEditingController();
  bool loadingData = false;

  @override
  void initState() {
    super.initState();
    loadingData = true;
    fetchData();
  }

  int currentPage = 1;
  int limit = 10;

  Future<void> fetchData({int page = 1}) async {
    final response = await http.get(Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/transactions/?filter={"__t":null}&page=$page&limit=$limit'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<Map<String, dynamic>> transactionData = (data['data'] as List)
          .where((transactionData) => transactionData is Map<String, dynamic>)
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
              transactionData['__t'] == null &&
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Archive Data'),
          content: const Text('Are you sure you want to Archive this data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final url = Uri.parse(
                    'https://lpg-api-06n8.onrender.com/api/v1/transactions/$id');
                final response = await http.delete(url);

                if (response.statusCode == 200) {
                  setState(() {
                    transactionDataList
                        .removeWhere((data) => data['_id'] == id);
                  });

                  Navigator.pop(context);
                } else {
                  print(
                      'Failed to Archive the data. Status code: ${response.statusCode}');
                }
              },
              child: const Text('Archive'),
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
                                    title: TitleMediumOver(
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

                                              return '$itemName (₱${NumberFormat.decimalPattern().format(price)} x $quantity)';
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
