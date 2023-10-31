import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriversPage extends StatefulWidget {
  @override
  _DriversPageState createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  List<Map<String, dynamic>> riderDataList = [];
  TextEditingController searchController =
      TextEditingController(); // Controller for the search field

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  int currentPage = 1;
  int limit = 30;

  Future<void> fetchData({int page = 1}) async {
    final response = await http.get(Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/users/?page=$page&limit=$limit'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> riderData = (data['data'] as List)
          .where((userData) =>
              userData is Map<String, dynamic> &&
              userData['__t'] == 'Rider') // Filter for 'Rider'
          .map((userData) => userData as Map<String, dynamic>)
          .toList();

      setState(() {
        // Clear the existing data before adding new data
        riderDataList.clear();
        riderDataList.addAll(riderData);
        currentPage = page; // Update the current page number
      });
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  Future<void> addRiderToAPI(Map<String, dynamic> newRider) async {
    final url = Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/users');
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(newRider),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // The new rider has been successfully added or updated
      // You can also handle the response data if needed

      // Update the UI to display the newly added or updated rider (if required)
      fetchData(); // Refresh the data list

      Navigator.pop(context); // Close the add rider dialog
    } else {
      // Handle any other status codes (e.g., 400 for validation errors, 500 for server errors, etc.)
      print(
          'Failed to add or update the rider. Status code: ${response.statusCode}');
      // You can also display an error message to the user
    }
  }

  void updateData(String id) {
    // Find the rider data to edit
    Map<String, dynamic> riderToEdit =
        riderDataList.firstWhere((data) => data['_id'] == id);

    // Create controllers for each field
    TextEditingController nameController =
        TextEditingController(text: riderToEdit['name']);
    TextEditingController contactNumberController =
        TextEditingController(text: riderToEdit['contactNumber']);
    TextEditingController addressController =
        TextEditingController(text: riderToEdit['address']);
    TextEditingController gcashController =
        TextEditingController(text: riderToEdit['gcash'].toString());
    TextEditingController gcashQrController =
        TextEditingController(text: riderToEdit['gcashQr'].toString());

    TextEditingController typeController =
        TextEditingController(text: riderToEdit['__t']);
    TextEditingController licenseController =
        TextEditingController(text: riderToEdit['license']);
    TextEditingController seminarCertController =
        TextEditingController(text: riderToEdit['seminarCert']);
    TextEditingController emailController =
        TextEditingController(text: riderToEdit['email']);
    TextEditingController passwordController =
        TextEditingController(text: riderToEdit['password']);
    TextEditingController imageController =
        TextEditingController(text: riderToEdit['image']);

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
                  decoration: InputDecoration(labelText: 'Contact Number'),
                ),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextFormField(
                  controller: gcashController,
                  decoration: InputDecoration(labelText: 'Gcash'),
                ),
                TextFormField(
                  controller: gcashQrController,
                  decoration: InputDecoration(labelText: 'GcashQr'),
                ),
                TextFormField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: '__t'),
                ),
                TextFormField(
                  controller: licenseController,
                  decoration: InputDecoration(labelText: 'license'),
                ),
                TextFormField(
                  controller: seminarCertController,
                  decoration: InputDecoration(labelText: 'seminarCert'),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'email'),
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'password'),
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
                // Update the rider data based on the controllers
                riderToEdit['name'] = nameController.text;
                riderToEdit['contactNumber'] = contactNumberController.text;
                riderToEdit['address'] = addressController.text;
                riderToEdit['gcash'] = gcashController.text;
                riderToEdit['gcashQr'] = gcashQrController.text;
                riderToEdit['__t'] = typeController.text;
                riderToEdit['license'] = licenseController.text;
                riderToEdit['seminarCert'] = seminarCertController.text;

                riderToEdit['email'] = emailController.text;
                riderToEdit['password'] = passwordController.text;
                riderToEdit['image'] = imageController.text;

                // Send a request to your API to update the data with the new values
                final url = Uri.parse(
                    'https://lpg-api-06n8.onrender.com/api/v1/users/$id');
                final headers = {'Content-Type': 'application/json'};

                final response = await http.patch(
                  url,
                  headers: headers,
                  body: jsonEncode(riderToEdit),
                );

                if (response.statusCode == 200) {
                  // The data has been successfully updated
                  // You can also handle the response data if needed

                  // Update the UI to display the newly updated rider (if required)
                  fetchData(); // Refresh the data list

                  Navigator.pop(context); // Close the edit rider dialog
                } else {
                  // Handle any other status codes (e.g., 400 for validation errors, 500 for server errors, etc.)
                  print(
                      'Failed to update the rider. Status code: ${response.statusCode}');
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
        'https://lpg-api-06n8.onrender.com/api/v1/users/?search=$query'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> riderData = (data['data'] as List)
          .where((userData) =>
              userData is Map<String, dynamic> &&
              userData.containsKey('__t') &&
              userData['__t'] == 'Rider')
          .map((userData) => userData as Map<String, dynamic>)
          .toList();

      setState(() {
        riderDataList = riderData;
      });
    } else {}
  }

  void openAddRiderDialog() {
    // Create controllers for each field
    TextEditingController nameController = TextEditingController();
    TextEditingController contactNumberController = TextEditingController();
    TextEditingController addressController = TextEditingController();
    TextEditingController gcashController = TextEditingController();
    TextEditingController gcashQrController = TextEditingController();
    TextEditingController typeController = TextEditingController();
    TextEditingController licenseController = TextEditingController();
    TextEditingController seminarCertController = TextEditingController();

    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Rider'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Add text form fields for rider data input
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: contactNumberController,
                  decoration: InputDecoration(labelText: 'Contact Number'),
                ),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextFormField(
                  controller: gcashController,
                  decoration: InputDecoration(labelText: 'Gcash'),
                ),
                TextFormField(
                  controller: gcashQrController,
                  decoration: InputDecoration(labelText: 'GcashQr'),
                ),
                TextFormField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: '__t'),
                ),
                TextFormField(
                  controller: licenseController,
                  decoration: InputDecoration(labelText: 'license'),
                ),
                TextFormField(
                  controller: seminarCertController,
                  decoration: InputDecoration(labelText: 'seminarCert'),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'email'),
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'password'),
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
                // Create a new rider object from the input data
                Map<String, dynamic> newRider = {
                  "name": nameController.text,
                  "contactNumber": contactNumberController.text,
                  "address": addressController.text,
                  "gcash": gcashController.text,
                  "gcashQr": gcashQrController.text,
                  "__t": typeController.text,
                  "license": licenseController.text,
                  "seminarCert": seminarCertController.text,
                  "email": emailController.text,
                  "password": passwordController.text,
                  "image": imageController.text,
                };

                // Call the function to add the new rider to the API
                addRiderToAPI(newRider);
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
                    'https://lpg-api-06n8.onrender.com/api/v1/users/$id');
                final response = await http.delete(url);

                if (response.statusCode == 200) {
                  // Data has been successfully deleted
                  // Update the UI to remove the deleted data
                  setState(() {
                    riderDataList.removeWhere((data) => data['_id'] == id);
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
          'Rider CRUD',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
        iconTheme: IconThemeData(color: Color(0xFF232937)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            color: Color(0xFF232937),
            onPressed: () {
              // Open the dialog to add a new rider
              openAddRiderDialog();
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
                    DataColumn(label: Text('Contact Number')),
                    DataColumn(label: Text('Address')),
                    DataColumn(label: Text('Gcash')),
                    DataColumn(label: Text('GcashQr')),
                    DataColumn(label: Text('Type')),
                    DataColumn(
                      label: Text('Actions'),
                      tooltip: 'Update and Delete',
                    ),
                  ],
                  rows: riderDataList.map((userData) {
                    final id = userData['_id'];

                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(userData['name'] ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['contactNumber'] ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['address'] ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['gcash'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['gcashQr'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['__t'] ?? ''),
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
