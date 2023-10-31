import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class walkinPage extends StatefulWidget {
  @override
  _walkinPageState createState() => _walkinPageState();
}

class _walkinPageState extends State<walkinPage> {
  List<Map<String, dynamic>> walkinDataList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  int currentPage = 1;
  int limit = 2;

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

    TextEditingController riderController =
        TextEditingController(text: walkinToEdit['rider'].toString());

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
                TextFormField(
                  controller: riderController,
                  decoration: InputDecoration(labelText: 'Rider'),
                ),
                TextFormField(
                  controller: pickupImagesController,
                  decoration: InputDecoration(labelText: 'pickupImages'),
                ),
                TextFormField(
                  controller: completedController,
                  decoration: InputDecoration(labelText: 'completed'),
                ),
                TextFormField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: 'type'),
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
                walkinToEdit['deliveryLocation'] =
                    walkinToEdit['name'] = nameController.text;
                walkinToEdit['contactNumber'] = contactNumberController.text;

                walkinToEdit['paymentMethod'] = paymentMethodController.text;

                walkinToEdit['total'] = totalController.text;
                walkinToEdit['items'] = itemsController.text;

                walkinToEdit['rider'] = riderController.text;

                walkinToEdit['pickupImages'] = pickupImagesController.text;

                walkinToEdit['completed'] = completedController.text;
                walkinToEdit['type'] = typeController.text;

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

    TextEditingController completedController = TextEditingController();

    TextEditingController typeController = TextEditingController();

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
                  decoration: InputDecoration(labelText: 'Contact Number'),
                ),
                TextFormField(
                  controller: pickupImagesController,
                  decoration: InputDecoration(labelText: 'pickupImages'),
                ),
                TextFormField(
                  controller: completedController,
                  decoration: InputDecoration(labelText: 'completed'),
                ),
                TextFormField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: 'type'),
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
              onPressed: () {
                Map<String, dynamic> newWalkin = {
                  "name": nameController.text,
                  "contactNumber": contactNumberController.text,
                  "paymentMethod": paymentMethodController.text,
                  "total": totalController.text,
                  "items": itemsController.text,
                  "pickupImages": pickupImagesController.text,
                  "completed": completedController.text,
                  "type": typeController.text,
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
                  columns: <DataColumn>[
                    DataColumn(label: Text('name')),
                    DataColumn(label: Text('contactNumber')),
                    DataColumn(label: Text('paymentMethod')),
                    DataColumn(label: Text('Total')),
                    DataColumn(label: Text('items')),
                    DataColumn(label: Text('pickupImages')),
                    DataColumn(label: Text('completed')),
                    DataColumn(label: Text('type')),
                    DataColumn(
                      label: Text('Actions'),
                      tooltip: 'Update and Delete',
                    ),
                  ],
                  rows: walkinDataList.map((userData) {
                    final id = userData['_id'];

                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(userData['name'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(userData['contactNumber'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(userData['paymentMethod'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['total'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['items'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(userData['pickupImages'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['completed'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['type'] ?? ''),
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
}
