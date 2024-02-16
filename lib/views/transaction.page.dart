import 'package:admin_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';

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
  int limit = 10;

  Future<void> fetchData({int page = 1}) async {
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
    if (query.isEmpty) {
      // If the query is empty, fetch all transactions without applying the name filter
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
      } else {
        // Handle error case if needed
      }
    } else {
      // If a query is provided, apply the name filter (case-insensitive)
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
      } else {
        // Handle error case if needed
      }
    }
  }

  void archiveData(String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Archive Data'),
          content: Text('Are you sure you want to Archive this data?'),
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
                      'Failed to Archive the data. Status code: ${response.statusCode}');
                }
              },
              child: Text('Archive'),
            ),
          ],
        );
      },
    );
  }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         title: const Text(
//           'Transaction CRUD',
//           style: TextStyle(color: Color(0xFF232937), fontSize: 24),
//         ),
//         iconTheme: IconThemeData(color: Color(0xFF232937)),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: searchController,
//                       decoration: InputDecoration(
//                         hintText: 'Search',
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       search(searchController.text);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       primary: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                     child: Icon(Icons.search),
//                   ),
//                 ],
//               ),
//             ),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Color(0xFF232937),
//                     width: 1.0,
//                   ),
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//                 child: DataTable(
//                   columns: <DataColumn>[
//                     DataColumn(label: Text('Customer Name')),
//                     DataColumn(label: Text('ContactNumber')),
//                     DataColumn(label: Text('Transaction Type')),
//                     DataColumn(label: Text('Barangay')),
//                     DataColumn(label: Text('Payment Method')),
//                     DataColumn(label: Text('Approved')),
//                     DataColumn(label: Text('Picked Up')),
//                     DataColumn(label: Text('Completed')),
//                     DataColumn(label: Text('Cancelled')),
//                     DataColumn(label: Text('Pick Up Image')),
//                     DataColumn(label: Text('Deliver Image')),
//                     DataColumn(label: Text('Date and Time')),
//                     DataColumn(
//                       label: Text('Actions'),
//                       tooltip: 'Update and Archive',
//                     ),
//                   ],
//                   // rows: transactionDataList.map((transactionData) {
//                   //   final id = transactionData['_id'];

//                   rows: transactionDataList
//                       .where((transactionData) =>
//                           transactionData['__t'] == 'Delivery' ||
//                           transactionData['type'] ==
//                               '{Online}') // Filter data by type
//                       .map((transactionData) {
//                     final id = transactionData['_id'];
//                     return DataRow(
//                       cells: <DataCell>[
//                         DataCell(Text(transactionData['name'].toString() ?? ''),
//                             placeholder: false),
//                         DataCell(
//                             Text(transactionData['contactNumber'].toString() ??
//                                 ''),
//                             placeholder: false),
//                         DataCell(Text(transactionData['type'].toString() ?? ''),
//                             placeholder: false),
//                         DataCell(
//                           SizedBox(
//                             width: 150, // Adjust the width as needed
//                             child: Text(
//                               transactionData['barangay'].toString() ?? '',
//                               overflow: TextOverflow
//                                   .ellipsis, // Add this to handle overflow
//                             ),
//                           ),
//                           placeholder: false,
//                         ),
//                         DataCell(
//                           SizedBox(
//                             width: 100, // Adjust the width as needed
//                             child: Text(
//                               transactionData['paymentMethod'].toString() ?? '',
//                               overflow: TextOverflow
//                                   .ellipsis, // Add this to handle overflow
//                             ),
//                           ),
//                           placeholder: false,
//                         ),
//                         DataCell(
//                             Text(
//                                 transactionData['isApproved'].toString() ?? ''),
//                             placeholder: false),
//                         DataCell(
//                           SizedBox(
//                             width: 100, // Adjust the width as needed
//                             child: Text(
//                               transactionData['pickedUp'].toString() ?? '',
//                               overflow: TextOverflow
//                                   .ellipsis, // Add this to handle overflow
//                             ),
//                           ),
//                           placeholder: false,
//                         ),
//                         DataCell(
//                           SizedBox(
//                             width: 100, // Adjust the width as needed
//                             child: Text(
//                               transactionData['completed'].toString() ?? '',
//                               overflow: TextOverflow
//                                   .ellipsis, // Add this to handle overflow
//                             ),
//                           ),
//                           placeholder: false,
//                         ),
//                         DataCell(
//                           SizedBox(
//                             width: 100, // Adjust the width as needed
//                             child: Text(
//                               transactionData['cancelled'].toString() ?? '',
//                               overflow: TextOverflow
//                                   .ellipsis, // Add this to handle overflow
//                             ),
//                           ),
//                           placeholder: false,
//                         ),
//                         DataCell(
//                           SizedBox(
//                             width: 100, // Adjust the width as needed
//                             child: Text(
//                               transactionData['pickupImages'].toString() ?? '',
//                               overflow: TextOverflow
//                                   .ellipsis, // Add this to handle overflow
//                             ),
//                           ),
//                           placeholder: false,
//                         ),
//                         DataCell(
//                           SizedBox(
//                             width: 100, // Adjust the width as needed
//                             child: Text(
//                               transactionData['completionImages'].toString() ??
//                                   '',
//                               overflow: TextOverflow
//                                   .ellipsis, // Add this to handle overflow
//                             ),
//                           ),
//                           placeholder: false,
//                         ),
//                         DataCell(
//                           SizedBox(
//                             width: 170, // Adjust the width as needed
//                             child: Text(
//                               transactionData['createdAt'].toString() ?? '',
//                               overflow: TextOverflow
//                                   .ellipsis, // Add this to handle overflow
//                             ),
//                           ),
//                           placeholder: false,
//                         ),
//                         DataCell(
//                           Row(
//                             children: [
//                               // IconButton(
//                               //   icon: Icon(Icons.edit),
//                               //   onPressed: () => updateData(id),
//                               // ),
//                               IconButton(
//                                 icon: Icon(Icons.archive),
//                                 onPressed: () => ArchiveData(id),
//                               ),
//                             ],
//                           ),
//                           placeholder: false,
//                         ),
//                       ],
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 if (currentPage > 1)
//                   ElevatedButton(
//                     onPressed: () {
//                       fetchData(page: currentPage - 1);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       primary: Colors.black,
//                     ),
//                     child: Text('Previous'),
//                   ),
//                 SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     fetchData(page: currentPage + 1);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     primary: Colors.black,
//                   ),
//                   child: Text('Next'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction List'),
      ),
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
                  itemCount: transactionDataList
                      .where((transactionData) =>
                          transactionData['__t'] == 'Delivery' ||
                          transactionData['type'] == '{Online}')
                      .length,
                  itemBuilder: (BuildContext context, int index) {
                    final filteredData = transactionDataList
                        .where((transactionData) =>
                            transactionData['__t'] == 'Delivery' ||
                            transactionData['type'] == '{Online}')
                        .toList();

                    final userData = filteredData[index];
                    final id = userData['_id'];

                    return GestureDetector(
                      onTap: () {
                        _showCustomerDetailsModal(userData);
                      },
                      child: Card(
                        elevation: 4,
                        child: ListTile(
                          title: Text(
                            'Receiver Name: ${userData['name'] ?? ''}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              Text(
                                'Contact #: ${userData['contactNumber'] ?? ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                'Barangay: ${userData['barangay'] ?? ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Payment: ${userData['paymentMethod'] ?? ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
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
                          primary: const Color(0xFF232937),
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
                        primary: const Color(0xFF232937),
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

  void _showCustomerDetailsModal(Map<String, dynamic> userData) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    'Transaction Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                BodyMediumText(
                  text: 'Receiver Name: ${userData['name']}',
                ),
                BodyMediumText(
                  text: 'Contact Number: ${userData['contactNumber']}',
                ),
                BodyMediumText(
                  text: 'Barangay: ${userData['barangay']}',
                ),
                BodyMediumText(
                  text: 'Payment Method: ${userData['paymentMethod']}',
                ),
                BodyMediumText(
                  text: 'Status: ${userData['status']}',
                ),
                BodyMediumText(
                  text:
                      'Delivery Date: ${DateFormat('MMM d, y - h:mm a ').format(DateTime.parse(userData['deliveryDate']))}',
                ),
                // BodyMediumText(text: 'Item: '),
                BodyMediumText(
                    text:
                        'Total: ₱${NumberFormat.decimalPattern().format(userData['total'])}'),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (userData['pickupImages'] != "")
                          Expanded(
                            child: Column(
                              children: [
                                const BodyMediumText(
                                  text: 'Pick-up Image: ',
                                ),
                                Image.network(
                                  userData['pickupImages'],
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (userData['completionImages'] != "")
                          Expanded(
                            child: Column(
                              children: [
                                const BodyMediumText(
                                  text: 'Completion Image: ',
                                ),
                                Image.network(
                                  userData['completionImages'],
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (userData['cancellationImages'] != "")
                          Expanded(
                            child: Column(
                              children: [
                                const BodyMediumText(
                                  text: 'Cancellation Image: ',
                                ),
                                Image.network(
                                  userData['cancellationImages'],
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
