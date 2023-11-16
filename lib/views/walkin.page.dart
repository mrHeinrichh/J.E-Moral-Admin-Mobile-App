import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class walkinPage extends StatefulWidget {
  @override
  _walkinPageState createState() => _walkinPageState();
}

class _walkinPageState extends State<walkinPage> {
  File? _image;
  final _imageStreamController = StreamController<File?>.broadcast();

  bool _sortAscending = true;
  String _sortColumn = 'createdAt'; // Default sorting column

  List<Map<String, dynamic>> walkinDataList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    _imageStreamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  int currentPage = 1;
  int limit = 2;

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
    final response = await http.get(
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/transactions'));

    // 'https://lpg-api-06n8.onrender.com/api/v1/transactions/?page=$page&limit=$limit'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> walkinData = (data['data'] as List)
          .where((userData) =>
              userData is Map<String, dynamic> && userData['type'] == 'Walkin')
          .map((userData) => userData as Map<String, dynamic>)
          .toList();

      setState(() {
        walkinDataList.clear();
        walkinDataList.addAll(walkinData);
        currentPage = page;
      });
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  Future<void> addWalkinToAPI(Map<String, dynamic> newWalkin) async {
    final url =
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/transactions');
    final headers = {'Content-Type': 'application/json'};

    var uploadResponse = await uploadImageToServer(_image!);
    print("Upload Response: $uploadResponse");

    if (uploadResponse != null) {
      print("Image URL: ${uploadResponse["url"]}");
      newWalkin["pickupImages"] = uploadResponse["url"];
    } else {
      // Handle the case where image upload fails
      print("Image upload failed");
      return;
    }

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(newWalkin),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      fetchData();

      Navigator.pop(context);
    } else {
      print(
          'Failed to add or update the walkin. Status code: ${response.statusCode}');
    }
  }

  void updateData(String id) {
    Map<String, dynamic> walkinToEdit =
        walkinDataList.firstWhere((data) => data['_id'] == id);

    TextEditingController nameController =
        TextEditingController(text: walkinToEdit['name'].toString());
    TextEditingController contactNumberController =
        TextEditingController(text: walkinToEdit['contactNumber'].toString());
    TextEditingController paymentMethodController =
        TextEditingController(text: walkinToEdit['paymentMethod'].toString());
    TextEditingController totalController =
        TextEditingController(text: walkinToEdit['total'].toString());
    TextEditingController itemsController =
        TextEditingController(text: walkinToEdit['items'].toString());
    TextEditingController pickupImagesController =
        TextEditingController(text: walkinToEdit['pickupImages'].toString());
    TextEditingController completedController =
        TextEditingController(text: walkinToEdit['completed'].toString());
    TextEditingController typeController =
        TextEditingController(text: walkinToEdit['type']);

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
                  controller: contactNumberController,
                  decoration: InputDecoration(labelText: 'ContactNumber'),
                ),
                TextFormField(
                  controller: paymentMethodController,
                  decoration: InputDecoration(labelText: 'PaymentMethod'),
                ),
                TextFormField(
                  controller: totalController,
                  decoration: InputDecoration(labelText: 'Total'),
                ),
                TextFormField(
                  controller: itemsController,
                  decoration: InputDecoration(labelText: 'Items'),
                ),
                Text(
                  "\npickupImage",
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
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                walkinToEdit['deliveryLocation'] = " ";
                walkinToEdit['name'] = nameController.text;
                walkinToEdit['contactNumber'] = contactNumberController.text;
                walkinToEdit['paymentMethod'] = paymentMethodController.text;
                walkinToEdit['total'] = totalController.text;
                walkinToEdit['items'] = itemsController.text;
                walkinToEdit['pickupImages'] = ""; // Clear previous value
                walkinToEdit['completed'] = completedController.text;
                walkinToEdit['type'] = typeController.text;

                // Upload new image if available
                if (_image != null) {
                  var uploadResponse = await uploadImageToServer(_image!);
                  print("Upload Response: $uploadResponse");

                  if (uploadResponse != null) {
                    print("Image URL: ${uploadResponse["url"]}");
                    walkinToEdit["pickupImages"] = uploadResponse["url"];
                  } else {
                    // Handle the case where image upload fails
                    print("Image upload failed");
                    return;
                  }
                }

                final url = Uri.parse(
                    'https://lpg-api-06n8.onrender.com/api/v1/transactions/$id');
                final headers = {'Content-Type': 'application/json'};

                final response = await http.patch(
                  url,
                  headers: headers,
                  body: jsonEncode(walkinToEdit),
                );

                if (response.statusCode == 200) {
                  fetchData();

                  Navigator.pop(context);
                } else {
                  print(
                      'Failed to update the walkin. Status code: ${response.statusCode}');
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
        'https://lpg-api-06n8.onrender.com/api/v1/transactions/?search=$query'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> walkinData = (data['data'] as List)
          .where((userData) =>
              userData is Map<String, dynamic> &&
              userData.containsKey('type') &&
              userData['type'] == 'Walkin')
          .map((userData) => userData as Map<String, dynamic>)
          .toList();

      setState(() {
        walkinDataList = walkinData;
      });
    } else {}
  }

