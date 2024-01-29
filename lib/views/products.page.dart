import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/services.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  File? _image;
  final _imageStreamController = StreamController<File?>.broadcast();

  List<Map<String, dynamic>> productDataList = [];
  TextEditingController searchController = TextEditingController();

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
  int limit = 10;

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

  void showCustomOverlay(BuildContext context, String message) {
    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.5,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            child: Card(
              color: Colors.red,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  message,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)!.insert(overlay);

    Future.delayed(Duration(seconds: 2), () {
      overlay.remove();
    });
  }

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
        productDataList.clear();
        productDataList.addAll(productData);
        currentPage = page;
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

  Future<void> _pickImageForEdit() async {
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

  void updateData(String id) {
    Map<String, dynamic> productToEdit =
        productDataList.firstWhere((data) => data['_id'] == id);

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
    TextEditingController customerPriceController =
        TextEditingController(text: productToEdit['customerPrice'].toString());
    TextEditingController retailerPriceController =
        TextEditingController(text: productToEdit['retailerPrice'].toString());
    TextEditingController imageController =
        TextEditingController(text: productToEdit['image']);
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Data'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the product name';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: categoryController.text,
                    onChanged: (newValue) {
                      setState(() {
                        categoryController.text = newValue!;
                      });
                    },
                    items: ['Brand New Tanks', 'Refill Tanks']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Category',
                    ),
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the product description';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: weightController,
                    decoration: InputDecoration(labelText: 'Weight (in kg.)'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the product weight (in kg.)';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  TextFormField(
                    controller: quantityController,
                    decoration: InputDecoration(labelText: 'Quantity'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the product quantity';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  TextFormField(
                    controller: customerPriceController,
                    decoration: InputDecoration(labelText: 'Customer Price'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the product customer price';
                      }
                      return null;
                    },
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  TextFormField(
                    controller: retailerPriceController,
                    decoration: InputDecoration(labelText: 'Retailer Price'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the product retailer price';
                      }
                      return null;
                    },
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  Text(
                    "\nProduct Image",
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
                              ? (productToEdit['image']?.toString() ?? '')
                                      .isNotEmpty
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                          productToEdit['image']?.toString() ??
                                              ''),
                                    )
                                  : const CircleAvatar(
                                      radius: 50,
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
                              await _pickImageForEdit();
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
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  productToEdit['name'] = nameController.text;
                  productToEdit['category'] = categoryController.text;
                  productToEdit['description'] = descriptionController.text;
                  productToEdit['weight'] = weightController.text;
                  productToEdit['quantity'] = quantityController.text;
                  productToEdit['customerPrice'] = customerPriceController.text;
                  productToEdit['retailerPrice'] = retailerPriceController.text;

                  // Upload new image only if available
                  if (_image != null) {
                    var uploadResponse = await uploadImageToServer(_image!);
                    if (uploadResponse != null) {
                      print("Image URL: ${uploadResponse["url"]}");
                      productToEdit["image"] = uploadResponse["url"];
                    } else {
                      print("Image upload failed");
                    }
                  }
                  final url = Uri.parse(
                      'https://lpg-api-06n8.onrender.com/api/v1/items/$id');
                  final headers = {'Content-Type': 'application/json'};

                  final response = await http.patch(
                    url,
                    headers: headers,
                    body: jsonEncode(productToEdit),
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
                  'Product') // Only include products with type 'Products'
          .map((productData) => productData as Map<String, dynamic>)
          .toList();

      setState(() {
        productDataList = productData;
      });
    } else {}
  }

  void openAddProductDialog() {
    // Create controllers for each field
    TextEditingController nameController = TextEditingController();
    TextEditingController categoryController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController weightController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
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
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the product name';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField(
                    value: categoryController.text.isNotEmpty
                        ? categoryController.text
                        : null,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Brand New Tanks',
                          child: Text('Brand New Tanks')),
                      DropdownMenuItem(
                          value: 'Refill Tanks', child: Text('Refill Tanks')),
                    ],
                    onChanged: (newValue) {
                      categoryController.text = newValue.toString();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please select the product category";
                      } else {
                        return null;
                      }
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the product description';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: weightController,
                    decoration: InputDecoration(labelText: 'Weight (in kg.)'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the product weight (in kg.)';
                      }
                      return null;
                    },
                    keyboardType:
                        TextInputType.number, // Set the keyboard type to number
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Allow only numeric input
                    ],
                  ),
                  TextFormField(
                    controller: quantityController,
                    decoration: InputDecoration(labelText: 'Quantity'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the product quantity';
                      }
                      return null;
                    },
                    keyboardType:
                        TextInputType.number, // Set the keyboard type to number
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // Allow only numeric input
                    ],
                  ),
                  TextFormField(
                    controller: customerPriceController,
                    decoration: InputDecoration(labelText: 'Customer Price'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the product customer price';
                      }
                      return null;
                    },
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                  TextFormField(
                    controller: retailerPriceController,
                    decoration: InputDecoration(labelText: 'Retailer Price'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the product retailer price';
                      }
                      return null;
                    },
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                  Text(
                    "\nProduct Image",
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
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Additional conditions for image validation
                  if (_image == null) {
                    showCustomOverlay(context, 'Please Upload an Image');
                  } else {
                    Map<String, dynamic> newProduct = {
                      "name": nameController.text,
                      "category": categoryController.text,
                      "description": descriptionController.text,
                      "weight": weightController.text,
                      "quantity": quantityController.text,
                      "type": "Product",
                      "customerPrice": customerPriceController.text,
                      "retailerPrice": retailerPriceController.text,
                      "image": "",
                    };
                    // Call the function to add the new product to the API
                    addProductToAPI(newProduct);
                  }
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void ArchiveData(String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Archive Data'),
          content: Text('Are you sure you want to Archive this data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Send a request to your API to Archive the data
                final url = Uri.parse(
                    'https://lpg-api-06n8.onrender.com/api/v1/items/$id');
                final response = await http.delete(url);

                if (response.statusCode == 200) {
                  setState(() {
                    productDataList.removeWhere((data) => data['_id'] == id);
                  });

                  Navigator.pop(context); // Close the dialog
                } else {
                  // Handle any other status codes (e.g., 400 for validation errors, 500 for server errors, etc.)
                  print(
                      'Failed to Archive the data. Status code: ${response.statusCode}');
                  // You can also display an error message to the user
                }
              },
              child: Text('Archive'),
            ),
          ],
        );
      },
    );
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
            'Product CRUD',
            style: TextStyle(color: Color(0xFF232937), fontSize: 24),
          ),
          iconTheme: IconThemeData(color: Color(0xFF232937)),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              color: Color(0xFF232937),
              onPressed: () {
                openAddProductDialog();
              },
            ),
          ],
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
                            borderRadius: BorderRadius.circular(
                                20), // Apply border radius
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
                        color: Color(
                            0xFF232937), // You can change the border color
                        width: 1.0,
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
                          tooltip: 'Update and Archive',
                        ),
                      ],
                      rows: productDataList
                          .where((productData) =>
                              productData['type'] ==
                              'Product') // Filter data by type
                          .map((productData) {
                        final id = productData['_id'];
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(Text(productData['name'] ?? '')),
                            DataCell(Text(productData['category'] ?? '')),
                            DataCell(Text(productData['type'] ?? '')),
                            DataCell(Text(productData['description'] ?? '')),
                            DataCell(
                                Text(productData['weight'].toString() ?? '')),
                            DataCell(
                                Text(productData['quantity'].toString() ?? '')),
                            DataCell(Text(
                                productData['customerPrice'].toString() ?? '')),
                            DataCell(Text(
                                productData['retailerPrice'].toString() ?? '')),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => updateData(id),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.archive),
                                    onPressed: () => ArchiveData(id),
                                  ),
                                ],
                              ),
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
                          fetchData(page: currentPage - 1);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                        ),
                        child: Text('Previous'),
                      ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        fetchData(page: currentPage + 1);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                      ),
                      child: Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
