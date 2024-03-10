import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:admin_app/widgets/custom_image_upload.dart';
import 'package:admin_app/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
  bool loadingData = false;

  List<Map<String, dynamic>> riderDataList = [];
  TextEditingController searchController = TextEditingController();

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
    loadingData = true;
    fetchData();
  }

  int currentPage = 1;
  int limit = 100;

  Future<void> fetchData({int page = 1}) async {
    final filter = Uri.encodeComponent('{"__t": "Rider"}');
    final response = await http.get(Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/users/?filter=$filter&page=$page&limit=$limit'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> riderData = (data['data'] as List)
          .where((userData) =>
              userData is Map<String, dynamic> && userData['__t'] == 'Rider')
          .map((userData) => userData as Map<String, dynamic>)
          .toList();

      setState(() {
        riderDataList.clear();
        riderDataList.addAll(riderData);
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
          'https://lpg-api-06n8.onrender.com/api/v1/users/?search=$query&limit=1000'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> filteredData = (data['data'] as List)
          .where((userData) =>
              userData is Map<String, dynamic> &&
              userData['__t'] == "Rider" &&
              (userData['name']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  userData['contactNumber']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  userData['email']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  userData['address']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase())))
          .map((productData) => productData as Map<String, dynamic>)
          .toList();

      setState(() {
        riderDataList = filteredData;
      });
    } else {}
  }

  Future<void> _profileTakeImage() async {
    final profilepickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (profilepickedFile != null) {
      final profileImageFile = File(profilepickedFile.path);
      _profileImageStreamController.sink.add(profileImageFile);

      setState(() {
        _profileImage = profileImageFile;
      });
    }
  }

  Future<void> _profilePickImage() async {
    final profilepickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (profilepickedFile != null) {
      final profileImageFile = File(profilepickedFile.path);
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

        final parsedResponse = json.decode(responseBody);

        if (parsedResponse.containsKey('data')) {
          final List<dynamic> data = parsedResponse['data'];

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

  Future<void> _qrTakeImage() async {
    final qrPickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (qrPickedFile != null) {
      final qrImageFile = File(qrPickedFile.path);
      _qrImageStreamController.sink.add(qrImageFile);
      setState(() {
        _qrImage = qrImageFile;
      });
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

        final parsedResponse = json.decode(responseBody);

        if (parsedResponse.containsKey('data')) {
          final List<dynamic> data = parsedResponse['data'];

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

  Future<void> _driverTakeImage() async {
    final driverPickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (driverPickedFile != null) {
      final driverImageFile = File(driverPickedFile.path);
      _driverImageStreamController.sink.add(driverImageFile);
      setState(() {
        _driverImage = driverImageFile;
      });
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

        final parsedResponse = json.decode(responseBody);

        if (parsedResponse.containsKey('data')) {
          final List<dynamic> data = parsedResponse['data'];

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

  Future<void> _certTakeImage() async {
    final certPickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (certPickedFile != null) {
      final certImageFile = File(certPickedFile.path);
      _certImageStreamController.sink.add(certImageFile);
      setState(() {
        _certImage = certImageFile;
      });
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

        final parsedResponse = json.decode(responseBody);

        if (parsedResponse.containsKey('data')) {
          final List<dynamic> data = parsedResponse['data'];

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

  void openAddRiderDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController contactNumberController = TextEditingController();
    TextEditingController addressController = TextEditingController();
    TextEditingController gcashController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    bool isProfileImageSelected = false;
    bool isQrImageSelected = false;
    bool isDriverImageSelected = false;
    bool isCertImageSelected = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add New Delivery Driver',
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
                    stream: _profileImageStreamController.stream,
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: snapshot.data != null
                                    ? FileImage(snapshot.data!)
                                    : null,
                                backgroundColor:
                                    const Color(0xFF050404).withOpacity(0.7),
                                child: snapshot.data == null
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 50,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                          ImageUploaderValidator(
                            takeImage: _profileTakeImage,
                            pickImage: _profilePickImage,
                            buttonText: "Upload Profile Image",
                            onImageSelected: (isSelected) {
                              setState(() {
                                isProfileImageSelected = isSelected;
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  EditTextField(
                    controller: nameController,
                    labelText: "Full Name",
                    hintText: 'Enter the Full Name',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the Full Name";
                      } else {
                        return null;
                      }
                    },
                  ),
                  EditTextField(
                    controller: addressController,
                    labelText: "Address",
                    hintText: 'Enter the Address',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the Address";
                      } else {
                        return null;
                      }
                    },
                  ),
                  EditTextField(
                    labelText: 'Mobile Number',
                    hintText: 'Enter the Mobile Number',
                    controller: contactNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the Mobile Number";
                      } else if (value.length != 11) {
                        return "Please Enter the Correct Mobile Number";
                      } else if (!value.startsWith('09')) {
                        return "Please Enter the Correct Mobile Number";
                      } else {
                        return null;
                      }
                    },
                  ),
                  EditTextField(
                    labelText: 'GCash Number',
                    hintText: 'Enter the GCash Number',
                    controller: gcashController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the GCash Number";
                      } else if (value.length != 11) {
                        return "Please Enter the Correct GCash Number";
                      } else if (!value.startsWith('09')) {
                        return "Please Enter the Correct GCash Number";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<File?>(
                    stream: _qrImageStreamController.stream,
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF050404)
                                        .withOpacity(0.9),
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
                            takeImage: _qrTakeImage,
                            pickImage: _qrPickImage,
                            buttonText: "Upload GCash QR Image",
                            onImageSelected: (isSelected) {
                              setState(() {
                                isQrImageSelected = isSelected;
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  EditTextField(
                    controller: emailController,
                    labelText: 'Email Address',
                    hintText: 'Enter your Email Address',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Email Address";
                      } else if (!RegExp(
                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                          .hasMatch(value)) {
                        return "Please Enter Correct Email Address";
                      } else {
                        return null;
                      }
                    },
                  ),
                  EditTextField(
                    controller: passwordController,
                    labelText: "Password",
                    hintText: 'Enter the Password',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the Password";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<File?>(
                    stream: _driverImageStreamController.stream,
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF050404)
                                        .withOpacity(0.9),
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
                            takeImage: _driverTakeImage,
                            pickImage: _driverPickImage,
                            buttonText: "Upload Driver License Image",
                            onImageSelected: (isSelected) {
                              setState(() {
                                isDriverImageSelected = isSelected;
                              });
                            },
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
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF050404)
                                        .withOpacity(0.9),
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
                            takeImage: _certTakeImage,
                            pickImage: _certPickImage,
                            buttonText: "Upload Seminar Certificate Image",
                            onImageSelected: (isSelected) {
                              setState(() {
                                isCertImageSelected = isSelected;
                              });
                            },
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
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF050404).withOpacity(0.8),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (!isProfileImageSelected) {
                  showCustomOverlay(context, 'Please Upload a Profile Image');
                } else if (!isQrImageSelected) {
                  showCustomOverlay(context, 'Please Upload a GCash QR');
                } else if (!isDriverImageSelected) {
                  showCustomOverlay(context, 'Please Upload a Driver License');
                } else if (!isCertImageSelected) {
                  showCustomOverlay(
                      context, 'Please Upload a Seminar Certificate');
                } else {
                  if (formKey.currentState!.validate()) {
                    Map<String, dynamic> newRider = {
                      "name": nameController.text,
                      "contactNumber": contactNumberController.text,
                      "address": addressController.text,
                      "gcash": gcashController.text,
                      "__t": "Rider",
                      "email": emailController.text,
                      "password": passwordController.text,
                      "image": "",
                      "gcashQr": "",
                      "license": "",
                      "seminarCert": "",
                    };
                    addRiderToAPI(newRider);
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
    Map<String, dynamic> riderToEdit =
        riderDataList.firstWhere((data) => data['_id'] == id);

    TextEditingController nameController =
        TextEditingController(text: riderToEdit['name']);
    TextEditingController contactNumberController =
        TextEditingController(text: riderToEdit['contactNumber']);
    TextEditingController addressController =
        TextEditingController(text: riderToEdit['address']);
    TextEditingController gcashController =
        TextEditingController(text: riderToEdit['gcash']);
    TextEditingController emailController =
        TextEditingController(text: riderToEdit['email']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Edit Delivery Driver',
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
                  StreamBuilder<File?>(
                    stream: _profileImageStreamController.stream,
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Center(
                                child: snapshot.data != null
                                    ? CircleAvatar(
                                        radius: 50,
                                        backgroundImage:
                                            FileImage(snapshot.data!),
                                      )
                                    : (riderToEdit['image'] != null &&
                                            riderToEdit['image']
                                                .toString()
                                                .isNotEmpty)
                                        ? CircleAvatar(
                                            radius: 50,
                                            backgroundImage: NetworkImage(
                                              riderToEdit['image'].toString(),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 50,
                                          ),
                              ),
                            ],
                          ),
                          ImageUploader(
                            takeImage: _profileTakeImage,
                            pickImage: _profilePickImage,
                            buttonText: "Upload Profile Image",
                          ),
                        ],
                      );
                    },
                  ),
                  EditTextField(
                    controller: nameController,
                    labelText: "Full Name",
                    hintText: 'Enter the Full Name',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the Full Name";
                      } else {
                        return null;
                      }
                    },
                  ),
                  EditTextField(
                    controller: addressController,
                    labelText: "Address",
                    hintText: 'Enter the Address',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the Address";
                      } else {
                        return null;
                      }
                    },
                  ),
                  EditTextField(
                    labelText: 'Mobile Number',
                    hintText: 'Enter the Mobile Number',
                    controller: contactNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the Mobile Number";
                      } else if (value.length != 11) {
                        return "Please Enter the Correct Mobile Number";
                      } else if (!value.startsWith('09')) {
                        return "Please Enter the Correct Mobile Number";
                      } else {
                        return null;
                      }
                    },
                  ),
                  EditTextField(
                    labelText: 'GCash Number',
                    hintText: 'Enter the GCash Number',
                    controller: gcashController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the GCash Number";
                      } else if (value.length != 11) {
                        return "Please Enter the Correct GCash Number";
                      } else if (!value.startsWith('09')) {
                        return "Please Enter the Correct GCash Number";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<File?>(
                    stream: _qrImageStreamController.stream,
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF050404)
                                        .withOpacity(0.9),
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
                                              (riderToEdit['gcashQr'] ?? '')
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
                                                  riderToEdit['gcashQr']!,
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
                            takeImage: _qrTakeImage,
                            pickImage: _qrPickImage,
                            buttonText: "Upload GCash QR Image",
                          ),
                        ],
                      );
                    },
                  ),
                  EditTextField(
                    controller: emailController,
                    labelText: 'Email Address',
                    hintText: 'Enter your Email Address',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Email Address";
                      } else if (!RegExp(
                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                          .hasMatch(value)) {
                        return "Please Enter Correct Email Address";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<File?>(
                    stream: _driverImageStreamController.stream,
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF050404)
                                        .withOpacity(0.9),
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
                                              (riderToEdit['license'] ?? '')
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
                                                  riderToEdit['license']!,
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
                            takeImage: _driverTakeImage,
                            pickImage: _driverPickImage,
                            buttonText: "Upload Driver License Image",
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
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF050404)
                                        .withOpacity(0.9),
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
                                              (riderToEdit['seminarCert'] ?? '')
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
                                                  riderToEdit['seminarCert']!,
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
                            takeImage: _certTakeImage,
                            pickImage: _certPickImage,
                            buttonText: "Upload Seminar Certificate Image",
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
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF050404).withOpacity(0.8),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  riderToEdit['name'] = nameController.text;
                  riderToEdit['contactNumber'] = contactNumberController.text;
                  riderToEdit['address'] = addressController.text;
                  riderToEdit['gcash'] = gcashController.text;
                  riderToEdit['email'] = emailController.text;
                  riderToEdit['__t'] = "Rider";

                  if (_profileImage != null) {
                    var editProfileUploadResponse =
                        await uploadProfileImageToServer(_profileImage!);
                    if (editProfileUploadResponse != null) {
                      riderToEdit["image"] = editProfileUploadResponse["url"];
                    }
                  }

                  if (_qrImage != null) {
                    var editQrUploadResponse =
                        await uploadProfileImageToServer(_qrImage!);
                    if (editQrUploadResponse != null) {
                      riderToEdit["gcashQr"] = editQrUploadResponse["url"];
                    }
                  }
                  if (_driverImage != null) {
                    var editDriverUploadResponse =
                        await uploadProfileImageToServer(_driverImage!);
                    if (editDriverUploadResponse != null) {
                      riderToEdit["license"] = editDriverUploadResponse["url"];
                    }
                  }
                  if (_certImage != null) {
                    var editCertUploadResponse =
                        await uploadProfileImageToServer(_certImage!);
                    if (editCertUploadResponse != null) {
                      riderToEdit["seminarCert"] =
                          editCertUploadResponse["url"];
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
                    setState(() {
                      _profileImage = null;
                      _qrImage = null;
                      _driverImage = null;
                      _certImage = null;
                    });

                    fetchData();
                    Navigator.pop(context);
                  } else {
                    print(
                        'Failed to update the rider. Status code: ${response.statusCode}');
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

  void changePassData(String id) async {
    Map<String, dynamic> riderToEdit =
        riderDataList.firstWhere((data) => data['_id'] == id);

    TextEditingController passwordController = TextEditingController(text: "");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Change Password',
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
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        riderToEdit['image'].toString(),
                      ),
                    ),
                  ),
                  const Divider(),
                  BodyMediumOver(
                    text: 'Name: ${riderToEdit['name']}',
                  ),
                  BodyMediumOver(
                    text: 'Address: ${riderToEdit['address']}',
                  ),
                  BodyMediumText(
                    text: 'Mobile #: ${riderToEdit['contactNumber']}',
                  ),
                  BodyMediumText(
                    text: 'GCash #: ${riderToEdit['gcash']}',
                  ),
                  BodyMediumOver(
                    text: 'Email Address: ${riderToEdit['email']}',
                  ),
                  EditTextField(
                    controller: passwordController,
                    labelText: "New Password",
                    hintText: 'Enter the New Password',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the New Password";
                      } else {
                        return null;
                      }
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
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF050404).withOpacity(0.8),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  riderToEdit['password'] = passwordController.text;

                  final url = Uri.parse(
                      'https://lpg-api-06n8.onrender.com/api/v1/users/$id/password');
                  final headers = {'Content-Type': 'application/json'};

                  final response = await http.patch(
                    url,
                    headers: headers,
                    body: jsonEncode(riderToEdit),
                  );

                  if (response.statusCode == 200) {
                    fetchData();
                    Navigator.pop(context);
                  } else {
                    print(
                        'Failed to update the delivery driver. Status code: ${response.statusCode}');
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
    Map<String, dynamic> riderToEdit =
        riderDataList.firstWhere((data) => data['_id'] == id);
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
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        riderToEdit['image'].toString(),
                      ),
                    ),
                  ),
                  const Divider(),
                  BodyMediumOver(
                    text: 'Name: ${riderToEdit['name']}',
                  ),
                  BodyMediumOver(
                    text: 'Address: ${riderToEdit['address']}',
                  ),
                  BodyMediumText(
                    text: 'Mobile #: ${riderToEdit['contactNumber']}',
                  ),
                  BodyMediumText(
                    text: 'GCash #: ${riderToEdit['gcash']}',
                  ),
                  BodyMediumOver(
                    text: 'Email Address: ${riderToEdit['email']}',
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
                    riderDataList.removeWhere((data) => data['_id'] == id);
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
          'Delivery Driver List',
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
                            openAddRiderDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF050404).withOpacity(0.9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Add Delivery Driver',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (riderDataList.isEmpty && !loadingData)
                      const Center(
                        child: Column(
                          children: [
                            SizedBox(height: 40),
                            Text(
                              'No delivery drivers to display.',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 30),
                          ],
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
                              itemCount: riderDataList.length,
                              itemBuilder: (BuildContext context, int index) {
                                final userData = riderDataList[index];
                                final id = userData['_id'];

                                return SizedBox(
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 2,
                                    child: Column(
                                      children: [
                                        // Padding(
                                        //   padding: const EdgeInsets.all(8.0),
                                        //   child: Container(
                                        //     width: double.infinity,
                                        //     height: 100,
                                        //     decoration: BoxDecoration(
                                        //       borderRadius:
                                        //           BorderRadius.circular(10),
                                        //       border: Border.all(
                                        //         color: Colors.black,
                                        //         width: 1,
                                        //       ),
                                        //       image: DecorationImage(
                                        //         image: NetworkImage(
                                        //             userData['image'] ?? ''),
                                        //         fit: BoxFit.cover,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        ListTile(
                                          title: Row(
                                            children: [
                                              Flexible(
                                                child: TitleMedium(
                                                  text: '${userData['name']}',
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.content_copy,
                                                  color: const Color(0xFF050404)
                                                      .withOpacity(0.9),
                                                ),
                                                onPressed: () {
                                                  Clipboard.setData(
                                                          ClipboardData(
                                                              text: id))
                                                      .then((_) {
                                                    // ScaffoldMessenger.of(
                                                    //         context)
                                                    //     .showSnackBar(
                                                    //   const SnackBar(
                                                    //     content: Text(
                                                    //         'Rider ID copied to clipboard'),
                                                    //   ),
                                                    // );
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Divider(),
                                              BodyMediumText(
                                                text:
                                                    'Mobile no.: ${userData['contactNumber']}',
                                              ),
                                              BodyMediumText(
                                                text:
                                                    'GCash no.: ${userData['contactNumber']}',
                                              ),
                                              BodyMediumText(
                                                text:
                                                    'Email: ${userData['email']}',
                                              ),
                                              BodyMediumText(
                                                text:
                                                    'Address: ${userData['address']}',
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
                                                    color:
                                                        const Color(0xFF050404)
                                                            .withOpacity(0.9),
                                                  ),
                                                  onPressed: () =>
                                                      updateData(id),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 35,
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.password,
                                                    color:
                                                        const Color(0xFF050404)
                                                            .withOpacity(0.9),
                                                  ),
                                                  onPressed: () =>
                                                      changePassData(id),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 25,
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.archive,
                                                    color:
                                                        const Color(0xFF050404)
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
