import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Map<String, dynamic>> productsDataList = [];
  TextEditingController searchController =
      TextEditingController(); // Controller for the search field

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  int currentPage = 1;
  int limit = 21;

  Future<void> fetchData({int page = 1}) async {
    final response = await http.get(Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/items/?page=$page&limit=$limit'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> productsData = (data['data'] as List)
          .where((productsData) =>
              productsData is Map<String, dynamic> &&
              productsData['type'] == 'Products') // Filter for 'Products'
          .map((productsData) => productsData as Map<String, dynamic>)
          .toList();

      setState(() {
        // Clear the existing data before adding new data
        productsDataList.clear();
        productsDataList.addAll(productsData);
        currentPage = page; // Update the current page number
      });
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  Future<void> addProductsToAPI(Map<String, dynamic> newProducts) async {
    final url = Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/items');
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(newProducts),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // The new products has been successfully added or updated
      // You can also handle the response data if needed

      // Update the UI to display the newly added or updated products (if required)
      fetchData(); // Refresh the data list

      Navigator.pop(context); // Close the add products dialog
    } else {
      // Handle any other status codes (e.g., 400 for validation errors, 500 for server errors, etc.)
      print(
          'Failed to add or update the products. Status code: ${response.statusCode}');
      // You can also display an error message to the products
    }
  }

  void updateData(String id) {
    // Find the products data to edit
    Map<String, dynamic> productsToEdit =
        productsDataList.firstWhere((data) => data['_id'] == id);

    // Create controllers for each field
    TextEditingController nameController =
        TextEditingController(text: productsToEdit['name']);
    TextEditingController categoryController =
        TextEditingController(text: productsToEdit['category']);
    TextEditingController descriptionController =
        TextEditingController(text: productsToEdit['description']);
    TextEditingController weightController =
        TextEditingController(text: productsToEdit['weight'].toString());
    TextEditingController quantityController =
        TextEditingController(text: productsToEdit['quantity'].toString());
    TextEditingController typeController =
        TextEditingController(text: productsToEdit['type']);
    TextEditingController customerPriceController =
        TextEditingController(text: productsToEdit['customerPrice'].toString());

    TextEditingController retailerPriceController =
        TextEditingController(text: productsToEdit['retailerPrice'].toString());

    TextEditingController imageController =
        TextEditingController(text: productsToEdit['image']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Data'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: weightController,
                  decoration: InputDecoration(labelText: 'Weight'),
                ),
                TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                ),
                TextFormField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: 'type'),
                ),
                TextFormField(
                  controller: customerPriceController,
                  decoration: InputDecoration(labelText: 'customerPrice'),
                ),
                TextFormField(
                  controller: retailerPriceController,
                  decoration: InputDecoration(labelText: 'retailerPrice'),
                ),
                TextFormField(
                  controller: imageController,
                  decoration: InputDecoration(labelText: 'image'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Update the products data based on the controllers
                productsToEdit['name'] = nameController.text;
                productsToEdit['category'] = categoryController.text;
                productsToEdit['description'] = descriptionController.text;
                productsToEdit['weight'] = weightController.text;
                productsToEdit['quantity'] = quantityController.text;
                productsToEdit['type'] = typeController.text;
                productsToEdit['customerPrice'] = customerPriceController.text;
                productsToEdit['retailerPrice'] = retailerPriceController.text;

                productsToEdit['image'] = imageController.text;

                // Send a request to your API to update the data with the new values
                final url = Uri.parse(
                    'https://lpg-api-06n8.onrender.com/api/v1/items/$id');
                final headers = {'Content-Type': 'application/json'};

                final response = await http.patch(
                  url,
                  headers: headers,
                  body: jsonEncode(productsToEdit),
                );

                if (response.statusCode == 200) {
                  // The data has been successfully updated
                  // You can also handle the response data if needed

                  // Update the UI to display the newly updated products (if required)
                  fetchData(); // Refresh the data list

                  Navigator.pop(context); // Close the edit products dialog
                } else {
                  // Handle any other status codes (e.g., 400 for validation errors, 500 for server errors, etc.)
                  print(
                      'Failed to update the products. Status code: ${response.statusCode}');
                  // You can also display an error message to the products
                }
              },
              child: Text('Save'),
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

      final List<Map<String, dynamic>> productsData = (data['data'] as List)
          .where((productsData) =>
              productsData is Map<String, dynamic> &&
              productsData.containsKey('type') &&
              productsData['type'] == 'Products')
          .map((productsData) => productsData as Map<String, dynamic>)
          .toList();

      setState(() {
        productsDataList = productsData;
      });
    } else {}
  }

  void openAddProductsDialog() {
    // Create controllers for each field
    TextEditingController nameController = TextEditingController();
    TextEditingController categoryController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController weightController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    TextEditingController typeController = TextEditingController();
    TextEditingController customerPriceController = TextEditingController();
    TextEditingController retailerPriceController = TextEditingController();
    TextEditingController imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Products'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Add text form fields for products data input
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'category'),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: weightController,
                  decoration: InputDecoration(labelText: 'Weight'),
                ),
                TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                ),
                TextFormField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: 'type'),
                ),
                TextFormField(
                  controller: customerPriceController,
                  decoration: InputDecoration(labelText: 'customer price'),
                ),
                TextFormField(
                  controller: retailerPriceController,
                  decoration: InputDecoration(labelText: 'retailerPrice'),
                ),

                TextFormField(
                  controller: imageController,
                  decoration: InputDecoration(labelText: 'image'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Create a new products object from the input data
                Map<String, dynamic> newProducts = {
                  "name": nameController.text,
                  "category": categoryController.text,
                  "description": descriptionController.text,
                  "weight": weightController.text,
                  "quantity": quantityController.text,
                  "type": typeController.text,
                  "customerPrice": customerPriceController.text,
                  "retailerPrice": retailerPriceController.text,
                  "image": imageController.text,
                };

                // Call the function to add the new products to the API
                addProductsToAPI(newProducts);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

// Function to handle data delete
  void deleteData(String id) async {
    // Show a confirmation dialog to confirm the deletion
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Data'),
          content: Text('Are you sure you want to delete this data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Send a request to your API to delete the data
                final url = Uri.parse(
                    'https://lpg-api-06n8.onrender.com/api/v1/items/$id');
                final response = await http.delete(url);

                if (response.statusCode == 200) {
                  // Data has been successfully deleted
                  // Update the UI to remove the deleted data
                  setState(() {
                    productsDataList.removeWhere((data) => data['_id'] == id);
                  });

                  Navigator.pop(context); // Close the dialog
                } else {
                  // Handle any other status codes (e.g., 400 for validation errors, 500 for server errors, etc.)
                  print(
                      'Failed to delete the data. Status code: ${response.statusCode}');
                  // You can also display an error message to the products
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
          'Products CRUD',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
        iconTheme: IconThemeData(color: Color(0xFF232937)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            color: Color(0xFF232937),
            onPressed: () {
              // Open the dialog to add a new products
              openAddProductsDialog();
            },
          ),
        ],
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
                        // Remove input field border
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle the search button click
                      search(searchController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors
                          .black, // Change the button background color to black
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Apply border radius
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
                    color: Color(0xFF232937), // You can change the border color
                    width: 1.0,
                    // You can change the border width
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: DataTable(
                  columns: <DataColumn>[
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('category')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Weight')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('customerPrice')),
                    DataColumn(label: Text('retailerPrice')),
                    DataColumn(label: Text('Type')),
                    DataColumn(
                      label: Text('Actions'),
                      tooltip: 'Update and Delete',
                    ),
                  ],
                  rows: productsDataList.map((productsData) {
                    final id = productsData['_id'];

                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(productsData['name'] ?? ''),
                            placeholder: false),
                        DataCell(Text(productsData['category'] ?? ''),
                            placeholder: false),
                        DataCell(Text(productsData['description'] ?? ''),
                            placeholder: false),
                        DataCell(Text(productsData['weight'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(productsData['quantity'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(
                                productsData['customerPrice'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(
                                productsData['retailerPrice'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(productsData['type'] ?? ''),
                            placeholder: false),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => updateData(id),
                              ),
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
                      // Load the previous page of data
                      fetchData(page: currentPage - 1);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors
                          .black, // Change the button background color to black
                    ),
                    child: Text('Previous'),
                  ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Load the next page of data
                    fetchData(page: currentPage + 1);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors
                        .black, // Change the button background color to black
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
