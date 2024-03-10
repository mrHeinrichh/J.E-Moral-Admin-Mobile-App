import 'package:admin_app/widgets/custom_text.dart';
import 'package:admin_app/widgets/fullscreen_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TransactionCancelledRetailerPage extends StatefulWidget {
  @override
  _TransactionCancelledRetailerPageState createState() =>
      _TransactionCancelledRetailerPageState();
}

class _TransactionCancelledRetailerPageState
    extends State<TransactionCancelledRetailerPage> {
  List<Map<String, dynamic>> transactionDataList = [];
  List<Map<String, dynamic>> retailerDataList = [];

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
  int limit = 20;

  Future<void> fetchData({int page = 1}) async {
    try {
      final response = await http.get(Uri.parse(
          'https://lpg-api-06n8.onrender.com/api/v1/transactions/?filter={"status":"Cancelled","__t":"Delivery"}&page=$page&limit=$limit'));
      if (_mounted) {
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<Map<String, dynamic>> transactionData = (data['data']
                  as List)
              .where(
                  (transactionData) => transactionData is Map<String, dynamic>)
              .map((transactionData) => transactionData as Map<String, dynamic>)
              .toList();

          setState(() {
            transactionDataList.clear();
            transactionDataList.addAll(transactionData);
            currentPage = page;
          });
        } else {}
      }
    } catch (e) {
      if (_mounted) {
        print("Error: $e");
      }
    } finally {
      loadingData = false;
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
              transactionData['__t'] == 'Delivery' &&
              transactionData['status'] == 'Cancelled' &&
              (transactionData['_id']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  transactionData['createdAt']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  _isMonthQuery(query, transactionData['createdAt']) ||
                  // transactionData['deliveryDate']
                  //     .toString()
                  //     .toLowerCase()
                  //     .contains(query.toLowerCase()) ||
                  // _isMonthQuery(query, transactionData['deliveryDate']) ||
                  transactionData['updatedAt']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  _isMonthQuery(query, transactionData['updatedAt']) ||
                  transactionData['paymentMethod']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  transactionData['paymentMethod']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  (_isDiscountedQuery(query) &&
                      transactionData['discountIdImage'] != null &&
                      transactionData['discountIdImage']
                          .toString()
                          .isNotEmpty) ||
                  transactionData['items']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  transactionData['total']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  transactionData['to']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  transactionData['rider']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase())))
          .map((transactionData) => transactionData as Map<String, dynamic>)
          .toList();

      setState(() {
        transactionDataList = filteredData;
      });
    } else {
      // Handle error
    }
  }

  bool _isMonthQuery(String query, String appointmentDate) {
    final months = {
      'january': '01',
      'jan': '01',
      'february': '02',
      'feb': '02',
      'march': '03',
      'mar': '03',
      'april': '04',
      'apr': '04',
      'may': '05',
      'june': '06',
      'jun': '06',
      'july': '07',
      'jul': '07',
      'august': '08',
      'aug': '08',
      'september': '09',
      'sep': '09',
      'october': '10',
      'oct': '10',
      'november': '11',
      'nov': '11',
      'december': '12',
      'dec': '12',
    };

    final lowerCaseQuery = query.toLowerCase();
    if (months.containsKey(lowerCaseQuery)) {
      final numericMonth = months[lowerCaseQuery];
      return appointmentDate.contains('-$numericMonth-');
    }
    return false;
  }

  bool _isDiscountedQuery(String query) {
    return query.toLowerCase() == 'discounted';
  }

  Future<Map<String, dynamic>> fetchRetailer(String retailerId) async {
    final response = await http.get(
      Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/users/?filter={"_id":"$retailerId","__t":"Retailer"}',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['data'] != null && data['data'].isNotEmpty) {
        final retailerData = data['data'][0] as Map<String, dynamic>;
        return retailerData;
      } else {
        throw Exception('Retailer not found');
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
                        'Date Ordered: ${DateFormat('MMM d, y - h:mm a ').format(DateTime.parse(transactionToEdit['createdAt']))}',
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
                          item.containsKey('retailerPrice')) {
                        final itemName = item['name'];
                        final quantity = item['quantity'];
                        final price = NumberFormat.decimalPattern().format(
                            double.parse(
                                (item['retailerPrice']).toStringAsFixed(2)));

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
                                'No transactions failed to display.',
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

                                return FutureBuilder<Map<String, dynamic>>(
                                  future: fetchRetailer(userData['to']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container();
                                    } else if (snapshot.hasError) {
                                      return Container();
                                    } else {
                                      final retailerData = snapshot.data!;

                                      return FutureBuilder<
                                          Map<String, dynamic>>(
                                        future: fetchRider(userData['rider']),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Container();
                                          } else if (snapshot.hasError) {
                                            return Container();
                                          } else {
                                            final riderData = snapshot.data!;

                                            return GestureDetector(
                                              onTap: () {
                                                showRetailerDetailsModal(
                                                    userData);
                                              },
                                              child: Card(
                                                color: Colors.white,
                                                elevation: 2,
                                                child: ListTile(
                                                  title: BodyMediumOver(
                                                    text:
                                                        'Transaction ID: ${userData['_id']}',
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Divider(),
                                                      const BodyMediumText(
                                                        text: 'Date Ordered:',
                                                      ),
                                                      Center(
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              DateFormat(
                                                                      'MMMM d, y - h:mm a')
                                                                  .format(DateTime
                                                                      .parse(userData[
                                                                              'createdAt'] ??
                                                                          '')),
                                                            ),
                                                            Text(
                                                              '(${DateFormat('yyyy-dd-MM - hh:mm').format(DateTime.parse(userData['createdAt'] ?? ''))})',
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      // const BodyMediumText(
                                                      //   text: 'Delivery Date:',
                                                      // ),
                                                      // Center(
                                                      //   child: Column(
                                                      //     children: [
                                                      //       Text(
                                                      //         DateFormat(
                                                      //                 'MMMM d, y - h:mm a')
                                                      //             .format(DateTime
                                                      //                 .parse(userData[
                                                      //                         'deliveryDate'] ??
                                                      //                     '')),
                                                      //       ),
                                                      //       Text(
                                                      //         '(${DateFormat('yyyy-dd-MM - hh:mm').format(DateTime.parse(userData['deliveryDate'] ?? ''))})',
                                                      //       ),
                                                      //     ],
                                                      //   ),
                                                      // ),
                                                      // const SizedBox(height: 5),
                                                      const BodyMediumText(
                                                        text: 'Date Delivered:',
                                                      ),
                                                      Center(
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              DateFormat(
                                                                      'MMMM d, y - h:mm a')
                                                                  .format(DateTime
                                                                      .parse(userData[
                                                                              'updatedAt'] ??
                                                                          '')),
                                                            ),
                                                            Text(
                                                              '(${DateFormat('yyyy-dd-MM - hh:mm').format(DateTime.parse(userData['updatedAt'] ?? ''))})',
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      const Divider(),
                                                      BodyMediumOver(
                                                        text:
                                                            'Ordered by: ${retailerData['name']}',
                                                      ),
                                                      BodyMediumOver(
                                                        text:
                                                            'Mobile Number: ${retailerData['contactNumber']}',
                                                      ),
                                                      const Divider(),
                                                      BodyMediumText(
                                                        text:
                                                            'Payment Method: ${userData['paymentMethod']}',
                                                      ),
                                                      BodyMediumText(
                                                        text:
                                                            'Discounted: ${userData['discountIdImage'] != "" && userData['discountIdImage'] != null ? 'Yes' : 'No'}',
                                                      ),
                                                      BodyMediumOver(
                                                        text:
                                                            'Items: ${userData['items']!.map((item) {
                                                          if (item is Map<
                                                                  String,
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
                                                                item[
                                                                    'quantity'];
                                                            final price = NumberFormat
                                                                    .decimalPattern()
                                                                .format(double
                                                                    .parse((item[
                                                                            'retailerPrice'])
                                                                        .toStringAsFixed(
                                                                            2)));

                                                            return '$itemName ₱$price (x$quantity)';
                                                          }
                                                        }).join(', ')}',
                                                      ),
                                                      BodyMediumText(
                                                        text:
                                                            'Total: ₱${NumberFormat.decimalPattern().format(double.parse((userData['total']).toStringAsFixed(2)))}',
                                                      ),
                                                      const Divider(),
                                                      BodyMediumOver(
                                                        text:
                                                            'Delivery Driver: ${riderData['name']}',
                                                      ),
                                                      BodyMediumOver(
                                                        text:
                                                            'Mobile Number: ${riderData['contactNumber']}',
                                                      ),
                                                      const SizedBox(height: 5),
                                                    ],
                                                  ),
                                                  trailing: SizedBox(
                                                    width: 25,
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons.archive,
                                                        color: const Color(
                                                                0xFF050404)
                                                            .withOpacity(0.9),
                                                      ),
                                                      onPressed: () =>
                                                          archiveData(id),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        },
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

  void showRetailerDetailsModal(Map<String, dynamic> userData) {
    fetchRetailer(userData['to']).then((retailerData) async {
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
          return Container(
            height: MediaQuery.of(context).size.height * 3 / 4,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
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
                  const Center(
                    child: BodyMedium(text: "Receiver Information:"),
                  ),
                  BodyMediumText(
                    text: 'Name: ${userData['name']}',
                  ),
                  BodyMediumText(
                    text: 'Mobile Number: ${userData['contactNumber']}',
                  ),
                  BodyMediumOver(
                    text: 'Pin Location: ${userData['deliveryLocation']}',
                  ),
                  BodyMediumOver(
                    text: 'House #: ${userData['houseLotBlk']}',
                  ),
                  BodyMediumOver(
                    text: 'Barangay: ${userData['barangay']}',
                  ),
                  const SizedBox(height: 5),
                  BodyMediumOver(
                    text:
                        'Delivery Date: ${userData['deliveryDate'] != null && userData['deliveryDate'] != "" ? DateFormat('MMMM d, y - h:mm a ').format(DateTime.parse(userData['deliveryDate'])) : ""}',
                  ),
                  const Divider(),
                  BodyMediumOver(
                    text: 'Ordered by: ${retailerData['name']}',
                  ),
                  BodyMediumOver(
                    text: 'Mobile Number: ${retailerData['contactNumber']}',
                  ),
                  const SizedBox(height: 5),
                  BodyMediumOver(
                    text:
                        'Date Ordered: ${DateFormat('MMMM d, y - h:mm a ').format(DateTime.parse(userData['createdAt']))}',
                  ),
                  const Divider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyMediumOver(
                        text: 'Delivery Driver: ${riderData['name']}',
                      ),
                      BodyMediumOver(
                        text: 'Mobile Number: ${riderData['contactNumber']}',
                      ),
                      const SizedBox(height: 5),
                      BodyMediumOver(
                        text:
                            'Date Delivered: ${DateFormat('MMMM d, y - h:mm a ').format(DateTime.parse(userData['updatedAt']))}',
                      ),
                      const Divider(),
                    ],
                  ),
                  BodyMediumText(
                    text: 'Payment Method: ${userData['paymentMethod']}',
                  ),
                  BodyMediumText(
                    text:
                        'Need to be Assembled: ${userData['assembly'] != null ? 'Yes' : 'No'}',
                  ),
                  BodyMediumText(
                    text:
                        'Applying for Discount: ${userData['discountIdImage'] != null && userData['discountIdImage'] != "" ? 'Yes' : 'No'}',
                  ),
                  const SizedBox(height: 5),
                  if (userData['discountIdImage'] != null &&
                      userData['discountIdImage'] != "")
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
                          height: 100,
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
                    text: 'Items: ${userData['items']!.map((item) {
                      if (item is Map<String, dynamic> &&
                          item.containsKey('name') &&
                          item.containsKey('quantity') &&
                          item.containsKey('retailerPrice')) {
                        final itemName = item['name'];
                        final quantity = item['quantity'];
                        final price = item['retailerPrice'];

                        return '$itemName ₱${NumberFormat.decimalPattern().format(price)} (x$quantity)';
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
                                    width: 100,
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
                                    width: 100,
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
                ],
              ),
            ),
          );
        },
      );
    }).catchError((error) {
      print('Error fetching retailer data: $error');
    });
  }
}
