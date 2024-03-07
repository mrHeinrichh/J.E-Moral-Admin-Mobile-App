import 'package:admin_app/routes/app_routes.dart';
import 'package:admin_app/views/product_details.page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:intl/intl.dart';

class WalkinPage extends StatefulWidget {
  @override
  _WalkinPageState createState() => _WalkinPageState();
}

class _WalkinPageState extends State<WalkinPage> {
  List<Map<String, dynamic>> itemsData = [];
  TextEditingController searchController = TextEditingController();
  bool loadingData = false;

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

  Future<void> fetchData() async {
    final url = Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/items/?&page=1&limit=300');
    final response = await http.get(url);
    if (!mounted) {
      return;
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
            'price': (item['customerPrice'] ?? 0).toString(),
            'showPrice': NumberFormat.decimalPattern().format(
                double.parse((item['customerPrice'] ?? 0).toStringAsFixed(2))),
            'imageUrl': item['image'] ?? 'Image URL Not Available',
            'description': item['description'] ?? 'Description Not Available',
            'type': item['type'] ?? 'Type Not Available',
            'weight': (item['weight'] ?? 0).toString(),
            'stock': (item['stock'] ?? 0).toString(),
          };

          if (groupedData.containsKey(category)) {
            groupedData[category]!.add(product);
          } else {
            groupedData[category] = [product];
          }
        });

        itemsData = groupedData.entries
            .map((entry) => {
                  'category': entry.key,
                  'products': entry.value,
                })
            .toList();

        loadingData = false;
      });
    }
  }

  void search() async {
    final searchTerm = searchController.text;
    final url = Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/items/search?search=$searchTerm&limit=300');
    final response = await http.get(url);
    if (!mounted) {
      return;
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
            'price': (item['customerPrice'] ?? 0).toString(),
            'showPrice': NumberFormat.decimalPattern().format(
                double.parse((item['customerPrice'] ?? 0).toStringAsFixed(2))),
            'imageUrl': item['image'] ?? 'Image URL Not Available',
            'description': item['description'] ?? 'Description Not Available',
            'type': item['type'] ?? 'Type Not Available',
            'weight': (item['weight'] ?? 0).toString(),
            'stock': (item['stock'] ?? 0).toString(),
          };

          if (groupedData.containsKey(category)) {
            groupedData[category]!.add(product);
          } else {
            groupedData[category] = [product];
          }
        });

        itemsData = groupedData.entries
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
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Walkin Orders',
          style: TextStyle(
            color: const Color(0xFF050404).withOpacity(0.9),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: const Color(0xFF050404).withOpacity(0.8),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.black,
            height: 0.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, dashboardRoute);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: RefreshIndicator(
          onRefresh: () async {
            await fetchData();
          },
          color: const Color(0xFF050404),
          strokeWidth: 2.5,
          child: Stack(
            children: [
              if (loadingData)
                Center(
                  child: LoadingAnimationWidget.flickr(
                    leftDotColor: const Color(0xFF050404).withOpacity(0.8),
                    rightDotColor: const Color(0xFFd41111).withOpacity(0.8),
                    size: 40,
                  ),
                ),
              if (!loadingData)
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 100,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 45,
                                  child: Material(
                                    elevation: 5,
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  controller: searchController,
                                                  cursorColor:
                                                      const Color(0xFF050404),
                                                  onChanged: (text) {
                                                    search();
                                                  },
                                                  decoration: InputDecoration(
                                                    hintText: 'Search',
                                                    border: InputBorder.none,
                                                    hintStyle: TextStyle(
                                                      color: const Color(
                                                              0xFF050404)
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              const Icon(
                                                Icons.search,
                                                color: Color(0xFF050404),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Material(
                                elevation: 5,
                                borderRadius: BorderRadius.circular(10.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.shopping_cart_rounded,
                                      color: const Color(0xFF050404)
                                          .withOpacity(0.8),
                                      size: 23,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(context, cartRoute);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: itemsData.length,
                        itemBuilder: (context, categoryIndex) {
                          final category = itemsData[categoryIndex]['category'];
                          final products = itemsData[categoryIndex]['products'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(
                                    category,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: const Color(0xFF050404)
                                          .withOpacity(0.8),
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
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProductDetailsPage(
                                                  productName:
                                                      product['name'] ??
                                                          'Name Not Available',
                                                  productPrice:
                                                      product['price'] ??
                                                          'Price Not Available',
                                                  showProductPrice:
                                                      product['showPrice'] ??
                                                          'Price Not Available',
                                                  productImageUrl: product[
                                                          'imageUrl'] ??
                                                      'Image URL Not Available',
                                                  itemType: product['type'] ??
                                                      'Type Not Available',
                                                  category: category ??
                                                      'Category Not Available',
                                                  description: product[
                                                          'description'] ??
                                                      'Description Not Available',
                                                  weight: product['weight'] ??
                                                      'Weight Not Available',
                                                  quantity: 0,
                                                  stock: product['stock'] ??
                                                      'Stock Not Available',
                                                  id: product['_id'] ??
                                                      'ID Not Available',
                                                ),
                                              ),
                                            );
                                          },
                                          child: SizedBox(
                                            width: 130,
                                            child: Column(
                                              children: [
                                                Card(
                                                  color: Colors.white,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.network(
                                                      product['imageUrl'],
                                                      width: 100,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                ListTile(
                                                  title: Text(
                                                    product['name'],
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF232937),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  subtitle: Text(
                                                    '₱${product['showPrice']}',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: const Color(
                                                              0xFFd41111)
                                                          .withOpacity(0.8),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
