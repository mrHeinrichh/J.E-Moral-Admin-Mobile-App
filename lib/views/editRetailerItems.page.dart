import 'package:admin_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditPricesForRetailersPage extends StatefulWidget {
  @override
  __EditPricesForRetailersPageStateState createState() =>
      __EditPricesForRetailersPageStateState();
}

class __EditPricesForRetailersPageStateState
    extends State<EditPricesForRetailersPage> {
  List<Map<String, dynamic>> itemDataList = [];
  TextEditingController searchController = TextEditingController();

  bool loadingData = false;
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
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
    final response = await http.get(Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/items/?page=$page&limit=$limit'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<Map<String, dynamic>> itemData = (data['data'] as List)
          .where((itemData) => itemData is Map<String, dynamic>)
          .map((itemData) => itemData as Map<String, dynamic>)
          .toList();

      setState(() {
        itemDataList.clear();
        itemDataList.addAll(itemData);
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
          'https://lpg-api-06n8.onrender.com/api/v1/items/?search=$query&limit=300'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> filteredData = (data['data'] as List)
          .where((itemData) =>
              itemData is Map<String, dynamic> &&
              (itemData['name']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  itemData['type']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  itemData['category']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  itemData['retailerPrice']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase())))
          .map((itemData) => itemData as Map<String, dynamic>)
          .toList();

      setState(() {
        itemDataList = filteredData;
      });
    } else {}
  }

  void updateData(String id) {
    Map<String, dynamic> productToEdit =
        itemDataList.firstWhere((data) => data['_id'] == id);
    TextEditingController retailerPriceController =
        TextEditingController(text: productToEdit['retailerPrice'].toString());
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Edit Price for Retailer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Padding(
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
                          image: NetworkImage(productToEdit['image'] ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  BodyMediumOver(
                    text: 'Product Name: ${productToEdit['name']}',
                  ),
                  BodyMediumText(
                    text: 'Type: ${productToEdit['type']}',
                  ),
                  BodyMediumText(
                    text: 'Category: ${productToEdit['category']}',
                  ),
                  BodyMediumText(
                      text:
                          'Retailer Price: ${productToEdit['retailerPrice'] % 1 == 0 ? '₱${productToEdit['retailerPrice'].toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}' : productToEdit['retailerPrice'].toStringAsFixed(productToEdit['retailerPrice'].truncateToDouble() == productToEdit['retailerPrice'] ? 0 : 2) == productToEdit['retailerPrice'].toStringAsFixed(0) ? '₱${productToEdit['retailerPrice'].toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}' : '₱${productToEdit['retailerPrice'].toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}'}'),
                  const Divider(),
                  EditTextField(
                    controller: retailerPriceController,
                    labelText: 'Updated Retailer Price',
                    hintText: 'Enter the Updated Retailer Price',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Price for Retailer';
                      }
                      final RegExp numberRegex = RegExp(r'^\d+(\.\d+)?$');
                      if (!numberRegex.hasMatch(value)) {
                        return 'Please Enter a Valid Price Number';
                      }
                      return null;
                    },
                  ),
                  EditTextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: reasonController,
                    labelText: 'Reason',
                    hintText: 'Enter the Reason',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Reason';
                      }
                      return null;
                    },
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
                if (formKey.currentState!.validate()) {
                  Map<String, dynamic> updateData = {
                    "price": retailerPriceController.text,
                    "reason": reasonController.text,
                    "type": "Retailer"
                  };

                  final url = Uri.parse(
                      'https://lpg-api-06n8.onrender.com/api/v1/items/$id/price');
                  final headers = {'Content-Type': 'application/json'};

                  final response = await http.patch(
                    url,
                    headers: headers,
                    body: jsonEncode(updateData),
                  );

                  if (response.statusCode == 200) {
                    fetchData();
                    Navigator.pop(context);
                  } else {
                    print(
                        'Failed to update the product. Status code: ${response.statusCode}');
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF050404).withOpacity(0.9),
              ),
              child: const Text(
                'Save',
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
                    if (itemDataList.isEmpty && !loadingData)
                      const Center(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 40),
                              Text(
                                'No items to display.',
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
                              itemCount: itemDataList.length,
                              itemBuilder: (BuildContext context, int index) {
                                final itemData = itemDataList[index];
                                final id = itemData['_id'];

                                return Card(
                                  color: Colors.white,
                                  elevation: 2,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: double.infinity,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  itemData['image'] ?? ''),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: TitleMedium(
                                            text: '${itemData['name']}'),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Divider(),
                                            TitleMediumText(
                                                text:
                                                    'Retailer Price: ${itemData['retailerPrice'] % 1 == 0 ? '₱${itemData['retailerPrice'].toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}' : itemData['retailerPrice'].toStringAsFixed(itemData['retailerPrice'].truncateToDouble() == itemData['retailerPrice'] ? 0 : 2) == itemData['retailerPrice'].toStringAsFixed(0) ? '₱${itemData['retailerPrice'].toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}' : '₱${itemData['retailerPrice'].toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}'}'),
                                            const SizedBox(height: 2),
                                            BodyMediumText(
                                                text:
                                                    'Type: ${itemData['type'] ?? ''}'),
                                            BodyMediumText(
                                                text:
                                                    'Category: ${itemData['category'] ?? ''}'),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 40,
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: const Color(0xFF050404)
                                                      .withOpacity(0.9),
                                                ),
                                                onPressed: () => updateData(id),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
