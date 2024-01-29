import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/services.dart';
import 'package:admin_app/widgets/date_time_picker.dart';

class AnnouncementPage extends StatefulWidget {
  @override
  _AnnouncementPageState createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  File? _image;
  final _imageStreamController = StreamController<File?>.broadcast();

  List<Map<String, dynamic>> announcementDataList = [];
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

  Future<void> fetchData({int page = 1}) async {
    final response = await http.get(Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/announcements/?page=$page&limit=$limit'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> announcementData = (data['data'] as List)
          .where((announcementData) => announcementData is Map<String, dynamic>)
          .map((announcementData) => announcementData as Map<String, dynamic>)
          .toList();

      setState(() {
        announcementDataList.clear();
        announcementDataList.addAll(announcementData);
        currentPage = page;
      });
    } else {
      throw Exception('Failed to load data from the API');
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

  Future<void> addAnnouncementToAPI(
      Map<String, dynamic> newAnnouncement) async {
    final url =
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/announcements');
    final headers = {'Content-Type': 'application/json'};

    try {
      var uploadResponse = await uploadImageToServer(_image!);
      print("Upload Response: $uploadResponse");

      if (uploadResponse != null) {
        print("Image URL: ${uploadResponse["url"]}");
        newAnnouncement["image"] = uploadResponse["url"];

        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(newAnnouncement),
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

//NOT YET WORKING
  Future<void> search(String query) async {
    final response = await http.get(Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/announcements/?search=$query'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> announcementData = (data['data'] as List)
          .where((announcementData) =>
              announcementData is Map<String, dynamic> &&
              announcementData.containsKey('__v') &&
              announcementData['__v'] == 0)
          .map((announcementData) => announcementData as Map<String, dynamic>)
          .toList();

      setState(() {
        announcementDataList = announcementData;
      });
    } else {}
  }

  // TextEditingController dateStartController = TextEditingController();
  // DateTime? selectedStartDateTime;

  // Future<void> _selectedStartDateTime(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedStartDateTime ?? DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //   );

  //   if (picked != null) {
  //     final TimeOfDay? startPickedTime = await showTimePicker(
  //       context: context,
  //       initialTime: selectedStartDateTime != null
  //           ? TimeOfDay.fromDateTime(selectedStartDateTime!)
  //           : TimeOfDay.now(),
  //     );

  //     if (startPickedTime != null) {
  //       setState(() {
  //         selectedStartDateTime = DateTime(
  //           picked.year,
  //           picked.month,
  //           picked.day,
  //           startPickedTime.hour,
  //           startPickedTime.minute,
  //         );
  //         dateStartController.text = selectedStartDateTime.toString();
  //       });
  //     }
  //   }
  // }

  // TextEditingController dateEndController = TextEditingController();
  // DateTime? selectedEndDateTime;

  // Future<void> _selectedEndDateTime(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedEndDateTime ?? DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //   );

  //   if (picked != null) {
  //     final TimeOfDay? endPickedTime = await showTimePicker(
  //       context: context,
  //       initialTime: selectedEndDateTime != null
  //           ? TimeOfDay.fromDateTime(selectedEndDateTime!)
  //           : TimeOfDay.now(),
  //     );

  //     if (endPickedTime != null) {
  //       setState(() {
  //         selectedEndDateTime = DateTime(
  //           picked.year,
  //           picked.month,
  //           picked.day,
  //           endPickedTime.hour,
  //           endPickedTime.minute,
  //         );
  //         dateEndController.text = selectedEndDateTime.toString();
  //       });
  //     }
  //   }
  // }

  void openAddAnnouncementDialog() {
    TextEditingController textController = TextEditingController();
    TextEditingController imageController = TextEditingController();

    TextEditingController dateStartController = TextEditingController();
    TextEditingController dateEndController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // dateStartController.clear();
        // dateEndController.clear();
        return AlertDialog(
          title: const Text('Add New Announcement'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: textController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the Announcement Title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DateTimePicker(
                    controller: dateStartController,
                    labelText: 'Starting Date and Time',
                  ),
                  const SizedBox(height: 10),
                  DateTimePicker(
                    controller: dateEndController,
                    labelText: 'Ending Date and Time',
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
                              "Upload Announcement Image",
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (_image == null) {
                    showCustomOverlay(context, 'Please Upload an Image');
                  } else {
                    Map<String, dynamic> newAnnouncement = {
                      "text": textController.text,
                      "image": imageController.text,
                      "start": dateStartController.text,
                      "end": dateEndController.text,
                    };
                    addAnnouncementToAPI(newAnnouncement);
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void updateData(String id) {
    Map<String, dynamic> announcementToEdit =
        announcementDataList.firstWhere((data) => data['_id'] == id);

    TextEditingController textController =
        TextEditingController(text: announcementToEdit['text']);
    TextEditingController dateStartController =
        TextEditingController(text: announcementToEdit['start']);
    TextEditingController dateEndController =
        TextEditingController(text: announcementToEdit['end']);
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Data'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: textController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the announcement title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DateTimePicker(
                    controller: dateStartController,
                    labelText: 'Starting Date and Time',
                    initialDateTime:
                        DateTime.parse(announcementToEdit['start']),
                  ),
                  const SizedBox(height: 10),
                  DateTimePicker(
                    controller: dateEndController,
                    labelText: 'Ending Date and Time',
                    initialDateTime: DateTime.parse(announcementToEdit['end']),
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
                              ? (announcementToEdit['image']?.toString() ?? '')
                                      .isNotEmpty
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                          announcementToEdit['image']
                                                  ?.toString() ??
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
                              "Upload Announcement Image",
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  announcementToEdit['text'] = textController.text;
                  announcementToEdit['start'] = dateStartController.text;
                  announcementToEdit['end'] = dateEndController.text;

                  if (_image != null) {
                    var uploadResponse = await uploadImageToServer(_image!);
                    if (uploadResponse != null) {
                      print("Image URL: ${uploadResponse["url"]}");
                      announcementToEdit["image"] = uploadResponse["url"];
                    } else {
                      print("Image upload failed");
                    }
                  }

                  final url = Uri.parse(
                      'https://lpg-api-06n8.onrender.com/api/v1/announcements/$id');
                  final headers = {'Content-Type': 'application/json'};

                  final response = await http.patch(
                    url,
                    headers: headers,
                    body: jsonEncode(announcementToEdit),
                  );

                  print('Response Body: ${response.body}');

                  if (response.statusCode == 200) {
                    fetchData();
                    Navigator.pop(context);
                  } else {
                    print(
                        'Failed to update the announcement. Status code: ${response.statusCode}');
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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

  void archiveData(String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('archive Data'),
          content: const Text('Are you sure you want to archive this data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final url = Uri.parse(
                    'https://lpg-api-06n8.onrender.com/api/v1/announcements/$id');
                final response = await http.delete(url);

                if (response.statusCode == 200) {
                  setState(() {
                    announcementDataList
                        .removeWhere((data) => data['_id'] == id);
                  });

                  Navigator.pop(context);
                } else {
                  print(
                      'Failed to archive the data. Status code: ${response.statusCode}');
                }
              },
              child: const Text('archive'),
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
          'Announcements CRUD',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF232937)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            color: const Color(0xFF232937),
            onPressed: () {
              openAddAnnouncementDialog();
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
                      decoration: const InputDecoration(
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
                    child: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF232937),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Title')),
                    DataColumn(label: Text('Image')),
                    DataColumn(
                      label: Text('Actions'),
                      tooltip: 'Update and archive',
                    ),
                  ],
                  rows: announcementDataList.map((announcementData) {
                    final id = announcementData['_id'];
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(announcementData['text'] ?? ''),
                            placeholder: false),
                        DataCell(Text(announcementData['image'] ?? ''),
                            placeholder: false),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => updateData(id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.archive),
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
                      fetchData(page: currentPage - 1);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                    ),
                    child: const Text('Previous'),
                  ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    fetchData(page: currentPage + 1);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                  ),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
