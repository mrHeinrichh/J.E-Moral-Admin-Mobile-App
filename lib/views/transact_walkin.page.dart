import 'package:admin_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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
        'https://lpg-api-06n8.onrender.com/api/v1/transactions/?filter={"status":"Completed","__t":"Transactions"}&page=$page&limit=$limit'));

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
    if (query.isEmpty) {
      final response = await http.get(
          Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/transactions/'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final List<Map<String, dynamic>> transactionData = (data['data']
                as List)
            .where((transactionData) =>
                transactionData is Map<String, dynamic> &&
                transactionData.containsKey('name'))
            .map((transactionData) => transactionData as Map<String, dynamic>)
            .toList();

        setState(() {
          transactionDataList = transactionData;
        });
      } else {}
    } else {
      final Map<String, dynamic> filter = {"name": query};
      final String filterParam = Uri.encodeComponent(jsonEncode(filter));

      final response = await http.get(Uri.parse(
          'https://lpg-api-06n8.onrender.com/api/v1/transactions/?filter=$filterParam'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final List<Map<String, dynamic>> transactionData = (data['data']
                as List)
            .where((transactionData) =>
                transactionData is Map<String, dynamic> &&
                transactionData.containsKey('name') &&
                transactionData['name']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .map((transactionData) => transactionData as Map<String, dynamic>)
            .toList();

        setState(() {
          transactionDataList = transactionData;
        });
      } else {}
    }
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
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: RefreshIndicator(
          onRefresh: () => fetchData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: IntrinsicWidth(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Search',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              suffixIcon: InkWell(
                                onTap: () {
                                  search(searchController.text);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: const Icon(
                                    Icons.search,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactionDataList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final userData = transactionDataList[index];
                    final id = userData['_id'];

                    return Card(
                      elevation: 4,
                      child: ListTile(
                        title: TitleMediumText(
                          text: 'Status: ${userData['status']}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            BodyMediumText(
                              text: 'Name: ${userData['name']}',
                            ),
                            BodyMediumText(
                              text:
                                  'Mobile #: ${userData['contactNumber'] ?? ''}',
                            ),
                            BodyMediumText(
                              text:
                                  'Discounted: ${userData['discounted'] != false ? 'Yes' : 'No'}',
                            ),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 20,
                          child: IconButton(
                            icon: const Icon(Icons.archive),
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
                          backgroundColor: const Color(0xFF232937),
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
                        backgroundColor: const Color(0xFF232937),
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
      ),
    );
  }
}
