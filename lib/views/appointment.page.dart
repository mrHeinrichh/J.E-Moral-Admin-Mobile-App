import 'package:admin_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AppointmentPage extends StatefulWidget {
  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  List<Map<String, dynamic>> customerDataList = [];
  TextEditingController searchController = TextEditingController();

  bool loadingData = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadingData = true;
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
        loadingData = false;
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
                      .contains(query.toLowerCase()) ||
                  userData['appointmentDate']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  _isMonthQuery(query, userData['appointmentDate'])))
          .map((userData) => userData as Map<String, dynamic>)
          .toList();

      setState(() {
        customerDataList = filteredData;
      });
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }
  }

  bool _isMonthQuery(String query, String appointmentDate) {
    final months = {
      'january': '01',
      'jan': '01',
      'february': '02',
      'feb': '02',
      'march': '03',
      'mar': '03',
      'april': '04',
      'apr': '04',
      'may': '05',
      'june': '06',
      'jun': '06',
      'july': '07',
      'jul': '07',
      'august': '08',
      'aug': '08',
      'september': '09',
      'sep': '09',
      'october': '10',
      'oct': '10',
      'november': '11',
      'nov': '11',
      'december': '12',
      'dec': '12',
    };

    final lowerCaseQuery = query.toLowerCase();
    if (months.containsKey(lowerCaseQuery)) {
      final numericMonth = months[lowerCaseQuery];
      return appointmentDate.contains('-$numericMonth-');
    }
    return false;
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
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Appointment List',
          style: TextStyle(
            color: const Color(0xFF050404).withOpacity(0.9),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: const Color(0xFF050404).withOpacity(0.8),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.black,
            height: 0.2,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: loadingData
          ? Center(
              child: LoadingAnimationWidget.flickr(
                leftDotColor: const Color(0xFF050404).withOpacity(0.8),
                rightDotColor: const Color(0xFFd41111).withOpacity(0.8),
                size: 40,
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF050404),
              strokeWidth: 2.5,
              onRefresh: () async {
                await fetchData();
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                onChanged: (query) {
                                  search(query);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF050404)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF050404)),
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      search(searchController.text);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        Icons.search,
                                        color: Color(0xFF050404),
                                      ),
                                    ),
                                  ),
                                ),
                                cursorColor: const Color(0xFF050404),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (customerDataList.isEmpty && !loadingData)
                      const Center(
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Text(
                              'No appointments to display.',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    if (customerDataList.isNotEmpty)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: customerDataList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final userData = customerDataList[index];
                                  final id = userData['_id'];

                                  return Column(
                                    children: [
                                      Card(
                                        color: Colors.white,
                                        elevation: 4,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 30,
                                                    backgroundImage:
                                                        NetworkImage(
                                                      userData['image'] ?? '',
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        TitleMedium(
                                                            text: userData[
                                                                'name']),
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
                                                              'Date: ${DateFormat('MMMM d, y').format(DateTime.parse(userData['appointmentDate']))}',
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
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                                  0xFF050404)
                                                              .withOpacity(0.9),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 14),
                                                    ),
                                                    onPressed: () async {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                              'Confirmation',
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            content: const Text(
                                                              'Are you sure you want to approve this appointment?',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  foregroundColor: const Color(
                                                                          0xFF050404)
                                                                      .withOpacity(
                                                                          0.8),
                                                                ),
                                                                child: const Text(
                                                                    'Cancel'),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  updateAppointmentStatus(
                                                                      id);
                                                                },
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  foregroundColor: const Color(
                                                                          0xFF050404)
                                                                      .withOpacity(
                                                                          0.9),
                                                                ),
                                                                child:
                                                                    const Text(
                                                                  'Approve',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: const Text(
                                                      'Approve',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                    ],
                                  );
                                },
                              ),
                              if (customerDataList.isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (currentPage > 1)
                                      ElevatedButton(
                                        onPressed: () {
                                          fetchData(page: currentPage - 1);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF050404)
                                                  .withOpacity(0.9),
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
                                        backgroundColor: const Color(0xFF050404)
                                            .withOpacity(0.9),
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
                  ],
                ),
              ),
            ),
    );
  }
}
