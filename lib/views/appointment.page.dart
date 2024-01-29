import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppointmentPage extends StatefulWidget {
  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  List<Map<String, dynamic>> customerDataList = [];
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  int currentPage = 1;
  int limit = 10;

  Future<void> fetchData({int page = 1}) async {
    final response = await http.get(Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/users/?page=$page&limit=$limit'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> customerData = (data['data'] as List)
          .where((userData) =>
              userData is Map<String, dynamic> &&
              userData['__t'] == 'Customer' &&
              userData['hasAppointment'] ==
                  true) // Filter for 'Customer' and "hasAppointment" is true
          .map((userData) => userData as Map<String, dynamic>)
          .toList();

      setState(() {
        // Clear the existing data before adding new data
        customerDataList.clear();
        customerDataList.addAll(customerData);
        currentPage = page; // Update the current page number
      });
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  Future<void> addCustomerToAPI(Map<String, dynamic> newCustomer) async {
    final url = Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/users');
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(newCustomer),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // The new customer has been successfully added or updated
      // You can also handle the response data if needed

      // Update the UI to display the newly added or updated customer (if required)
      fetchData(); // Refresh the data list

      Navigator.pop(context); // Close the add customer dialog
    } else {
      // Handle any other status codes (e.g., 400 for validation errors, 500 for server errors, etc.)
      print(
          'Failed to add or update the customer. Status code: ${response.statusCode}');
      // You can also display an error message to the user
    }
  }

  void updateData(String id) {
    // Find the customer data to edit
    Map<String, dynamic> customerToEdit =
        customerDataList.firstWhere((data) => data['_id'] == id);

    // Create controllers for each field
    TextEditingController nameController =
        TextEditingController(text: customerToEdit['name']);
    TextEditingController contactNumberController =
        TextEditingController(text: customerToEdit['contactNumber']);
    TextEditingController dateInterviewController =
        TextEditingController(text: customerToEdit['dateInterview']);
    TextEditingController timeInterviewController =
        TextEditingController(text: customerToEdit['timeInterview'].toString());
    TextEditingController hasAppointmentController = TextEditingController(
        text: customerToEdit['hasAppointment'].toString());

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
                  controller: dateInterviewController,
                  decoration: InputDecoration(labelText: 'DateInterview'),
                ),
                TextFormField(
                  controller: timeInterviewController,
                  decoration: InputDecoration(labelText: 'TimeInterview'),
                ),
                TextFormField(
                  controller: hasAppointmentController,
                  decoration: InputDecoration(labelText: 'HasAppointment'),
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
                // Update the customer data based on the controllers
                customerToEdit['name'] = nameController.text;
                customerToEdit['contactNumber'] = contactNumberController.text;
                customerToEdit['dateInterview'] = dateInterviewController.text;
                customerToEdit['timeInterview'] = timeInterviewController.text;
                customerToEdit['hasAppointment'] =
                    hasAppointmentController.text;

                // Send a request to your API to update the data with the new values
                final url = Uri.parse(
                    'https://lpg-api-06n8.onrender.com/api/v1/users/$id');
                final headers = {'Content-Type': 'application/json'};

                final response = await http.patch(
                  url,
                  headers: headers,
                  body: jsonEncode(customerToEdit),
                );

                if (response.statusCode == 200) {
                  // The data has been successfully updated
                  // You can also handle the response data if needed

                  // Update the UI to display the newly updated customer (if required)
                  fetchData(); // Refresh the data list

                  Navigator.pop(context); // Close the edit customer dialog
                } else {
                  // Handle any other status codes (e.g., 400 for validation errors, 500 for server errors, etc.)
                  print(
                      'Failed to update the customer. Status code: ${response.statusCode}');
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

      final List<Map<String, dynamic>> customerData = (data['data'] as List)
          .where((userData) =>
              userData is Map<String, dynamic> &&
              userData.containsKey('hasAppointment') &&
              userData['appointmentStatus'] == 'Pending' &&
              userData['appointmentStatus'] == 'Approved' &&
              userData['appointmentStatus'] == 'Declined')
          .map((userData) => userData as Map<String, dynamic>)
          .toList();

      setState(() {
        customerDataList = customerData;
      });
    } else {}
  }

  void openAddCustomerDialog() {
    // Create controllers for each field
    TextEditingController nameController = TextEditingController();
    TextEditingController contactNumberController = TextEditingController();
    TextEditingController dateInterviewController = TextEditingController();
    TextEditingController timeInterviewController = TextEditingController();
    TextEditingController hasAppointmentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Customer'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Add text form fields for customer data input
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: contactNumberController,
                  decoration: InputDecoration(labelText: 'Contact Number'),
                ),
                TextFormField(
                  controller: dateInterviewController,
                  decoration: InputDecoration(labelText: 'DateInterview'),
                ),
                TextFormField(
                  controller: timeInterviewController,
                  decoration: InputDecoration(labelText: 'TimeInterview'),
                ),
                TextFormField(
                  controller: hasAppointmentController,
                  decoration: InputDecoration(labelText: 'HasAppointment'),
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
                // Create a new customer object from the input data
                Map<String, dynamic> newCustomer = {
                  "name": nameController.text,
                  "contactNumber": contactNumberController.text,
                  "dateInterview": dateInterviewController.text,
                  "timeInterview": timeInterviewController.text,
                  "hasAppointment": hasAppointmentController.text,
                };

                // Call the function to add the new customer to the API
                addCustomerToAPI(newCustomer);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

// Function to handle data archive
  void archiveData(String id) async {
    // Show a confirmation dialog to confirm the deletion
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('archive Data'),
          content: Text('Are you sure you want to archive this data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Send a request to your API to archive the data
                final url = Uri.parse(
                    'https://lpg-api-06n8.onrender.com/api/v1/users/$id');
                final response = await http.delete(url);

                if (response.statusCode == 200) {
                  // Data has been successfully archived
                  // Update the UI to remove the archived data
                  setState(() {
                    customerDataList.removeWhere((data) => data['_id'] == id);
                  });

                  Navigator.pop(context); // Close the dialog
                } else {
                  // Handle any other status codes (e.g., 400 for validation errors, 500 for server errors, etc.)
                  print(
                      'Failed to archive the data. Status code: ${response.statusCode}');
                  // You can also display an error message to the user
                }
              },
              child: Text('archive'),
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
          'Appointment CRUD',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
        iconTheme: IconThemeData(color: Color(0xFF232937)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            color: Color(0xFF232937),
            onPressed: () {
              // Open the dialog to add a new customer
              openAddCustomerDialog();
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
                    DataColumn(label: Text('DateInterview')),
                    DataColumn(label: Text('TimeInterview')),
                    DataColumn(label: Text('HasAppointment')),
                    DataColumn(
                      label: Text('Actions'),
                      tooltip: 'Update and archive',
                    ),
                  ],
                  rows: customerDataList.map((userData) {
                    final id = userData['_id'];

                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(userData['name'] ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['contactNumber'] ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['dateInterview'] ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(userData['timeInterview'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(userData['hasAppointment'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => updateData(id),
                              ),
                              IconButton(
                                icon: Icon(Icons.archive),
                                onPressed: () => archiveData(id),
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
