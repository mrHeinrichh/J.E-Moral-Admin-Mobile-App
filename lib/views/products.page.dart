import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  File? _image;
  final _imageStreamController = StreamController<File?>.broadcast();

  List<Map<String, dynamic>> productDataList = [];
  TextEditingController searchController =
      TextEditingController(); // Controller for the search field

  @override
  void dispose() {
    _imageStreamController.close();
    super.dispose();
  }

  void initState() {
    super.initState();
    fetchData();
  }

  int currentPage = 1;
  int limit = 21;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      _imageStreamController.sink.add(imageFile);
      setState(() {
        _image = imageFile;
      });
    }
  }

  Future<Map<String, dynamic>?> uploadImageToServer(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/upload/image'),
      );

      var fileStream = http.ByteStream(Stream.castFrom(imageFile.openRead()));
      var length = await imageFile.length();

      String fileExtension = imageFile.path.split('.').last.toLowerCase();
      var contentType = MediaType('image', 'png');

      Map<String, String> imageExtensions = {
        'png': 'png',
        'jpg': 'jpeg',
        'jpeg': 'jpeg',
        'gif': 'gif',
      };

      if (imageExtensions.containsKey(fileExtension)) {
        contentType = MediaType('image', imageExtensions[fileExtension]!);
      }

      var multipartFile = http.MultipartFile(
        'image',
        fileStream,
        length,
        filename: 'image.$fileExtension',
        contentType: contentType,
      );

      request.files.add(multipartFile);

      var response = await request.send();

      // ...

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print("Image uploaded successfully: $responseBody");

        // Parse the response JSON
        final parsedResponse = json.decode(responseBody);

        // Check if 'data' is present in the response
        if (parsedResponse.containsKey('data')) {
          final List<dynamic> data = parsedResponse['data'];

          // Check if 'path' is present in the first item of the 'data' array
          if (data.isNotEmpty && data[0].containsKey('path')) {
            final imageUrl = data[0]['path'];
            print("Image URL: $imageUrl");

            return {'url': imageUrl};
          } else {
            print("Invalid response format: $parsedResponse");
            return null;
          }
        } else {
          print("Invalid response format: $parsedResponse");
          return null;
        }
      } else {
        print("Image upload failed with status code: ${response.statusCode}");
        final responseBody = await response.stream.bytesToString();
        print("Response body: $responseBody");
        return null;
      }
    } catch (e) {
      print("Image upload failed with error: $e");
      return null;
    }
  }

  Future<void> fetchData({int page = 1}) async {
    final response = await http
        .get(Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/items'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> productData = (data['data'] as List)
          .where((productData) => productData is Map<String, dynamic>)
          .map((productData) => productData as Map<String, dynamic>)
          .toList();

      setState(() {
        // Clear the existing data before adding new data
        productDataList.clear();
        productDataList.addAll(productData);
        currentPage = page; // Update the current page number
      });
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  Future<void> addProductToAPI(Map<String, dynamic> newProduct) async {
    final url = Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/items');
    final headers = {'Content-Type': 'application/json'};

    try {
      var uploadResponse = await uploadImageToServer(_image!);
      print("Upload Response: $uploadResponse");

      if (uploadResponse != null) {
        print("Image URL: ${uploadResponse["url"]}");
        newProduct["image"] = uploadResponse["url"];

        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(newProduct),
        );

        print("API Response: ${response.statusCode} - ${response.body}");

        if (response.statusCode == 201 || response.statusCode == 200) {
          fetchData();
          Navigator.pop(context);
        } else {
          print(
              'Failed to add or update the product. Status code: ${response.statusCode}');
        }
      } else {
        print("Image upload failed");
      }
    } catch (e) {
      print("Exception during API request: $e");
    }
  }

  void updateData(String id) {
    // Find the product data to edit
    Map<String, dynamic> productToEdit =
        productDataList.firstWhere((data) => data['_id'] == id);

    // Create controllers for each field
    TextEditingController nameController =
        TextEditingController(text: productToEdit['name']);
    TextEditingController categoryController =
        TextEditingController(text: productToEdit['category']);
    TextEditingController descriptionController =
        TextEditingController(text: productToEdit['description']);
    TextEditingController weightController =
        TextEditingController(text: productToEdit['weight'].toString());
    TextEditingController quantityController =
        TextEditingController(text: productToEdit['quantity'].toString());
    TextEditingController typeController =
        TextEditingController(text: productToEdit['type']);
    TextEditingController customerPriceController =
        TextEditingController(text: productToEdit['customerPrice'].toString());

    TextEditingController retailerPriceController =
        TextEditingController(text: productToEdit['retailerPrice'].toString());

    TextEditingController imageController =
        TextEditingController(text: productToEdit['image']);

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
                  controller: typeController,
                  decoration: InputDecoration(labelText: 'Type'),
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
                  controller: customerPriceController,
                  decoration: InputDecoration(labelText: 'Customer Price'),
                ),
                TextFormField(
                  controller: retailerPriceController,
                  decoration: InputDecoration(labelText: 'Retailer Price'),
                ),
                TextFormField(
                  controller: imageController,
                  decoration: InputDecoration(labelText: 'Image'),
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
                // Update the product data based on the controllers
                productToEdit['name'] = nameController.text;
                productToEdit['category'] = categoryController.text;
                productToEdit['description'] = descriptionController.text;
                productToEdit['weight'] = weightController.text;
                productToEdit['quantity'] = quantityController.text;
                productToEdit['type'] = typeController.text;
                productToEdit['customerPrice'] = customerPriceController.text;
                productToEdit['retailerPrice'] = retailerPriceController.text;
                productToEdit['image'] = imageController.text;

                // Send a request to your API to update the data with the new values
                final url = Uri.parse(
                    'https://lpg-api-06n8.onrender.com/api/v1/items/$id');
                final headers = {'Content-Type': 'application/json'};

                final response = await http.patch(
                  url,
                  headers: headers,
                  body: jsonEncode(productToEdit),
                );

                if (response.statusCode == 200) {
                  // The data has been successfully updated
                  // You can also handle the response data if needed

                  // Update the UI to display the newly updated product (if required)
                  fetchData(); // Refresh the data list

                  Navigator.pop(context); // Close the edit product dialog
                } else {
                  // Handle any other status codes (e.g., 400 for validation errors, 500 for server errors, etc.)
                  print(
                      'Failed to update the product. Status code: ${response.statusCode}');
                  // You can also display an error message to the user
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

      final List<Map<String, dynamic>> productData = (data['data'] as List)
          .where((productData) =>
              productData is Map<String, dynamic> &&
              productData.containsKey('type') &&
              productData['type'] ==
                  'Products') // Only include products with type 'Products'
          .map((productData) => productData as Map<String, dynamic>)
          .toList();

      setState(() {
        productDataList = productData;
      });
    } else {
      // Handle the error case
    }
  }

  void openAddProductDialog() {
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
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Add text form fields for product data input
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                // TextFormField(
                //   controller: typeController,
                //   decoration: InputDecoration(labelText: 'Type'),
                // ),
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
                  controller: customerPriceController,
                  decoration: InputDecoration(labelText: 'Customer Price'),
                ),
                TextFormField(
                  controller: retailerPriceController,
                  decoration: InputDecoration(labelText: 'Retailer Price'),
                ),
                Text(
                  "\nProductImage",
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey[700],
                  ),
                ),
                StreamBuilder<File?>(
                  stream: _imageStreamController.stream,
                  builder: (context, snapshot) {
                    return Column(
                      children: [
                        const SizedBox(height: 10.0),
                        const Divider(),
                        const SizedBox(height: 10.0),
                        snapshot.data == null
                            ? const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              )
                            : CircleAvatar(
                                radius: 50,
                                backgroundImage: FileImage(snapshot.data!),
                              ),
                        TextButton(
                          onPressed: () async {
                            await _pickImage();
                          },
                          child: const Text(
                            "Upload Image",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          //BREAKKKKKKKKKK
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Map<String, dynamic> newProduct = {
                  "name": nameController.text,
                  "category": categoryController.text,
                  "description": descriptionController.text,
                  "weight": weightController.text,
                  "quantity": quantityController.text,
                  "type": "Products",
                  "customerPrice": customerPriceController.text,
                  "retailerPrice": retailerPriceController.text,
                  "image": "",
                };
                // Call the function to add the new product to the API
                addProductToAPI(newProduct);
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
                    productDataList.removeWhere((data) => data['_id'] == id);
                  });

                  Navigator.pop(context); // Close the dialog
                } else {
                  // Handle any other status codes (e.g., 400 for validation errors, 500 for server errors, etc.)
                  print(
                      'Failed to delete the data. Status code: ${response.statusCode}');
                  // You can also display an error message to the user
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
          'Product CRUD',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
        iconTheme: IconThemeData(color: Color(0xFF232937)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            color: Color(0xFF232937),
            onPressed: () {
              // Open the dialog to add a new product
              openAddProductDialog();
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
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Weight')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Customer Price')),
                    DataColumn(label: Text('Retailer Price')),
                    DataColumn(
                      label: Text('Actions'),
                      tooltip: 'Update and Delete',
                    ),
                  ],
                  rows: productDataList
                      .where((productData) => productData['type'] == 'Products')
                      .map((productData) {
                    final id = productData['_id'];

                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(productData['name'] ?? ''),
                            placeholder: false),
                        DataCell(Text(productData['category'] ?? ''),
                            placeholder: false),
                        DataCell(Text(productData['type'] ?? ''),
                            placeholder: false),
                        DataCell(Text(productData['description'] ?? ''),
                            placeholder: false),
                        DataCell(Text(productData['weight'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(productData['quantity'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(productData['customerPrice'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(productData['retailerPrice'].toString() ?? ''),
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