  void openAddWalkinDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController contactNumberController = TextEditingController();
    TextEditingController paymentMethodController = TextEditingController();
    TextEditingController totalController = TextEditingController();
    TextEditingController itemsController = TextEditingController();
    TextEditingController pickupImagesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Walkin'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: contactNumberController,
                  decoration: InputDecoration(labelText: 'ContactNumber'),
                ),
                TextFormField(
                  controller: paymentMethodController,
                  decoration: InputDecoration(labelText: 'PaymentMethod'),
                ),
                TextFormField(
                  controller: totalController,
                  decoration: InputDecoration(labelText: 'Total'),
                ),
                TextFormField(
                  controller: itemsController,
                  decoration: InputDecoration(labelText: 'Items'),
                ),
                Text(
                  "\npickupImage",
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey[700],
                  ),
                ),
                //BREAKKKKKKKKKK
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
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Map<String, dynamic> newWalkin = {
                  "name": nameController.text,
                  "contactNumber": contactNumberController.text,
                  "paymentMethod": paymentMethodController.text,
                  "total": totalController.text,
                  "items": itemsController.text,
                  "pickupImages": "",
                  "completed": "true",
                  "type": "Walkin",
                };
                addWalkinToAPI(newWalkin);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void deleteData(String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Data'),
          content: Text('Are you sure you want to delete this data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final url = Uri.parse(
                    'https://lpg-api-06n8.onrender.com/api/v1/transactions/$id');
                final response = await http.delete(url);

                if (response.statusCode == 200) {
                  setState(() {
                    walkinDataList.removeWhere((data) => data['_id'] == id);
                  });

                  Navigator.pop(context);
                } else {
                  print(
                      'Failed to delete the data. Status code: ${response.statusCode}');
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
          'Walkin CRUD',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
        iconTheme: IconThemeData(color: Color(0xFF232937)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            color: Color(0xFF232937),
            onPressed: () {
              openAddWalkinDialog();
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
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      search(searchController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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
                    color: Color(0xFF232937),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: DataTable(
                  sortAscending: _sortAscending,
                  sortColumnIndex:
                      0, // Set to the index of the column you want to initially sort by
                  columns: <DataColumn>[
                    // _buildDataColumnWithSort(
                    //     'createdAt', 'Created At', 'Sort by Created At'),
                    _buildDataColumnWithSort('createdAt', 'Name', 'Name'),
                    _buildDataColumn('contactNumber', 'Contact Number'),
                    _buildDataColumn('paymentMethod', 'Payment Method'),
                    _buildDataColumn('Total', 'Total'),
                    _buildDataColumn('items', 'Items'),
                    _buildDataColumn('pickupImages', 'Pickup Images'),
                    _buildDataColumn('completed', 'Completed'),
                    _buildDataColumn('type', 'Type'),
                    _buildDataColumn('Actions', 'Update and Delete'),
                  ],
                  rows: _buildDataRows(),
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
    );
  }

  DataColumn _buildDataColumnWithSort(
      String columnName, String label, String tooltip) {
    return DataColumn(
      label: Text(label),
      tooltip: tooltip,
      onSort: (columnIndex, ascending) {
        setState(() {
          _sortColumn = columnName;
          _sortAscending = ascending;
        });
      },
    );
  }

  DataColumn _buildDataColumn(String columnName, String label) {
    return DataColumn(label: Text(label));
  }

  int _getColumnIndex(String columnName) {
    for (int i = 0; i < walkinDataList.length; i++) {
      if (walkinDataList[i].containsKey(columnName)) {
        return i;
      }
    }
    return -1;
  }

  List<DataRow> _buildDataRows() {
    List<Map<String, dynamic>> sortedList = List.from(walkinDataList);

    sortedList.sort((a, b) {
      DateTime aDate = DateTime.parse(a['createdAt']);
      DateTime bDate = DateTime.parse(b['createdAt']);

      if (_sortAscending) {
        return aDate.compareTo(bDate);
      } else {
        return bDate.compareTo(aDate);
      }
    });

    return sortedList.map((userData) {
      final id = userData['_id'];

      return DataRow(
        cells: <DataCell>[
          DataCell(Text(userData['name'].toString() ?? ''), placeholder: false),
          DataCell(Text(userData['contactNumber'].toString() ?? ''),
              placeholder: false),
          DataCell(Text(userData['paymentMethod'].toString() ?? ''),
              placeholder: false),
          DataCell(Text(userData['total'].toString() ?? ''),
              placeholder: false),
          DataCell(Text(userData['items'].toString() ?? ''),
              placeholder: false),
          DataCell(Text(userData['pickupImages'].toString() ?? ''),
              placeholder: false),
          DataCell(Text(userData['completed'].toString() ?? ''),
              placeholder: false),
          DataCell(Text(userData['type'] ?? ''), placeholder: false),
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
    }).toList();
  }
}
