import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class transactionPage extends StatefulWidget {
  @override
  _transactionPageState createState() => _transactionPageState();
}

class _transactionPageState extends State<transactionPage> {
  List<Map<String, dynamic>> transactionDataList = [];
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

      final List<Map<String, dynamic>> transactionData = (data['data'] as List)
          // .where((userData) =>
          //     userData is Map<String, dynamic> && userData['type'] == 'Online')
          .map((userData) => userData as Map<String, dynamic>)
          .toList();

      setState(() {
        transactionDataList.clear();
        transactionDataList.addAll(transactionData);
        currentPage = page;
      });
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  Future<void> addTransactionToAPI(Map<String, dynamic> newTransaction) async {
    final url =
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/transactions');
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(newTransaction),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      fetchData();

      Navigator.pop(context);
    } else {
      print(
          'Failed to add or update the transaction. Status code: ${response.statusCode}');
    }
  }

  void updateData(String id) {
    Map<String, dynamic> transactionToEdit =
        transactionDataList.firstWhere((data) => data['_id'] == id);

    TextEditingController deliveryLocationController = TextEditingController(
        text: transactionToEdit['deliveryLocation'].toString());
    TextEditingController nameController =
        TextEditingController(text: transactionToEdit['name'].toString());
    TextEditingController contactNumberController = TextEditingController(
        text: transactionToEdit['contactNumber'].toString());
    TextEditingController houseLotBlkController = TextEditingController(
        text: transactionToEdit['houseLotBlk'].toString());
    TextEditingController barangayController =
        TextEditingController(text: transactionToEdit['barangay'].toString());
    TextEditingController paymentMethodController = TextEditingController(
        text: transactionToEdit['paymentMethod'].toString());
    TextEditingController assemblyController =
        TextEditingController(text: transactionToEdit['assembly'].toString());
    TextEditingController deliveryTimeController = TextEditingController(
        text: transactionToEdit['deliveryTime'].toString());
    TextEditingController totalController =
        TextEditingController(text: transactionToEdit['total'].toString());
    TextEditingController itemsController =
        TextEditingController(text: transactionToEdit['items'].toString());
    TextEditingController customerController =
        TextEditingController(text: transactionToEdit['customer'].toString());
    TextEditingController riderController =
        TextEditingController(text: transactionToEdit['rider'].toString());
    TextEditingController hasFeedbackController = TextEditingController(
        text: transactionToEdit['hasFeedback'].toString());
    TextEditingController feedbackController =
        TextEditingController(text: transactionToEdit['feedback']);
    TextEditingController ratingController =
        TextEditingController(text: transactionToEdit['rating'].toString());
    TextEditingController pickupImagesController = TextEditingController(
        text: transactionToEdit['pickupImages'].toString());
    TextEditingController completionImagesController = TextEditingController(
        text: transactionToEdit['completionImages'].toString());
    TextEditingController cancellationImagesController = TextEditingController(
        text: transactionToEdit['cancellationImages'].toString());
    TextEditingController cancelReasonController = TextEditingController(
        text: transactionToEdit['cancelReason'].toString());
    TextEditingController pickedUpController =
        TextEditingController(text: transactionToEdit['pickedUp'].toString());
    TextEditingController cancelledController =
        TextEditingController(text: transactionToEdit['cancelled'].toString());
    TextEditingController completedController =
        TextEditingController(text: transactionToEdit['completed'].toString());
    TextEditingController typeController =
        TextEditingController(text: transactionToEdit['type']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Data'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: deliveryLocationController,
                  decoration: InputDecoration(labelText: 'DeliveryLocation'),
                ),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: contactNumberController,
                  decoration: InputDecoration(labelText: 'ContactNumber'),
                ),
                TextFormField(
                  controller: houseLotBlkController,
                  decoration: InputDecoration(labelText: 'HouseLotBlk'),
                ),
                TextFormField(
                  controller: barangayController,
                  decoration: InputDecoration(labelText: 'Barangay'),
                ),
                TextFormField(
                  controller: paymentMethodController,
                  decoration: InputDecoration(labelText: 'PaymentMethod'),
                ),
                TextFormField(
                  controller: assemblyController,
                  decoration: InputDecoration(labelText: 'Assembly'),
                ),
                TextFormField(
                  controller: deliveryTimeController,
                  decoration: InputDecoration(labelText: 'DeliveryTime'),
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
                  controller: customerController,
                  decoration: InputDecoration(labelText: 'Customer'),
                ),
                TextFormField(
                  controller: riderController,
                  decoration: InputDecoration(labelText: 'Rider'),
                ),
                TextFormField(
                  controller: hasFeedbackController,
                  decoration: InputDecoration(labelText: 'HasFeedback'),
                ),
                TextFormField(
                  controller: feedbackController,
                  decoration: InputDecoration(labelText: 'feedback'),
                ),
                TextFormField(
                  controller: ratingController,
                  decoration: InputDecoration(labelText: 'rating'),
                ),
                TextFormField(
                  controller: pickupImagesController,
                  decoration: InputDecoration(labelText: 'pickupImages'),
                ),
                TextFormField(
                  controller: completionImagesController,
                  decoration: InputDecoration(labelText: 'completionImages'),
                ),
                TextFormField(
                  controller: cancellationImagesController,
                  decoration: InputDecoration(labelText: 'cancellationImages'),
                ),
                TextFormField(
                  controller: cancelReasonController,
                  decoration: InputDecoration(labelText: 'cancelReason'),
                ),
                TextFormField(
                  controller: pickedUpController,
                  decoration: InputDecoration(labelText: 'pickedUp'),
                ),
                TextFormField(
                  controller: cancelledController,
                  decoration: InputDecoration(labelText: 'cancelled'),
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
                transactionToEdit['deliveryLocation'] =
                    deliveryLocationController.text;
                transactionToEdit['name'] = nameController.text;
                transactionToEdit['contactNumber'] =
                    contactNumberController.text;
                transactionToEdit['houseLotBlk'] = houseLotBlkController.text;
                transactionToEdit['barangay'] = barangayController.text;
                transactionToEdit['paymentMethod'] =
                    paymentMethodController.text;
                transactionToEdit['assembly'] = assemblyController.text;
                transactionToEdit['deliveryTime'] = deliveryTimeController.text;

                transactionToEdit['total'] = totalController.text;
                transactionToEdit['items'] = itemsController.text;
                transactionToEdit['customer'] = customerController.text;
                transactionToEdit['rider'] = riderController.text;
                transactionToEdit['hasFeedback'] = hasFeedbackController.text;
                transactionToEdit['feedback'] = feedbackController.text;
                transactionToEdit['rating'] = ratingController.text;
                transactionToEdit['pickupImages'] = pickupImagesController.text;
                transactionToEdit['completionImages'] =
                    completionImagesController.text;
                transactionToEdit['cancellationImages'] =
                    cancellationImagesController.text;
                transactionToEdit['cancelReason'] = cancelReasonController.text;
                transactionToEdit['pickedUp'] = pickedUpController.text;
                transactionToEdit['cancelled'] = cancelledController.text;
                transactionToEdit['completed'] = completedController.text;
                transactionToEdit['type'] = typeController.text;

                final url = Uri.parse(
                    'https://lpg-api-06n8.onrender.com/api/v1/transactions/$id');
                final headers = {'Content-Type': 'application/json'};

                final response = await http.patch(
                  url,
                  headers: headers,
                  body: jsonEncode(transactionToEdit),
                );

                if (response.statusCode == 200) {
                  fetchData();

                  Navigator.pop(context);
                } else {
                  print(
                      'Failed to update the transaction. Status code: ${response.statusCode}');
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

      final List<Map<String, dynamic>> transactionData = (data['data'] as List)
          .where((userData) =>
              userData is Map<String, dynamic> &&
              userData.containsKey('type') &&
              userData['type'] == 'name')
          .map((userData) => userData as Map<String, dynamic>)
          .toList();

      setState(() {
        transactionDataList = transactionData;
      });
    } else {}
  }

  void openAddTransactionDialog() {
    TextEditingController deliveryLocationController = TextEditingController();
    TextEditingController nameController = TextEditingController();

    TextEditingController contactNumberController = TextEditingController();

    TextEditingController houseLotBlkController = TextEditingController();

    TextEditingController barangayController = TextEditingController();

    TextEditingController paymentMethodController = TextEditingController();
    TextEditingController assemblyController = TextEditingController();
    TextEditingController deliveryTimeController = TextEditingController();

    TextEditingController totalController = TextEditingController();
    TextEditingController itemsController = TextEditingController();
    TextEditingController customerController = TextEditingController();
    TextEditingController riderController = TextEditingController();
    TextEditingController hasFeedbackController = TextEditingController();
    TextEditingController feedbackController = TextEditingController();
    TextEditingController ratingController = TextEditingController();
    TextEditingController pickupImagesController = TextEditingController();
    TextEditingController completionImagesController = TextEditingController();
    TextEditingController cancellationImagesController =
        TextEditingController();
    TextEditingController cancelReasonController = TextEditingController();

    TextEditingController pickedUpController = TextEditingController();

    TextEditingController cancelledController = TextEditingController();

    TextEditingController completedController = TextEditingController();

    TextEditingController typeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Transaction'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: deliveryLocationController,
                  decoration: InputDecoration(labelText: 'DeliveryLocation'),
                ),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: contactNumberController,
                  decoration: InputDecoration(labelText: 'ContactNumber'),
                ),
                TextFormField(
                  controller: houseLotBlkController,
                  decoration: InputDecoration(labelText: 'HouseLotBlk'),
                ),
                TextFormField(
                  controller: barangayController,
                  decoration: InputDecoration(labelText: 'Barangay'),
                ),
                TextFormField(
                  controller: paymentMethodController,
                  decoration: InputDecoration(labelText: 'PaymentMethod'),
                ),
                TextFormField(
                  controller: assemblyController,
                  decoration: InputDecoration(labelText: 'Assembly'),
                ),
                TextFormField(
                  controller: deliveryTimeController,
                  decoration: InputDecoration(labelText: 'DeliveryTime'),
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
                  controller: customerController,
                  decoration: InputDecoration(labelText: 'Customer'),
                ),
                TextFormField(
                  controller: riderController,
                  decoration: InputDecoration(labelText: 'Rider'),
                ),
                TextFormField(
                  controller: hasFeedbackController,
                  decoration: InputDecoration(labelText: 'HasFeedback'),
                ),
                TextFormField(
                  controller: feedbackController,
                  decoration: InputDecoration(labelText: 'feedback'),
                ),
                TextFormField(
                  controller: ratingController,
                  decoration: InputDecoration(labelText: 'rating'),
                ),
                TextFormField(
                  controller: pickupImagesController,
                  decoration: InputDecoration(labelText: 'pickupImages'),
                ),
                TextFormField(
                  controller: completionImagesController,
                  decoration: InputDecoration(labelText: 'completionImages'),
                ),
                TextFormField(
                  controller: cancellationImagesController,
                  decoration: InputDecoration(labelText: 'cancellationImages'),
                ),
                TextFormField(
                  controller: cancelReasonController,
                  decoration: InputDecoration(labelText: 'cancelReason'),
                ),
                TextFormField(
                  controller: pickedUpController,
                  decoration: InputDecoration(labelText: 'pickedUp'),
                ),
                TextFormField(
                  controller: cancelledController,
                  decoration: InputDecoration(labelText: 'cancelled'),
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
                Map<String, dynamic> newTransaction = {
                  "deliveryLocation": deliveryLocationController.text,
                  "name": nameController.text,
                  "contactNumber": contactNumberController.text,
                  "houseLotBlk": houseLotBlkController.text,
                  "barangay": barangayController.text,
                  "paymentMethod": paymentMethodController.text,
                  "assembly": assemblyController.text,
                  "deliveryTime": deliveryTimeController.text,
                  "total": totalController.text,
                  "items": itemsController.text,
                  "customer": customerController.text,
                  "rider": riderController.text,
                  "hasFeedback": hasFeedbackController.text,
                  "feedback": feedbackController.text,
                  "rating": ratingController.text,
                  "pickupImages": pickupImagesController.text,
                  "completionImages": completionImagesController.text,
                  "cancellationImages": cancellationImagesController.text,
                  "cancelReason": cancelReasonController.text,
                  "pickedUp": pickedUpController.text,
                  "cancelled": cancelledController.text,
                  "completed": completedController.text,
                  "type": typeController.text,
                };
                addTransactionToAPI(newTransaction);
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
                    transactionDataList
                        .removeWhere((data) => data['_id'] == id);
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
          'Transaction CRUD',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
        iconTheme: IconThemeData(color: Color(0xFF232937)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            color: Color(0xFF232937),
            onPressed: () {
              openAddTransactionDialog();
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
                    DataColumn(label: Text('deliveryLocation')),
                    DataColumn(label: Text('name')),
                    DataColumn(label: Text('contactNumber')),
                    DataColumn(label: Text('houseLotBlk')),
                    DataColumn(label: Text('barangay')),
                    DataColumn(label: Text('paymentMethod')),
                    DataColumn(label: Text('assembly')),
                    DataColumn(label: Text('deliveryTime')),
                    DataColumn(label: Text('Total')),
                    DataColumn(label: Text('items')),
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Rider')),
                    DataColumn(label: Text('HasFeedback')),
                    DataColumn(label: Text('feedback')),
                    DataColumn(label: Text('rating')),
                    DataColumn(label: Text('pickupImages')),
                    DataColumn(label: Text('completionImages')),
                    DataColumn(label: Text('cancellationImages')),
                    DataColumn(label: Text('cancelReason')),
                    DataColumn(label: Text('pickedUp')),
                    DataColumn(label: Text('cancelled')),
                    DataColumn(label: Text('completed')),
                    DataColumn(label: Text('type')),
                    DataColumn(
                      label: Text('Actions'),
                      tooltip: 'Update and Delete',
                    ),
                  ],
                  rows: transactionDataList.map((userData) {
                    final id = userData['_id'];

                    return DataRow(
                      cells: <DataCell>[
                        DataCell(
                            Text(userData['deliveryLocation'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['name'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(userData['contactNumber'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['houseLotBlk'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['barangay'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(userData['paymentMethod'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['assembly'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(userData['deliveryTime'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['total'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['items'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['customer'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['rider'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['hasFeedback'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['feedback'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['rating'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(userData['pickupImages'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(userData['completionImages'].toString() ?? ''),
                            placeholder: false),
                        DataCell(
                            Text(userData['cancellationImages'].toString() ??
                                ''),
                            placeholder: false),
                        DataCell(Text(userData['cancelReason'] ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['pickedUp'].toString() ?? ''),
                            placeholder: false),
                        DataCell(Text(userData['cancelled'].toString() ?? ''),
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
