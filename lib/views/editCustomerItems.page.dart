import 'package:admin_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditPricesForCustomersPage extends StatefulWidget {
  @override
  __EditPricesForCustomersPageStateState createState() =>
      __EditPricesForCustomersPageStateState();
}

class __EditPricesForCustomersPageStateState
    extends State<EditPricesForCustomersPage> {
  List<Map<String, dynamic>> productDataList = [];
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
      final List<Map<String, dynamic>> productData = (data['data'] as List)
          .where((productData) => productData is Map<String, dynamic>)
          .map((productData) => productData as Map<String, dynamic>)
          .toList();

      setState(() {
        productDataList.addAll(productData);
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
          'https://lpg-api-06n8.onrender.com/api/v1/items/?search=$query'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> filteredData = (data['data'] as List)
          .where((productData) =>
              productData is Map<String, dynamic> &&
              productData['type'] == 'Product' &&
              (productData['name']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  productData['category']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  productData['customerPrice']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase())))
          .map((productData) => productData as Map<String, dynamic>)
          .toList();

      setState(() {
        productDataList = filteredData;
      });
    } else {}
  }

  void updateData(String id) {
    Map<String, dynamic> productToEdit =
        productDataList.firstWhere((data) => data['_id'] == id);
    TextEditingController customerPriceController =
        TextEditingController(text: productToEdit['customerPrice'].toString());
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Edit Price for Customer',
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
                // mainAxisAlignment: MainAxisAlignment.start,
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
                          'Customer Price: ${productToEdit['customerPrice'] % 1 == 0 ? '₱${productToEdit['customerPrice'].toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}' : productToEdit['customerPrice'].toStringAsFixed(productToEdit['customerPrice'].truncateToDouble() == productToEdit['customerPrice'] ? 0 : 2) == productToEdit['customerPrice'].toStringAsFixed(0) ? '₱${productToEdit['customerPrice'].toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}' : '₱${productToEdit['customerPrice'].toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}'}'),
                  const Divider(),
                  EditTextField(
                    controller: customerPriceController,
                    labelText: 'Updated Customer Price',
                    hintText: 'Enter the Updated Customer Price',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Price for Customer';
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
                    "price": customerPriceController.text,
                    "reason": reasonController.text,
                    "type": "Customer"
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
      //  backgroundColor: Colors.white,
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
                    if (productDataList.isEmpty && !loadingData)
                      const Center(
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Text(
                              'No items to display.',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    if (productDataList.isNotEmpty)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: productDataList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final productData = productDataList[index];
                                  final id = productData['_id'];

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: SizedBox(
                                      child: Card(
                                        color: Colors.white,
                                        elevation: 6,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                        productData['image'] ??
                                                            ''),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              title: TitleMedium(
                                                  text:
                                                      '${productData['name']}'),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Divider(),
                                                  TitleMediumText(
                                                      text:
                                                          'Customer Price: ${productData['customerPrice'] % 1 == 0 ? '₱${productData['customerPrice'].toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}' : productData['customerPrice'].toStringAsFixed(productData['customerPrice'].truncateToDouble() == productData['customerPrice'] ? 0 : 2) == productData['customerPrice'].toStringAsFixed(0) ? '₱${productData['customerPrice'].toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}' : '₱${productData['customerPrice'].toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}'}'),
                                                  const SizedBox(height: 2),
                                                  BodyMediumText(
                                                      text:
                                                          'Type: ${productData['type'] ?? ''}'),
                                                  BodyMediumText(
                                                      text:
                                                          'Category: ${productData['category'] ?? ''}'),
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
                                                        color: const Color(
                                                                0xFF050404)
                                                            .withOpacity(0.9),
                                                      ),
                                                      onPressed: () =>
                                                          updateData(id),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (productDataList.isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (currentPage > 1)
                                      ElevatedButton(
                                        onPressed: () {
                                          fetchData(page: currentPage - 1);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF050404)
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
