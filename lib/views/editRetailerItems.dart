import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';

class EditRetailerItemsPage extends StatefulWidget {
  @override
  __EditRetailerItemsPageStateState createState() =>
      __EditRetailerItemsPageStateState();
}

class __EditRetailerItemsPageStateState extends State<EditRetailerItemsPage> {
  List<Map<String, dynamic>> productDataList = [];
  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchData();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Reached the end of the list, load more data
      fetchData(page: currentPage + 1);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int currentPage = 1;
  int limit = 10;

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
      });
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  void updateData(String id) {
    Map<String, dynamic> productToEdit =
        productDataList.firstWhere((data) => data['_id'] == id);
    TextEditingController retailerPriceController =
        TextEditingController(text: productToEdit['retailerPrice'].toString());
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Price for Retailer'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: retailerPriceController,
                    decoration:
                        const InputDecoration(labelText: 'Retailer Price'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the Price for Retailer';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: reasonController,
                    decoration:
                        const InputDecoration(labelText: 'Retailer Reason'),
                    // validator: (value) {
                    //   if (value!.isEmpty) {
                    //     return 'Please enter the Reason';
                    //   }
                    //   return null;
                    // },
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Map<String, dynamic> updateData = {
                    "price": retailerPriceController.text,
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
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> search(String query) async {
    final response = await http.get(Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/items/?search=$query'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> productData = (data['data'] as List)
          .where((productData) =>
              productData is Map<String, dynamic> &&
              productData.containsKey('type') &&
              productData['type'] ==
                  'Product') // Only include products with type 'Products'
          .map((productData) => productData as Map<String, dynamic>)
          .toList();

      setState(() {
        productDataList = productData;
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'Edit Prices for Retailers',
            style: TextStyle(color: Color(0xFF232937), fontSize: 24),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF232937)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
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
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Icon(Icons.search),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                        // Reached the end of the list, load more data
                        fetchData(page: currentPage + 1);
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount: productDataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final productData = productDataList[index];
                        final id = productData['_id'];

                        return Card(
                          child: ListTile(
                            title: Text(productData['name'] ?? ''),
                            subtitle: Text(productData['category'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("₱" +
                                        (productData['retailerPrice']
                                                .toString() ??
                                            '')),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => updateData(id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
