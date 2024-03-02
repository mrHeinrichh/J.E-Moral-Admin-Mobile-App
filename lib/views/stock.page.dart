import 'package:admin_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class StocksPage extends StatefulWidget {
  @override
  _StocksPageState createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  List<Map<String, dynamic>> stockDataList = [];
  TextEditingController searchController = TextEditingController();

  bool loadingData = false;

  @override
  void dispose() {
    super.dispose();
  }

  void initState() {
    super.initState();
    loadingData = true;
    fetchData();
    fetchStock();
  }

  int currentPage = 1;
  int limit = 20;

  Future<void> fetchData({int page = 1}) async {
    final response = await http.get(Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/items/?page=$page&limit=$limit'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<Map<String, dynamic>> stockData = (data['data'] as List)
          .where((stockData) => stockData is Map<String, dynamic>)
          .map((stockData) => stockData as Map<String, dynamic>)
          .toList();

      setState(() {
        stockDataList.clear();
        stockDataList.addAll(stockData);
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
                  itemData['stock']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase())))
          .map((itemData) => itemData as Map<String, dynamic>)
          .toList();

      setState(() {
        stockDataList = filteredData;
      });
    } else {}
  }

  void updateData(String id) {
    Map<String, dynamic> stockToEdit =
        stockDataList.firstWhere((data) => data['_id'] == id);

    int stock = int.parse(stockToEdit['stock'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text(
                'Update Stock',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            image: NetworkImage(stockToEdit['image'] ?? ''),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    BodyMediumOver(
                      text:
                          '${stockToEdit['type'] == 'Product' ? 'Product Name' : 'Accessory Name'}: ${stockToEdit['name']}',
                    ),
                    BodyMediumText(
                      text: 'Type: ${stockToEdit['type']}',
                    ),
                    BodyMediumText(
                      text: 'Category: ${stockToEdit['category']}',
                    ),
                    BodyMediumText(
                      text: 'Available Stock: ${stockToEdit['stock']}',
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (stock > 0) stock--;
                            });
                          },
                        ),
                        Text(
                          stock.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              stock++;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
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
                    stockDataList.firstWhere(
                        (data) => data['_id'] == id)['stock'] = stock;

                    final url = Uri.parse(
                        'https://lpg-api-06n8.onrender.com/api/v1/items/$id');
                    final headers = {'Content-Type': 'application/json'};

                    final response = await http.patch(
                      url,
                      headers: headers,
                      body: jsonEncode({'stock': stock}),
                    );

                    if (response.statusCode == 200) {
                      fetchData();
                      Navigator.pop(context);
                    } else {
                      print(
                          'Failed to update the stock. Status code: ${response.statusCode}');
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Stock List',
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
      ),
      backgroundColor: Colors.white,
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
                await fetchStock();
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFd41111).withOpacity(0.8),
                            border: Border.all(color: const Color(0xFF050404)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "CRITICALLY LOW",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFff8c00).withOpacity(0.8),
                            border: Border.all(color: const Color(0xFF050404)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "MODERATELY LOW",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (stockDataList.isEmpty && !loadingData)
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
                    if (stockDataList.isNotEmpty)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: stockDataList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final userData = stockDataList[index];
                                  final id = userData['_id'];
                                  final stock = userData['stock'] ?? 0;

                                  int checkColor;

                                  if (stock <= 3) {
                                    checkColor = stock;
                                  } else if (stock >= 4 && stock <= 7) {
                                    checkColor = stock;
                                  } else {
                                    checkColor = stock;
                                  }

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
                                                        userData['image'] ??
                                                            ''),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              title: TitleMedium(
                                                  text: '${userData['name']}'),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Divider(),
                                                  TitleMediumText(
                                                    text:
                                                        'Available Stock: $stock',
                                                    checkColor: checkColor,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  BodyMediumText(
                                                      text:
                                                          'Type: ${userData['type'] ?? ''}'),
                                                  BodyMediumText(
                                                      text:
                                                          'Category: ${userData['category'] ?? ''}'),
                                                ],
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: 40,
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons.assignment_add,
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
                              if (stockDataList.isNotEmpty)
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

  int moderatelyLowOnStock = 7;
  int lowOnStock = 3;
  int outOfStock = 0;

  Future<void> fetchStock() async {
    setState(() {
      loadingData = true;
    });

    final response = await http
        .get(Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/items/'));

    if (response.statusCode == 200) {
      setState(() {
        loadingData = false;
      });

      final Map<String, dynamic> data = json.decode(response.body);
      final List<Map<String, dynamic>> allStockData = (data['data'] as List)
          .where((stockData) => stockData is Map<String, dynamic>)
          .map((stockData) => stockData as Map<String, dynamic>)
          .toList();

      final List<Map<String, dynamic>> moderateLowOnStocks = allStockData
          .where((stockData) =>
              (stockData['stock'] ?? 0) > lowOnStock &&
              (stockData['stock'] ?? 0) <= moderatelyLowOnStock)
          .toList();

      final List<Map<String, dynamic>> lowOnStocks = allStockData
          .where((stockData) =>
              (stockData['stock'] ?? 0) <= lowOnStock &&
              (stockData['stock'] ?? 0) > outOfStock)
          .toList();

      final List<Map<String, dynamic>> outOfStocks = allStockData
          .where((stockData) => (stockData['stock'] ?? 0) <= outOfStock)
          .toList();

      List<Widget> stockWidgets = [];

      if (outOfStocks.isNotEmpty) {
        stockWidgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFd41111).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: const Text(
                    'Out of Stock',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Divider(),
              for (var stock in outOfStocks)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyMediumOver(
                        text:
                            '${stock['type'] == 'Product' ? 'Product Name' : 'Accessory Name'}: ${stock['name']}'),
                    BodyMediumText(text: 'Available Stock: ${stock['stock']}'),
                    BodyMediumText(text: 'Category: ${stock['category']}'),
                    BodyMediumText(text: 'Type: ${stock['type']}'),
                    const Divider(),
                  ],
                ),
            ],
          ),
        );
      }

      if (lowOnStocks.isNotEmpty) {
        stockWidgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFd41111).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: const Text(
                    'Low on Stock',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Divider(),
              for (var stock in lowOnStocks)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyMediumOver(
                        text:
                            '${stock['type'] == 'Product' ? 'Product Name' : 'Accessory Name'}: ${stock['name']}'),
                    BodyMediumText(text: 'Available Stock: ${stock['stock']}'),
                    BodyMediumText(text: 'Category: ${stock['category']}'),
                    BodyMediumText(text: 'Type: ${stock['type']}'),
                    const Divider(),
                  ],
                ),
            ],
          ),
        );
      }

      if (moderateLowOnStocks.isNotEmpty) {
        stockWidgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFff8c00).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: const Text(
                    'Moderately Low on Stock',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Divider(),
              for (var stock in moderateLowOnStocks)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyMediumOver(
                        text:
                            '${stock['type'] == 'Product' ? 'Product Name' : 'Accessory Name'}: ${stock['name']}'),
                    BodyMediumText(text: 'Available Stock: ${stock['stock']}'),
                    BodyMediumText(text: 'Category: ${stock['category']}'),
                    BodyMediumText(text: 'Type: ${stock['type']}'),
                    const Divider(),
                  ],
                ),
            ],
          ),
        );
      }

      if (moderateLowOnStocks.isNotEmpty ||
          lowOnStocks.isNotEmpty ||
          outOfStocks.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Column(
                children: [
                  Text(
                    'Stock Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Divider(),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: stockWidgets,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF050404).withOpacity(0.9),
                  ),
                  child: Text(
                    'OK',
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
    } else {
      setState(() {
        loadingData = false;
      });

      throw Exception('Failed to load data from the API');
    }
  }
}
