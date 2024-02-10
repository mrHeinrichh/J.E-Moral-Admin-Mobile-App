import 'package:admin_app/views/product_details.page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class WalkinPage extends StatefulWidget {
  @override
  _WalkinPageState createState() => _WalkinPageState();
}

class _WalkinPageState extends State<WalkinPage> {
  List<Map<String, dynamic>> sampleData = [];
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> announcements = [];
  bool initialSectionShown = false;

  @override
  void initState() {
    super.initState();
    fetchDataFromAPI();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    final url =
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/announcements/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final parsedData = json.decode(response.body);
      final data = parsedData['data'];

      final DateTime currentDate = DateTime.now();

      // Filter announcements based on the current date
      final filteredAnnouncements =
          List<Map<String, dynamic>>.from(data).where((announcement) {
        final DateTime startTime = DateTime.parse(announcement['start']);
        final DateTime endTime = DateTime.parse(announcement['end']);
        return currentDate.isAfter(startTime) && currentDate.isBefore(endTime);
      }).toList();

      setState(() {
        announcements = filteredAnnouncements;
      });
    }
  }

  void searchItems() async {
    final searchTerm = _searchController.text;
    final url = Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/items/?search=$searchTerm');
    final response = await http.get(url);
    if (!mounted) {
      return; // Check if the widget is still in the tree
    }

    if (response.statusCode == 200) {
      final parsedData = json.decode(response.body);
      final data = parsedData['data'];

      setState(() {
        final Map<String, List<Map<String, dynamic>>> groupedData = {};

        data.forEach((item) {
          final category = item['category'];
          final product = {
            'id': item['_id'] ?? 'ID Not Available',
            'name': item['name'] ?? 'Name Not Available',
            'price': (item['customerPrice'] ?? 0.0).toString(),
            'imageUrl': item['image'] ?? 'Image URL Not Available',
            'description': item['description'] ?? 'Description Not Available',
            'weight': (item['weight'] ?? 0).toString(),
            'stock': (item['stock'] ?? 0).toString(),
          };

          if (groupedData.containsKey(category)) {
            groupedData[category]!.add(product);
          } else {
            groupedData[category] = [product];
          }
        });

        sampleData = groupedData.entries
            .map((entry) => {
                  'category': entry.key,
                  'products': entry.value,
                })
            .toList();
      });
    }
  }

  Future<void> fetchDataFromAPI() async {
    final url = Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/items');
    final response = await http.get(url);
    if (!mounted) {
      return; // Check if the widget is still in the tree
    }

    if (response.statusCode == 200) {
      final parsedData = json.decode(response.body);
      final data = parsedData['data'];

      setState(() {
        final Map<String, List<Map<String, dynamic>>> groupedData = {};

        data.forEach((item) {
          final category = item['category'];
          final product = {
            '_id': item['_id'] ?? 'ID Not Available',
            'name': item['name'] ?? 'Name Not Available',
            'price': (item['customerPrice'] ?? 0.0).toString(),
            'imageUrl': item['image'] ?? 'Image URL Not Available',
            'description': item['description'] ?? 'Description Not Available',
            'weight': (item['weight'] ?? 0).toString(),
            'stock': (item['stock'] ?? 0).toString(),
          };

          if (groupedData.containsKey(category)) {
            groupedData[category]!.add(product);
          } else {
            groupedData[category] = [product];
          }
        });

        sampleData = groupedData.entries
            .map((entry) => {
                  'category': entry.key,
                  'products': entry.value,
                })
            .toList();
      });
    }
  }

  bool fullscreenImageVisible = false;
  String fullscreenImageUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Walkin Orders',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
        iconTheme: IconThemeData(color: Color(0xFF232937)),
        actions: <Widget>[],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: sampleData.length,
                  itemBuilder: (context, categoryIndex) {
                    final category = sampleData[categoryIndex]['category'];
                    final products = sampleData[categoryIndex]['products'];

                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            category,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFF232937),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: products.length,
                            itemBuilder: (context, productIndex) {
                              final product = products[productIndex];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailsPage(
                                        productName: product['name'] ??
                                            'Name Not Available',
                                        productPrice: product['price'] ??
                                            'Price Not Available',
                                        productImageUrl: product['imageUrl'] ??
                                            'Image URL Not Available',
                                        category: category ??
                                            'Category Not Available',
                                        description: product['description'] ??
                                            'Description Not Available',
                                        weight: product['weight'] ??
                                            'Weight Not Available',
                                        stock: product['stock'] ??
                                            'Stock Not Available',
                                      ),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: 130,
                                  child: Column(
                                    children: [
                                      Card(
                                        child: Column(
                                          children: [
                                            Image.network(
                                              product['imageUrl'],
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          product['name'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF232937),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          '\₱${product['price']}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFE98500),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
