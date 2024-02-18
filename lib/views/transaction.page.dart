import 'package:admin_app/widgets/custom_text.dart';
import 'package:admin_app/widgets/fullscreen_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

class transactionPage extends StatefulWidget {
  @override
  _transactionPageState createState() => _transactionPageState();
}

class _transactionPageState extends State<transactionPage> {
  List<Map<String, dynamic>> transactionDataList = [];
  List<Map<String, dynamic>> customerDataList = [];

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

  Future<Map<String, dynamic>> fetchCustomer(String customerId) async {
    final response = await http.get(
      Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/users/?filter={"_id":"$customerId","__t":"Customer"}',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['data'] != null && data['data'].isNotEmpty) {
        final customerData = data['data'][0] as Map<String, dynamic>;
        return customerData;
      } else {
        throw Exception('Customer not found');
      }
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  Future<Map<String, dynamic>> fetchRider(String riderId) async {
    final response = await http.get(
      Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/users/?filter={"_id":"$riderId","__t":"Rider"}',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['data'] != null && data['data'].isNotEmpty) {
        final riderData = data['data'][0] as Map<String, dynamic>;
        return riderData;
      } else {
        throw Exception('Rider not found');
      }
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

                    return FutureBuilder<Map<String, dynamic>>(
                      future: fetchCustomer(userData['to']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        } else if (snapshot.hasError) {
                          return const Text('Error fetching customer data');
                        } else {
                          final customerData = snapshot.data!;
                          return GestureDetector(
                            onTap: () {
                              _showCustomerDetailsModal(userData);
                            },
                            child: Card(
                              elevation: 4,
                              child: ListTile(
                                title: TitleMediumText(
                                  text:
                                      'Ordered by: ${customerData['name'] ?? ''}',
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(),
                                    BodyMediumText(
                                      text:
                                          'Status: ${userData['status'] ?? ''}',
                                    ),
                                    const SizedBox(height: 5),
                                    BodyMediumText(
                                      text:
                                          'Contact #: ${userData['contactNumber'] ?? ''}',
                                    ),
                                    BodyMediumText(
                                      text:
                                          'Barangay: ${userData['barangay'] ?? ''}',
                                    ),
                                    BodyMediumText(
                                      text:
                                          'Payment: ${userData['paymentMethod'] == 'COD' ? 'Cash on Delivery' : (userData['paymentMethod'] == 'GCASH' ? 'GCash' : '')}',
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
                        }
                      },
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
    fetchCustomer(userData['to']).then((customerData) async {
      dynamic riderData;
      if (userData['rider'] != null) {
        try {
          riderData = await fetchRider(userData['rider']);
        } catch (error) {
          print('Error fetching rider data: $error');
        }
      }

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
                    text: 'Status: ${userData['status']}',
                  ),
                  const Divider(),
                  BodyMediumText(
                    text: 'Receiver Name: ${userData['name']}',
                  ),
                  BodyMediumText(
                    text: 'Contact Number: ${userData['contactNumber']}',
                  ),
                  BodyMediumOver(
                    text: 'Barangay: ${userData['barangay']}',
                  ),
                  const Divider(),
                  BodyMediumOver(
                    text: 'Ordered by: ${customerData['name']}',
                  ),
                  BodyMediumOver(
                    text: 'Contact Number: ${customerData['contactNumber']}',
                  ),
                  const Divider(),
                  if (riderData != null) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyMediumOver(
                          text: 'Rider: ${riderData['name']}',
                        ),
                        BodyMediumOver(
                          text: 'Contact Number: ${riderData['contactNumber']}',
                        ),
                        const Divider(),
                      ],
                    ),
                  ],
                  BodyMediumText(
                    text: 'Payment Method: ${userData['paymentMethod']}',
                  ),
                  BodyMediumText(
                    text:
                        'Delivery Date: ${DateFormat('MMM d, y - h:mm a ').format(DateTime.parse(userData['deliveryDate']))}',
                  ),
                  BodyMediumText(
                    text:
                        'Applying for Discount: ${userData['discountIdImage'] != null ? 'Yes' : 'No'}',
                  ),
                  if (userData['discountIdImage'] != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FullScreenImageView(
                              imageUrl: userData['discountIdImage'],
                              onClose: () => Navigator.of(context).pop()),
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          height: 100, // Change the size
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(
                                  userData['discountIdImage'] ?? ''),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  BodyMediumOver(
                    text: 'Item: ${userData['items']!.map((item) {
                      if (item is Map<String, dynamic> &&
                          item.containsKey('name') &&
                          item.containsKey('quantity')) {
                        return '${item['name']} (${item['quantity']})';
                      }
                    }).join(', ')}',
                  ),
                  BodyMediumText(
                    text:
                        'Total: ₱${NumberFormat.decimalPattern().format(userData['total'])}',
                  ),
                  const Divider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (userData['pickupImages'] != "" &&
                              userData['cancellationImages'] == "")
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => FullScreenImageView(
                                      imageUrl: userData['pickupImages'],
                                      onClose: () =>
                                          Navigator.of(context).pop()),
                                ));
                              },
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
                          if (userData['completionImages'] != "" &&
                              userData['cancellationImages'] == "")
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => FullScreenImageView(
                                      imageUrl: userData['completionImages'],
                                      onClose: () =>
                                          Navigator.of(context).pop()),
                                ));
                              },
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
                          if (userData['cancellationImages'] != "")
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => FullScreenImageView(
                                      imageUrl: userData['cancellationImages'],
                                      onClose: () =>
                                          Navigator.of(context).pop()),
                                ));
                              },
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
                  const SizedBox(height: 5),
                  if (userData['cancellationImages'] != "")
                    BodyMediumText(
                      text: 'Cancel Reason: ${userData['cancelReason']}',
                    ),
                ],
              ),
            ),
          );
        },
      );
    }).catchError((error) {
      print('Error fetching customer data: $error');
    });
  }
}
