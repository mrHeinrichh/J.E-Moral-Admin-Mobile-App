import 'package:admin_app/widgets/custom_image_upload.dart';
import 'package:admin_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/services.dart';
import 'package:admin_app/widgets/date_time_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AnnouncementPage extends StatefulWidget {
  @override
  _AnnouncementPageState createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  File? _image;
  final _imageStreamController = StreamController<File?>.broadcast();

  final formKey = GlobalKey<FormState>();
  bool loadingData = false;

  List<Map<String, dynamic>> announcementDataList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    _imageStreamController.close();
    super.dispose();
  }

  void initState() {
    super.initState();
    loadingData = true;
    fetchData();
  }

  int currentPage = 1;
  int limit = 20;

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
        loadingData = false;
      });
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  Future<void> search(String query) async {
    final response = await http.get(
      Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/announcements/?search=$query&limit=500',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> filteredData = (data['data'] as List)
          .where((announcementData) =>
              announcementData is Map<String, dynamic> &&
              (announcementData['text']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  announcementData['start']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  announcementData['end']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  _isMonthQuery(query, announcementData['start']) ||
                  _isMonthQuery(query, announcementData['end'])))
          .map((announcementData) => announcementData as Map<String, dynamic>)
          .toList();

      setState(() {
        announcementDataList = filteredData;
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

    // final lowerCaseQuery = query.toLowerCase();
    // if (months.containsKey(lowerCaseQuery)) {
    //   final numericMonth = months[lowerCaseQuery];
    //   return appointmentDate.contains('-$numericMonth-');
    // } else {
    //   final DateFormat dateFormat = DateFormat('MMMM d, y - h:mm a');
    //   try {
    //     final DateTime parsedDate = dateFormat.parse(appointmentDate);
    //     final String formattedDate =
    //         dateFormat.format(parsedDate).toLowerCase();
    //     return formattedDate.contains(lowerCaseQuery);
    //   } catch (e) {
    //     return false;
    //   }
    // }
  }

  Future<void> _takeImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      _imageStreamController.sink.add(imageFile);
      setState(() {
        _image = imageFile;
      });
    }
  }

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

        final parsedResponse = json.decode(responseBody);

        if (parsedResponse.containsKey('data')) {
          final List<dynamic> data = parsedResponse['data'];

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

  void openAddAnnouncementDialog() {
    TextEditingController textController = TextEditingController();
    TextEditingController dateStartController = TextEditingController();
    TextEditingController dateEndController = TextEditingController();
    bool isImageSelected = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add New Announcement',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 10.0),
                  StreamBuilder<File?>(
                    stream: _imageStreamController.stream,
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 100,
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: snapshot.data == null
                                          ? const Icon(
                                              Icons.image,
                                              color: Colors.white,
                                              size: 50,
                                            )
                                          : Image.file(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ImageUploaderValidator(
                            takeImage: _takeImage,
                            pickImage: _pickImage,
                            buttonText: "Upload Announcement Image",
                            onImageSelected: (isSelected) {
                              setState(() {
                                isImageSelected = isSelected;
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  EditTextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: textController,
                    labelText: "Announcement Title",
                    hintText: 'Enter the Announcement Title',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Announcement Title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  DateTimePicker(
                    controller: dateStartController,
                    labelText: 'Starting Date and Time',
                  ),
                  const SizedBox(height: 15),
                  DateTimePicker(
                    controller: dateEndController,
                    labelText: 'Ending Date and Time',
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
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF050404).withOpacity(0.8),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (!isImageSelected) {
                  showCustomOverlay(
                      context, 'Please Upload an Announcement Image');
                } else {
                  if (formKey.currentState!.validate()) {
                    if (dateStartController.text.isEmpty) {
                      showCustomOverlay(
                          context, 'Please Select the Starting Date and Time');
                    } else if (dateEndController.text.isEmpty) {
                      showCustomOverlay(
                          context, 'Please Select the Ending Date and Time');
                    } else {
                      Map<String, dynamic> newAnnouncement = {
                        "text": textController.text,
                        "start": dateStartController.text,
                        "end": dateEndController.text,
                        "image": "",
                      };
                      addAnnouncementToAPI(newAnnouncement);
                    }
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF050404).withOpacity(0.9),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showCustomOverlay(BuildContext context, String message) {
    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.5,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFd41111).withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)!.insert(overlay);

    Future.delayed(const Duration(seconds: 2), () {
      overlay.remove();
    });
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Edit Announcement',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 10.0),
                  StreamBuilder<File?>(
                    stream: _imageStreamController.stream,
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 100,
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: snapshot.data == null &&
                                              (announcementToEdit['image'] ??
                                                      '')
                                                  .isEmpty
                                          ? const Icon(
                                              Icons.image,
                                              color: Colors.white,
                                              size: 50,
                                            )
                                          : snapshot.data != null
                                              ? Image.file(
                                                  snapshot.data!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                )
                                              : Image.network(
                                                  announcementToEdit['image']!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ImageUploader(
                            takeImage: _takeImage,
                            pickImage: _pickImage,
                            buttonText: "Upload Discounted ID Image",
                          ),
                        ],
                      );
                    },
                  ),
                  EditTextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: textController,
                    labelText: "Announcement Title",
                    hintText: 'Enter the Announcement Title',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Announcement Title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  DateTimePicker(
                    controller: dateStartController,
                    labelText: 'Starting Date and Time',
                    initialDateTime:
                        DateTime.parse(announcementToEdit['start']),
                  ),
                  const SizedBox(height: 15),
                  DateTimePicker(
                    controller: dateEndController,
                    labelText: 'Ending Date and Time',
                    initialDateTime: DateTime.parse(announcementToEdit['end']),
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
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF050404).withOpacity(0.8),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (dateStartController.text.isEmpty) {
                    showCustomOverlay(
                        context, 'Please Select the Starting Date and Time');
                  } else if (dateEndController.text.isEmpty) {
                    showCustomOverlay(
                        context, 'Please Select the Ending Date and Time');
                  } else {
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
                      setState(() {
                        _image = null;
                      });

                      fetchData();
                      Navigator.pop(context);
                    } else {
                      print(
                          'Failed to update the announcement. Status code: ${response.statusCode}');
                    }
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF050404).withOpacity(0.9),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void archiveData(String id) async {
    Map<String, dynamic> announcementToEdit =
        announcementDataList.firstWhere((data) => data['_id'] == id);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Archive Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: double.infinity,
                    height: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        announcementToEdit['image'] ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  const Divider(),
                  BodyMediumOver(
                    text: 'Title: ${announcementToEdit['text']}',
                  ),
                  BodyMediumText(
                    text:
                        'Start: ${DateFormat('MMMM d, y - h:mm a').format(DateTime.parse(announcementToEdit['start'] ?? ''))}',
                  ),
                  BodyMediumOver(
                    text:
                        'End: ${DateFormat('MMMM d, y - h:mm a').format(DateTime.parse(announcementToEdit['end'] ?? ''))}',
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    'Are you sure you want to Archive this data?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFd41111).withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
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
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF050404).withOpacity(0.8),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final url = Uri.parse(
                    'https://lpg-api-06n8.onrender.com/api/v1/users/$id');
                final response = await http.delete(url);

                if (response.statusCode == 200) {
                  setState(() {
                    announcementDataList
                        .removeWhere((data) => data['_id'] == id);
                  });

                  fetchData();
                  Navigator.pop(context);
                } else {
                  print(
                      'Failed to Archive the data. Status code: ${response.statusCode}');
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFd41111).withOpacity(0.9),
              ),
              child: const Text(
                'Archive',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Announcement List',
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
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
                        ElevatedButton(
                          onPressed: () {
                            openAddAnnouncementDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF050404).withOpacity(0.9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Add Announcement',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (announcementDataList.isEmpty && !loadingData)
                      const Center(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 40),
                              Text(
                                'No announcements to display.',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                              reverse: true,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: announcementDataList.length,
                              itemBuilder: (BuildContext context, int index) {
                                final announcementData =
                                    announcementDataList[index];
                                final id = announcementData['_id'];

                                return Card(
                                  color: Colors.white,
                                  elevation: 2,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: double.infinity,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  announcementData['image'] ??
                                                      ''),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: TitleMedium(
                                            text:
                                                '${announcementData['text']}'),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Divider(),
                                            BodyMediumText(
                                              text:
                                                  'Start: ${DateFormat('MMM d, y - h:mm a').format(DateTime.parse(announcementData['start'] ?? ''))}',
                                            ),
                                            Text(
                                              '(${DateFormat('yyyy-dd-MM - hh:mm').format(DateTime.parse(announcementData['start'] ?? ''))})',
                                            ),
                                            const SizedBox(height: 10),
                                            BodyMediumText(
                                              text:
                                                  'End: ${DateFormat('MMM d, y - h:mm a').format(DateTime.parse(announcementData['end'] ?? ''))}',
                                            ),
                                            Text(
                                              '(${DateFormat('yyyy-dd-MM - hh:mm').format(DateTime.parse(announcementData['end'] ?? ''))})',
                                            ),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 35,
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: const Color(0xFF050404)
                                                      .withOpacity(0.9),
                                                ),
                                                onPressed: () => updateData(id),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 25,
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.archive,
                                                  color: const Color(0xFF050404)
                                                      .withOpacity(0.9),
                                                ),
                                                onPressed: () =>
                                                    archiveData(id),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (currentPage > 1)
                                  ElevatedButton(
                                    onPressed: () {
                                      fetchData(page: currentPage - 1);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF050404)
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
                            const SizedBox(height: 10),
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
