import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class DriversPage extends StatefulWidget {
  @override
  _DriversPageState createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  File? _profileImage;
  File? _qrImage;
  File? _driverImage;
  File? _certImage;

  final _profileImageStreamController = StreamController<File?>.broadcast();
  final _qrImageStreamController = StreamController<File?>.broadcast();
  final _driverImageStreamController = StreamController<File?>.broadcast();
  final _certImageStreamController = StreamController<File?>.broadcast();

  final formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> riderDataList = [];

  TextEditingController searchController =
      TextEditingController(); // Controller for the search field

  @override
  void dispose() {
    _profileImageStreamController.close();
    _qrImageStreamController.close();
    _driverImageStreamController.close();
    _certImageStreamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  int currentPage = 1;
  int limit = 15;

  Future<void> _profilePickImage() async {
    final profilePickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (profilePickedFile != null) {
      final profileImageFile = File(profilePickedFile.path);
      _profileImageStreamController.sink.add(profileImageFile);
      setState(() {
        _profileImage = profileImageFile;
      });
    }
  }

  Future<void> _editProfilePickImage() async {
    final profilePickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (profilePickedFile != null) {
      final profileImageFile = File(profilePickedFile.path);
      _profileImageStreamController.sink.add(profileImageFile);
      setState(() {
        _profileImage = profileImageFile;
      });
    }
  }

  Future<Map<String, dynamic>?> uploadProfileImageToServer(
      File profileImageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/upload/image'),
      );

      var fileStream =
          http.ByteStream(Stream.castFrom(profileImageFile.openRead()));
      var length = await profileImageFile.length();

      String fileExtension =
          profileImageFile.path.split('.').last.toLowerCase();
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
        print("Profile Image uploaded successfully: $responseBody");

        // Parse the response JSON
        final parsedResponse = json.decode(responseBody);

        // Check if 'data' is present in the response
        if (parsedResponse.containsKey('data')) {
          final List<dynamic> data = parsedResponse['data'];

          // Check if 'path' is present in the first item of the 'data' array
          if (data.isNotEmpty && data[0].containsKey('path')) {
            final profileImageUrl = data[0]['path'];
            print("Image URL: $profileImageUrl");
            return {'url': profileImageUrl};
          } else {
            print("Invalid response format: $parsedResponse");
            return null;
          }
        } else {
          print("Invalid response format: $parsedResponse");
          return null;
        }
      } else {
        print(
            "Profile Image upload failed with status code: ${response.statusCode}");
        final responseBody = await response.stream.bytesToString();
        print("Response body: $responseBody");
        return null;
      }
    } catch (e) {
      print("Profile Image upload failed with error: $e");
      return null;
    }
  }

  Future<void> _qrPickImage() async {
    final qrPickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (qrPickedFile != null) {
      final qrImageFile = File(qrPickedFile.path);
      _qrImageStreamController.sink.add(qrImageFile);
      setState(() {
        _qrImage = qrImageFile;
      });
    }
  }

  Future<void> _editQrPickImage() async {
    final qrPickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (qrPickedFile != null) {
      final qrImageFile = File(qrPickedFile.path);
      _qrImageStreamController.sink.add(qrImageFile);
      setState(() {
        _qrImage = qrImageFile;
      });
    }
  }

  Future<Map<String, dynamic>?> uploadQrImageToServer(File qrImageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/upload/image'),
      );

      var fileStream = http.ByteStream(Stream.castFrom(qrImageFile.openRead()));
      var length = await qrImageFile.length();

      String fileExtension = qrImageFile.path.split('.').last.toLowerCase();
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
        print("QR Image uploaded successfully: $responseBody");

        // Parse the response JSON
        final parsedResponse = json.decode(responseBody);

        // Check if 'data' is present in the response
        if (parsedResponse.containsKey('data')) {
          final List<dynamic> data = parsedResponse['data'];

          // Check if 'path' is present in the first item of the 'data' array
          if (data.isNotEmpty && data[0].containsKey('path')) {
            final qrImageUrl = data[0]['path'];
            print("Image URL: $qrImageUrl");
            return {'url': qrImageUrl};
          } else {
            print("Invalid response format: $parsedResponse");
            return null;
          }
        } else {
          print("Invalid response format: $parsedResponse");
          return null;
        }
      } else {
        print(
            "QR Image upload failed with status code: ${response.statusCode}");
        final responseBody = await response.stream.bytesToString();
        print("Response body: $responseBody");
        return null;
      }
    } catch (e) {
      print("QR Image upload failed with error: $e");
      return null;
    }
  }

  Future<void> _driverPickImage() async {
    final driverPickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (driverPickedFile != null) {
      final driverImageFile = File(driverPickedFile.path);
      _driverImageStreamController.sink.add(driverImageFile);
      setState(() {
        _driverImage = driverImageFile;
      });
    }
  }

  Future<void> _editDriverPickImage() async {
    final driverPickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (driverPickedFile != null) {
      final driverImageFile = File(driverPickedFile.path);
      _driverImageStreamController.sink.add(driverImageFile);
      setState(() {
        _driverImage = driverImageFile;
      });
    }
  }

  Future<Map<String, dynamic>?> uploadDriverImageToServer(
      File driverImageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/upload/image'),
      );

      var fileStream =
          http.ByteStream(Stream.castFrom(driverImageFile.openRead()));
      var length = await driverImageFile.length();

      String fileExtension = driverImageFile.path.split('.').last.toLowerCase();
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
        print("Driver Image uploaded successfully: $responseBody");

        // Parse the response JSON
        final parsedResponse = json.decode(responseBody);

        // Check if 'data' is present in the response
        if (parsedResponse.containsKey('data')) {
          final List<dynamic> data = parsedResponse['data'];

          // Check if 'path' is present in the first item of the 'data' array
          if (data.isNotEmpty && data[0].containsKey('path')) {
            final driverImageUrl = data[0]['path'];
            print("Image URL: $driverImageUrl");
            return {'url': driverImageUrl};
          } else {
            print("Invalid response format: $parsedResponse");
            return null;
          }
        } else {
          print("Invalid response format: $parsedResponse");
          return null;
        }
      } else {
        print(
            "Driver License Image upload failed with status code: ${response.statusCode}");
        final responseBody = await response.stream.bytesToString();
        print("Response body: $responseBody");
        return null;
      }
    } catch (e) {
      print("Driver License Image upload failed with error: $e");
      return null;
    }
  }

  Future<void> _certPickImage() async {
    final certPickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (certPickedFile != null) {
      final certImageFile = File(certPickedFile.path);
      _certImageStreamController.sink.add(certImageFile);
      setState(() {
        _certImage = certImageFile;
      });
    }
  }

  Future<void> _editCertPickImage() async {
    final certPickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (certPickedFile != null) {
      final certImageFile = File(certPickedFile.path);
      _certImageStreamController.sink.add(certImageFile);
      setState(() {
        _certImage = certImageFile;
      });
    }
  }

  Future<Map<String, dynamic>?> uploadCertImageToServer(
      File certImageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/upload/image'),
      );

      var fileStream =
          http.ByteStream(Stream.castFrom(certImageFile.openRead()));
      var length = await certImageFile.length();

      String fileExtension = certImageFile.path.split('.').last.toLowerCase();
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
        print("Seminar Certificate Image uploaded successfully: $responseBody");

        // Parse the response JSON
        final parsedResponse = json.decode(responseBody);

        // Check if 'data' is present in the response
        if (parsedResponse.containsKey('data')) {
          final List<dynamic> data = parsedResponse['data'];

          // Check if 'path' is present in the first item of the 'data' array
          if (data.isNotEmpty && data[0].containsKey('path')) {
            final certImageUrl = data[0]['path'];
            print("Image URL: $certImageUrl");
            return {'url': certImageUrl};
          } else {
            print("Invalid response format: $parsedResponse");
            return null;
          }
        } else {
          print("Invalid response format: $parsedResponse");
          return null;
        }
      } else {
        print(
            "Seminar Certificate Image upload failed with status code: ${response.statusCode}");
        final responseBody = await response.stream.bytesToString();
        print("Response body: $responseBody");
        return null;
      }
    } catch (e) {
      print("Seminar Certificate Image upload failed with error: $e");
      return null;
    }
  }

  Future<void> fetchData({int page = 1}) async {
    final filter = Uri.encodeComponent('{"__t": "Rider"}');
    final response = await http.get(Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/users/?filter=$filter&page=$page&limit=$limit'));

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

    if (_profileImage != null) {
      var profileUploadResponse =
          await uploadProfileImageToServer(_profileImage!);
      print("Upload Response: $profileUploadResponse");

      if (profileUploadResponse != null) {
        print("Image URL: ${profileUploadResponse["url"]}");
        newRider["image"] = profileUploadResponse["url"];
      } else {
        print("Profile Image upload failed");
        return;
      }
    }

    if (_qrImage != null) {
      var qrUploadResponse = await uploadQrImageToServer(_qrImage!);
      print("Upload Response: $qrUploadResponse");

      if (qrUploadResponse != null) {
        print("Image URL: ${qrUploadResponse["url"]}");
        newRider["gcashQr"] = qrUploadResponse["url"];
      } else {
        print("Qr Image upload failed");
        return;
      }
    }

    if (_driverImage != null) {
      var driverUploadResponse = await uploadDriverImageToServer(_driverImage!);
      print("Upload Response: $driverUploadResponse");

      if (driverUploadResponse != null) {
        print("Image URL: ${driverUploadResponse["url"]}");
        newRider["license"] = driverUploadResponse["url"];
      } else {
        print("Driver License Image upload failed");
        return;
      }
    }

    if (_certImage != null) {
      var certUploadResponse = await uploadCertImageToServer(_certImage!);
      print("Upload Response: $certUploadResponse");

      if (certUploadResponse != null) {
        print("Image URL: ${certUploadResponse["url"]}");
        newRider["seminarCert"] = certUploadResponse["url"];
      } else {
        print("Seminar Certificate Image upload failed");
        return;
      }
    }

    print("Request Data: $newRider");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(newRider),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      fetchData();
      Navigator.pop(context);
    } else {
      print(
          'Failed to add or update the rider. Status code: ${response.statusCode}');
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
        TextEditingController(text: riderToEdit['gcash']);
    // TextEditingController gcashQrController =
    //     TextEditingController(text: riderToEdit['gcashQr'].toString());
    // TextEditingController typeController =
    //     TextEditingController(text: riderToEdit['__t']);
    // TextEditingController licenseController =
    //     TextEditingController(text: riderToEdit['license']);
    // TextEditingController seminarCertController =
    //     TextEditingController(text: riderToEdit['seminarCert']);
    // TextEditingController emailController =
    //     TextEditingController(text: riderToEdit['email']);
    // TextEditingController passwordController =
    //     TextEditingController(text: riderToEdit['password']);
    // TextEditingController imageController =
    //     TextEditingController(text: riderToEdit['image']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Rider'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  StreamBuilder<File?>(
                    stream: _profileImageStreamController.stream,
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          const SizedBox(height: 10.0),
                          const Divider(),
                          const SizedBox(height: 10.0),
                          snapshot.data == null
                              ? (riderToEdit['image']?.toString() ?? '')
                                      .isNotEmpty
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                          riderToEdit['image']?.toString() ??
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
                              await _editProfilePickImage();
                            },
                            child: const Text(
                              "Upload Profile Image",
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
                  TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please Enter Name";
                        } else {
                          return null;
                        }
                      }),
                  TextFormField(
                    controller: contactNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Contact Number'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Number";
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Address";
                      } else {
                        return null;
                      }
                    },
                  ),
                  TextFormField(
                    controller: gcashController,
                    decoration:
                        const InputDecoration(labelText: 'GCash Number'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Number";
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  StreamBuilder<File?>(
                    stream: _qrImageStreamController.stream,
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          const SizedBox(height: 10.0),
                          const Divider(),
                          const SizedBox(height: 10.0),
                          snapshot.data == null
                              ? (riderToEdit['gcashQr']?.toString() ?? '')
                                      .isNotEmpty
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                          riderToEdit['gcashQr']?.toString() ??
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
                              await _editQrPickImage();
                            },
                            child: const Text(
                              "Upload GCash Qr",
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
                  StreamBuilder<File?>(
                    stream: _qrImageStreamController.stream,
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          const SizedBox(height: 10.0),
                          const Divider(),
                          const SizedBox(height: 10.0),
                          snapshot.data == null
                              ? (riderToEdit['license']?.toString() ?? '')
                                      .isNotEmpty
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                          riderToEdit['license']?.toString() ??
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
                              await _editDriverPickImage();
                            },
                            child: const Text(
                              "Upload Driver License",
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
                  StreamBuilder<File?>(
                    stream: _certImageStreamController.stream,
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          const SizedBox(height: 10.0),
                          const Divider(),
                          const SizedBox(height: 10.0),
                          snapshot.data == null
                              ? (riderToEdit['seminarCert']?.toString() ?? '')
                                      .isNotEmpty
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                          riderToEdit['seminarCert']
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
                              await _editCertPickImage();
                            },
                            child: const Text(
                              "Upload Seminar Certificate",
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
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  riderToEdit['name'] = nameController.text;
                  riderToEdit['contactNumber'] = contactNumberController.text;
                  riderToEdit['address'] = addressController.text;
                  riderToEdit['gcash'] = gcashController.text;
                  riderToEdit['gcashQr'] = "";
                  riderToEdit['__t'] = "Rider";
                  riderToEdit['license'] = "";
                  riderToEdit['seminarCert'] = "";
                  // riderToEdit['email'] = emailController.text;
                  // riderToEdit['password'] = passwordController.text;
                  riderToEdit['image'] = "";

                  if (_profileImage != null) {
                    var editProfileUploadResponse =
                        await uploadProfileImageToServer(_profileImage!);
                    print("Upload Response: $editProfileUploadResponse");

                    if (editProfileUploadResponse != null) {
                      print("Image URL: ${editProfileUploadResponse["url"]}");
                      riderToEdit["image"] = editProfileUploadResponse["url"];
                    } else {
                      print("Profile Image upload failed");
                      return;
                    }
                  }

                  if (_qrImage != null) {
                    var editQrUploadResponse =
                        await uploadProfileImageToServer(_qrImage!);
                    print("Upload Response: $editQrUploadResponse");

                    if (editQrUploadResponse != null) {
                      print("Image URL: ${editQrUploadResponse["url"]}");
                      riderToEdit["gcashQr"] = editQrUploadResponse["url"];
                    } else {
                      print("QR Image upload failed");
                      return;
                    }
                  }
                  if (_driverImage != null) {
                    var editDriverUploadResponse =
                        await uploadProfileImageToServer(_driverImage!);
                    print("Upload Response: $editDriverUploadResponse");

                    if (editDriverUploadResponse != null) {
                      print("Image URL: ${editDriverUploadResponse["url"]}");
                      riderToEdit["license"] = editDriverUploadResponse["url"];
                    } else {
                      print("Driver License Image upload failed");
                      return;
                    }
                  }
                  if (_certImage != null) {
                    var editCertUploadResponse =
                        await uploadProfileImageToServer(_certImage!);
                    print("Upload Response: $editCertUploadResponse");

                    if (editCertUploadResponse != null) {
                      print("Image URL: ${editCertUploadResponse["url"]}");
                      riderToEdit["seminarCert"] =
                          editCertUploadResponse["url"];
                    } else {
                      print("Seminar Certificate Image upload failed");
                      return;
                    }
                  }

                  final url = Uri.parse(
                      'https://lpg-api-06n8.onrender.com/api/v1/users/$id');
                  final headers = {'Content-Type': 'application/json'};

                  final response = await http.patch(
                    url,
                    headers: headers,
                    body: jsonEncode(riderToEdit),
                  );

                  if (response.statusCode == 200) {
                    fetchData();
                    // print('Updated Address: ${riderToEdit["address"]}');

                    Navigator.pop(context);
                  } else {
                    print(
                        'Failed to update the rider. Status code: ${response.statusCode}');
                  }
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
    // TextEditingController gcashQrController = TextEditingController();
    // TextEditingController typeController = TextEditingController();
    // TextEditingController licenseController = TextEditingController();
    // TextEditingController seminarCertController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    // TextEditingController imageController = TextEditingController();

    bool isProfileImageUploaded = false;
    bool isQrImageUploaded = false;
    bool isDriverImageUploaded = false;
    bool isCertImageUploaded = false;

    File? profileImage;
    File? qrImage;
    File? driverImage;
    File? certImage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Rider'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  StreamBuilder<File?>(
                    stream: _profileImageStreamController.stream,
                    builder: (context, snapshot) {
                      profileImage = snapshot.data;
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
                              await _profilePickImage();
                            },
                            child: const Text(
                              "Upload Profile Image",
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
                  TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please Enter Name";
                        } else {
                          return null;
                        }
                      }),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Address";
                      } else {
                        return null;
                      }
                    },
                  ),
                  TextFormField(
                    controller: contactNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Contact Number'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Number";
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  TextFormField(
                    controller: gcashController,
                    decoration:
                        const InputDecoration(labelText: 'GCash Number'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Number";
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  StreamBuilder<File?>(
                    stream: _qrImageStreamController.stream,
                    builder: (context, snapshot) {
                      qrImage = snapshot.data;
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
                              await _qrPickImage();
                            },
                            child: const Text(
                              "Upload GCash QR",
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
                  TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please Enter Email";
                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
                            .hasMatch(value!)) {
                          return "Enter Correct Email";
                        } else {
                          return null;
                        }
                      }),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Password";
                      } else {
                        return null;
                      }
                    },
                  ),
                  StreamBuilder<File?>(
                    stream: _driverImageStreamController.stream,
                    builder: (context, snapshot) {
                      driverImage = snapshot.data;
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
                              await _driverPickImage();
                            },
                            child: const Text(
                              "Upload Driver License",
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
                  StreamBuilder<File?>(
                    stream: _certImageStreamController.stream,
                    builder: (context, snapshot) {
                      certImage = snapshot.data;
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
                              await _certPickImage();
                            },
                            child: const Text(
                              "Upload Seminar Certificate",
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
                setState(() {
                  isProfileImageUploaded = profileImage != null;
                  isQrImageUploaded = qrImage != null;
                  isDriverImageUploaded = driverImage != null;
                  isCertImageUploaded = certImage != null;
                });
                if (!isProfileImageUploaded) {
                  showCustomOverlay(context, 'Please Upload a Profile Image');
                } else if (!isQrImageUploaded) {
                  showCustomOverlay(context, 'Please Upload a GCash QR');
                } else if (!isDriverImageUploaded) {
                  showCustomOverlay(context, 'Please Upload a Driver License');
                } else if (!isCertImageUploaded) {
                  showCustomOverlay(
                      context, 'Please Upload a Seminar Certificate');
                } else {
                  Map<String, dynamic> newRider = {
                    "name": nameController.text,
                    "contactNumber": contactNumberController.text,
                    "address": addressController.text,
                    "gcash": gcashController.text,
                    "gcashQr": "",
                    "__t": "Rider",
                    "license": "",
                    "seminarCert": "",
                    "email": emailController.text,
                    "password": passwordController.text,
                    "image": "",
                  };
                  addRiderToAPI(newRider);
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
                  style: const TextStyle(color: Colors.white),
                ),
              ),
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
        iconTheme: const IconThemeData(color: Color(0xFF232937)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            color: const Color(0xFF232937),
            onPressed: () {
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
              child: SingleChildScrollView(
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
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Contact Number')),
                      DataColumn(label: Text('Address')),
                      DataColumn(label: Text('Gcash')),
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
                          DataCell(
                              Text(userData['contactNumber'].toString() ?? ''),
                              placeholder: false),
                          DataCell(Text(userData['address'].toString() ?? ''),
                              placeholder: false),
                          DataCell(Text(userData['gcash'].toString() ?? ''),
                              placeholder: false),
                          DataCell(Text(userData['__t'] ?? ''),
                              placeholder: false),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => updateData(id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
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
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     if (currentPage > 1)
            //       ElevatedButton(
            //         onPressed: () {
            //           fetchData(page: currentPage - 1);
            //         },
            //         style: ElevatedButton.styleFrom(
            //           primary: Colors.black,
            //         ),
            //         child: Text('Previous'),
            //       ),
            //     const SizedBox(width: 20),
            //     ElevatedButton(
            //       onPressed: () {
            //         fetchData(page: currentPage + 1);
            //       },
            //       style: ElevatedButton.styleFrom(
            //         primary: Colors.black,
            //       ),
            //       child: const Text('Next'),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
