import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class transactionPage extends StatefulWidget {
  @override
  _transactionPageState createState() => _transactionPageState();
}

class _transactionPageState extends State<transactionPage> {
  List<Map<String, dynamic>> transactionDataList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  int currentPage = 1;
  // int limit = 2;

  Future<void> fetchData({int page = 1, int limit = 10}) async {
    final response = await http.get(Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/transactions/?page=$page&limit=$limit'));
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
      });
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  Future<void> addTransactionToAPI(Map<String, dynamic> newTransaction) async {
    final url =
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/transactions');
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(newTransaction),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      fetchData();
      Navigator.pop(context);
    } else {
      print(
          'Failed to add or update the transaction. Status code: ${response.statusCode}');
    }
  }

  Future<void> search(String query) async {
    final response = await http.get(Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/transactions/?search=$query'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> transactionData = (data['data'] as List)
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
    } else {
      // Handle error case if needed
    }
  }

  //     final List<Map<String, dynamic>> transactionData = (data['data'] as List)
  //         .where((userData) =>
  //             userData is Map<String, dynamic> &&
  //             userData.containsKey('type') &&
  //             userData['type'] == 'Walkin')
  //         .map((userData) => userData as Map<String, dynamic>)
  //         .toList();

  //     setState(() {
  //       transactionDataList = transactionData;
  //     });
  //   } else {}
  // }

  void deleteData(String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Data'),
          content: Text('Are you sure you want to delete this data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
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
                      'Failed to delete the data. Status code: ${response.statusCode}');
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Transaction CRUD',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
        iconTheme: IconThemeData(color: Color(0xFF232937)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      search(searchController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Icon(Icons.search),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFF232937),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: DataTable(
                  columns: <DataColumn>[
                    DataColumn(label: Text('Customer Name')),
                    DataColumn(label: Text('ContactNumber')),
                    DataColumn(label: Text('Transaction Type')),
                    DataColumn(label: Text('Barangay')),
                    DataColumn(label: Text('Payment Method')),
                    DataColumn(label: Text('Approved')),
                    DataColumn(label: Text('Picked Up')),
                    DataColumn(label: Text('Completed')),
                    DataColumn(label: Text('Cancelled')),
                    DataColumn(label: Text('Pick Up Image')),
                    DataColumn(label: Text('Deliver Image')),
                    DataColumn(label: Text('Date and Time')),
                    DataColumn(
                      label: Text('Actions'),
                      tooltip: 'Update and Delete',
                    ),
                  ],
                  // rows: transactionDataList.map((transactionData) {
                  //   final id = transactionData['_id'];

                  rows: transactionDataList
                      .where((transactionData) =>
                          transactionData['type'] == 'Walkin' ||
                          transactionData['type'] ==
                              '{Online}') // Filter data by type
                      .map((transactionData) {
                    final id = transactionData['_id'];
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(transactionData['name'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(transactionData['contactNumber'].toString() ??
                                ''),
                            placeholder: false),
                        DataCell(Text(transactionData['type'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                          SizedBox(
                            width: 150, // Adjust the width as needed
                            child: Text(
                              transactionData['barangay'].toString() ?? '',
                              overflow: TextOverflow
                                  .ellipsis, // Add this to handle overflow
                            ),
                          ),
                          placeholder: false,
                        ),
                        DataCell(
                          SizedBox(
                            width: 100, // Adjust the width as needed
                            child: Text(
                              transactionData['paymentMethod'].toString() ?? '',
                              overflow: TextOverflow
                                  .ellipsis, // Add this to handle overflow
                            ),
                          ),
                          placeholder: false,
                        ),
                        DataCell(
                            Text(
                                transactionData['isApproved'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                          SizedBox(
                            width: 100, // Adjust the width as needed
                            child: Text(
                              transactionData['pickedUp'].toString() ?? '',
                              overflow: TextOverflow
                                  .ellipsis, // Add this to handle overflow
                            ),
                          ),
                          placeholder: false,
                        ),
                        DataCell(
                          SizedBox(
                            width: 100, // Adjust the width as needed
                            child: Text(
                              transactionData['completed'].toString() ?? '',
                              overflow: TextOverflow
                                  .ellipsis, // Add this to handle overflow
                            ),
                          ),
                          placeholder: false,
                        ),
                        DataCell(
                          SizedBox(
                            width: 100, // Adjust the width as needed
                            child: Text(
                              transactionData['cancelled'].toString() ?? '',
                              overflow: TextOverflow
                                  .ellipsis, // Add this to handle overflow
                            ),
                          ),
                          placeholder: false,
                        ),
                        DataCell(
                          SizedBox(
                            width: 100, // Adjust the width as needed
                            child: Text(
                              transactionData['pickupImages'].toString() ?? '',
                              overflow: TextOverflow
                                  .ellipsis, // Add this to handle overflow
                            ),
                          ),
                          placeholder: false,
                        ),
                        DataCell(
                          SizedBox(
                            width: 100, // Adjust the width as needed
                            child: Text(
                              transactionData['completionImages'].toString() ??
                                  '',
                              overflow: TextOverflow
                                  .ellipsis, // Add this to handle overflow
                            ),
                          ),
                          placeholder: false,
                        ),
                        DataCell(
                          SizedBox(
                            width: 170, // Adjust the width as needed
                            child: Text(
                              transactionData['createdAt'].toString() ?? '',
                              overflow: TextOverflow
                                  .ellipsis, // Add this to handle overflow
                            ),
                          ),
                          placeholder: false,
                        ),
                        DataCell(
                          Row(
                            children: [
                              // IconButton(
                              //   icon: Icon(Icons.edit),
                              //   onPressed: () => updateData(id),
                              // ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => deleteData(id),
                              ),
                            ],
                          ),
                          placeholder: false,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (currentPage > 1)
                  ElevatedButton(
                    onPressed: () {
                      fetchData(page: currentPage - 1);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                    ),
                    child: Text('Previous'),
                  ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    fetchData(page: currentPage + 1);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                  ),
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
