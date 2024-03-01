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
    fetchData();
  }

  int currentPage = 1;
  int limit = 100;

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
                                backgroundColor: Colors.grey,
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
          title: const Text('Archive Data'),
          content: const Text('Are you sure you want to Archive this data?'),
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
                    'https://lpg-api-06n8.onrender.com/api/v1/users/$id');
                final response = await http.delete(url);

                if (response.statusCode == 200) {
                  setState(() {
                    riderDataList.removeWhere((data) => data['_id'] == id);
                  });

                  Navigator.pop(context);
                } else {
                  print(
                      'Failed to Archive the data. Status code: ${response.statusCode}');
                }
              },
              child: const Text('Archive'),
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
        title: const Text('Delivery Driver List'),
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
                        openAddRiderDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF232937),
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: riderDataList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final userData = riderDataList[index];
                    final id = userData['_id'];

                    return Column(
                      children: [
                        Card(
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                    userData['image'] ?? '',
                                  ),
                                ),
                                title: TitleMedium(text: userData['name']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(),
                                    BodyMediumText(
                                        text:
                                            'Contact #: ${userData['contactNumber']}'),
                                    BodyMediumText(
                                        text:
                                            'Address: ${userData['address']}'),
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
                        ),
                      ],
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
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
