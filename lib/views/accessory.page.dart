import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AccessoryPage extends StatefulWidget {
  @override
  _AccessoryPageState createState() => _AccessoryPageState();
}

class _AccessoryPageState extends State<AccessoryPage> {
  List<Map<String, dynamic>> accessoryDataList = [];
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

      final List<Map<String, dynamic>> accessoryData = (data['data'] as List)
          .where((accessoryData) =>
              accessoryData is Map<String, dynamic> &&
              accessoryData['type'] == 'Accessory') // Filter for 'Accessory'
          .map((accessoryData) => accessoryData as Map<String, dynamic>)
          .toList();

      setState(() {
        // Clear the existing data before adding new data
        accessoryDataList.clear();
        accessoryDataList.addAll(accessoryData);
        currentPage = page; // Update the current page number
      });
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  Future<void> addAccessoryToAPI(Map<String, dynamic> newAccessory) async {
    final url = Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/items');
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(newAccessory),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // The new accessory has been successfully added or updated
      // You can also handle the response data if needed

      // Update the UI to display the newly added or updated accessory (if required)
      fetchData(); // Refresh the data list

      Navigator.pop(context); // Close the add accessory dialog
    } else {
      // Handle any other status codes (e.g., 400 for validation errors, 500 for server errors, etc.)
      print(
          'Failed to add or update the accessory. Status code: ${response.statusCode}');
      // You can also display an error message to the accessory
    }
  }

  void updateData(String id) {
    // Find the accessory data to edit
    Map<String, dynamic> accessoryToEdit =
        accessoryDataList.firstWhere((data) => data['_id'] == id);

    // Create controllers for each field
    TextEditingController nameController =
        TextEditingController(text: accessoryToEdit['name']);
    TextEditingController categoryController =
        TextEditingController(text: accessoryToEdit['category']);
    TextEditingController descriptionController =
        TextEditingController(text: accessoryToEdit['description']);
    TextEditingController weightController =
        TextEditingController(text: accessoryToEdit['weight'].toString());
    TextEditingController quantityController =
        TextEditingController(text: accessoryToEdit['quantity'].toString());
    TextEditingController typeController =
        TextEditingController(text: accessoryToEdit['type']);
    TextEditingController customerPriceController = TextEditingController(
        text: accessoryToEdit['customerPrice'].toString());

    TextEditingController retailerPriceController = TextEditingController(
        text: accessoryToEdit['retailerPrice'].toString());

    TextEditingController imageController =
        TextEditingController(text: accessoryToEdit['image']);

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
                // Update the accessory data based on the controllers
                accessoryToEdit['name'] = nameController.text;
                accessoryToEdit['category'] = categoryController.text;
                accessoryToEdit['description'] = descriptionController.text;
                accessoryToEdit['weight'] = weightController.text;
                accessoryToEdit['quantity'] = quantityController.text;
                accessoryToEdit['type'] = typeController.text;
                accessoryToEdit['customerPrice'] = customerPriceController.text;
                accessoryToEdit['retailerPrice'] = retailerPriceController.text;

                accessoryToEdit['image'] = imageController.text;

                // Send a request to your API to update the data with the new values
                final url = Uri.parse(
                    'https://lpg-api-06n8.onrender.com/api/v1/items/$id');
                final headers = {'Content-Type': 'application/json'};

                final response = await http.patch(
                  url,
                  headers: headers,
                  body: jsonEncode(accessoryToEdit),
                );

                if (response.statusCode == 200) {
                  // The data has been successfully updated
                  // You can also handle the response data if needed

                  // Update the UI to display the newly updated accessory (if required)
                  fetchData(); // Refresh the data list

                  Navigator.pop(context); // Close the edit accessory dialog
                } else {
                  // Handle any other status codes (e.g., 400 for validation errors, 500 for server errors, etc.)
                  print(
                      'Failed to update the accessory. Status code: ${response.statusCode}');
                  // You can also display an error message to the accessory
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

      final List<Map<String, dynamic>> accessoryData = (data['data'] as List)
          .where((accessoryData) =>
              accessoryData is Map<String, dynamic> &&
              accessoryData.containsKey('type') &&
              accessoryData['type'] == 'Accessory')
          .map((accessoryData) => accessoryData as Map<String, dynamic>)
          .toList();

      setState(() {
        accessoryDataList = accessoryData;
      });
    } else {}
  }

  void openAddAccessoryDialog() {
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
          title: Text('Add New Accessory'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Add text form fields for accessory data input
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
                // Create a new accessory object from the input data
                Map<String, dynamic> newAccessory = {
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

                // Call the function to add the new accessory to the API
                addAccessoryToAPI(newAccessory);
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
                    accessoryDataList.removeWhere((data) => data['_id'] == id);
                  });

                  Navigator.pop(context); // Close the dialog
                } else {
                  // Handle any other status codes (e.g., 400 for validation errors, 500 for server errors, etc.)
                  print(
                      'Failed to delete the data. Status code: ${response.statusCode}');
                  // You can also display an error message to the accessory
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
          'Accessory CRUD',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
        iconTheme: IconThemeData(color: Color(0xFF232937)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            color: Color(0xFF232937),
            onPressed: () {
              // Open the dialog to add a new accessory
              openAddAccessoryDialog();
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
                  rows: accessoryDataList.map((accessoryData) {
                    final id = accessoryData['_id'];

                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(accessoryData['name'] ?? ''),
                            placeholder: false),
                        DataCell(Text(accessoryData['category'] ?? ''),
                            placeholder: false),
                        DataCell(Text(accessoryData['description'] ?? ''),
                            placeholder: false),
                        DataCell(Text(accessoryData['weight'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(accessoryData['quantity'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(accessoryData['customerPrice'].toString() ??
                                ''),
                            placeholder: false),
                        DataCell(
                            Text(accessoryData['retailerPrice'].toString() ??
                                ''),
                            placeholder: false),
                        DataCell(Text(accessoryData['type'] ?? ''),
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
