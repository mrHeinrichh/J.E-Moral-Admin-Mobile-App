import 'package:admin_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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
        'https://lpg-api-06n8.onrender.com/api/v1/users/?filter={"__t": "Customer","appointmentStatus": "Pending"}&page=$page&limit=$limit'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<Map<String, dynamic>> customerData = (data['data'] as List)
          .where((customerData) => customerData is Map<String, dynamic>)
          .map((customerData) => customerData as Map<String, dynamic>)
          .toList();

      setState(() {
        customerDataList.clear();
        customerDataList.addAll(customerData);
        currentPage = page;
      });
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  Future<void> search(String query) async {
    final response = await http.get(
      Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/users/?filter={"__t": "Customer","appointmentStatus": "Pending"}&search=$query',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> filteredData = (data['data'] as List)
          .where((userData) =>
              userData is Map<String, dynamic> &&
              (userData['name']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  userData['contactNumber']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase())))
          .map((userData) => userData as Map<String, dynamic>)
          .toList();

      setState(() {
        customerDataList = filteredData;
      });
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }
  }

  Future<void> updateAppointmentStatus(String id) async {
    final url = Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/users/$id');
    final headers = {'Content-Type': 'application/json'};

    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode({
        'appointmentStatus': 'Approved',
        '__t': 'Customer',
      }),
    );

    if (response.statusCode == 200) {
      fetchData();
    } else {
      print(
          'Failed to update the customer. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: RefreshIndicator(
          onRefresh: () async {
            await fetchData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
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
                            decoration: InputDecoration(
                              hintText: 'Search',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              suffixIcon: InkWell(
                                onTap: () {
                                  search(searchController.text);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: const Icon(
                                    Icons.search,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: customerDataList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final userData = customerDataList[index];
                    final id = userData['_id'];

                    return Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                    userData['image'] ?? '',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TitleMedium(text: userData['name']),
                                      const Divider(),
                                      BodyMediumText(
                                        text:
                                            'Contact #: ${userData['contactNumber']}',
                                      ),
                                      BodyMediumText(
                                        text:
                                            'Appointment: ${userData['appointmentStatus']}',
                                      ),
                                      BodyMediumText(
                                        text:
                                            'Date: ${DateFormat('MMM d, y').format(DateTime.parse(userData['appointmentDate']))}',
                                      ),
                                      BodyMediumText(
                                        text:
                                            'Time: ${DateFormat('h:mm a ').format(DateTime.parse(userData['appointmentDate']))}',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: SizedBox(
                                width: 250,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF232937),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirmation'),
                                          content: const Text(
                                            'Are you sure you want to approve this appointment?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                updateAppointmentStatus(id);
                                              },
                                              child: const Text('Approve'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Text(
                                    'Approve',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                          backgroundColor: const Color(0xFF232937),
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
                        backgroundColor: const Color(0xFF232937),
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
      ),
    );
  }
}
