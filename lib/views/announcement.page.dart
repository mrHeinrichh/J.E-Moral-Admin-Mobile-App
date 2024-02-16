import 'package:admin_app/widgets/custom_image_upload.dart';
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

class AnnouncementPage extends StatefulWidget {
  @override
  _AnnouncementPageState createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  File? _image;
  final _imageStreamController = StreamController<File?>.broadcast();

  final formKey = GlobalKey<FormState>();

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
  int limit = 20;

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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (!isImageSelected) {
                  showCustomOverlay(
                      context, 'Please Upload an Announcement Image');
                } else {
                  if (formKey.currentState!.validate()) {
                    Map<String, dynamic> newAnnouncement = {
                      "text": textController.text,
                      "start": dateStartController.text,
                      "end": dateEndController.text,
                      "image": "",
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
              color: Colors.red,
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
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
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
        title: const Text('Announcement List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: RefreshIndicator(
          onRefresh: () => fetchData(),
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
                    ElevatedButton(
                      onPressed: () {
                        openAddAnnouncementDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF232937),
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: announcementDataList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final userData = announcementDataList[index];
                    final id = userData['_id'];

                    return Card(
                      elevation: 4,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: double.infinity,
                              height: 100, // Change the size
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(userData['image'] ?? ''),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              userData['text'] ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                Text(
                                  'Start: ${DateFormat('MMM d, y - h:mm a').format(DateTime.parse(userData['start'] ?? ''))}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  'End: ${DateFormat('MMM d, y - h:mm a').format(DateTime.parse(userData['end'] ?? ''))}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => updateData(id),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                  child: IconButton(
                                    icon: const Icon(Icons.archive),
                                    onPressed: () => archiveData(id),
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
                          primary: const Color(0xFF232937),
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
                        primary: const Color(0xFF232937),
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
      ),
    );
  }
}
