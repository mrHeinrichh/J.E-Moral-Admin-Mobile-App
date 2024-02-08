import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:admin_app/widgets/custom_image_upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class CustomerPage extends StatefulWidget {
  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  File? _profileImage;
  File? _discountedImage;
  final _profileImageStreamController = StreamController<File?>.broadcast();
  final _discountedImageStreamController = StreamController<File?>.broadcast();

  final formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> customerDataList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    _profileImageStreamController.close();
    _discountedImageStreamController.close();
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

  Future<void> _discountedTakeImage() async {
    final discountedpickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (discountedpickedFile != null) {
      final discountedImageFile = File(discountedpickedFile.path);
      _discountedImageStreamController.sink.add(discountedImageFile);

      setState(() {
        _discountedImage = discountedImageFile;
      });
    }
  }

  Future<void> _discountedPickImage() async {
    final discountedpickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (discountedpickedFile != null) {
      final discountedImageFile = File(discountedpickedFile.path);
      _discountedImageStreamController.sink.add(discountedImageFile);

      setState(() {
        _discountedImage = discountedImageFile;
      });
    }
  }

  Future<Map<String, dynamic>?> uploadDiscountedImageToServer(
      File discountedImageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/upload/image'),
      );

      var fileStream =
          http.ByteStream(Stream.castFrom(discountedImageFile.openRead()));
      var length = await discountedImageFile.length();

      String fileExtension =
          discountedImageFile.path.split('.').last.toLowerCase();
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
        print("Discounted Image uploaded successfully: $responseBody");

        final parsedResponse = json.decode(responseBody);

        if (parsedResponse.containsKey('data')) {
          final List<dynamic> data = parsedResponse['data'];

          if (data.isNotEmpty && data[0].containsKey('path')) {
            final discountedImageUrl = data[0]['path'];
            print("Image URL: $discountedImageUrl");
            return {'url': discountedImageUrl};
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
            "Discounted Image upload failed with status code: ${response.statusCode}");
        final responseBody = await response.stream.bytesToString();
        print("Response body: $responseBody");
        return null;
      }
    } catch (e) {
      print("Discounted Image upload failed with error: $e");
      return null;
    }
  }

  Future<void> fetchData({int page = 1}) async {
    final response = await http.get(Uri.parse(
        'https://lpg-api-06n8.onrender.com/api/v1/users/?page=$page&limit=$limit'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> customerData = (data['data'] as List)
          .where((userData) =>
              userData is Map<String, dynamic> && userData['__t'] == 'Customer')
          .map((userData) => userData as Map<String, dynamic>)
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

  Future<void> addCustomerToAPI(Map<String, dynamic> newCustomer) async {
    final url = Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/users');
    final headers = {'Content-Type': 'application/json'};

    if (_profileImage != null) {
      var profileUploadResponse =
          await uploadProfileImageToServer(_profileImage!);
      print("Upload Response for Profile Image: $profileUploadResponse");

      if (profileUploadResponse != null) {
        print("Profile Image URL: ${profileUploadResponse["url"]}");
        newCustomer["image"] = profileUploadResponse["url"];
      } else {
        print("Profile Image upload failed");
        return;
      }
    }

    if (_discountedImage != null) {
      var discountedUploadResponse =
          await uploadDiscountedImageToServer(_discountedImage!);
      print("Upload Response for Discounted Image: $discountedUploadResponse");

      if (discountedUploadResponse != null) {
        print("Discounted Image URL: ${discountedUploadResponse["url"]}");
        newCustomer["discountIdImage"] = discountedUploadResponse["url"];
      } else {
        print("Discounted Image upload failed");
        return;
      }
    }

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(newCustomer),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      fetchData();
      Navigator.pop(context);
    } else {
      print(
          'Failed to add or update the customer. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      await fetchData();
    } else {
      final response = await http.get(Uri.parse(
          'https://lpg-api-06n8.onrender.com/api/v1/users/?search=$query'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final List<Map<String, dynamic>> customerData = (data['data'] as List)
            .where((userData) =>
                userData is Map<String, dynamic> &&
                userData.containsKey('__t') &&
                userData['__t'] == 'Customer')
            .map((userData) => userData as Map<String, dynamic>)
            .toList();

        setState(() {
          customerDataList = customerData;
        });
      } else {}
    }
  }

  void openAddCustomerDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController contactNumberController = TextEditingController();
    TextEditingController addressController = TextEditingController();
    TextEditingController discountedController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    bool isProfileImageSelected = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add New Customer',
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
                    controller: contactNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Contact Number'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Number";
                        // } else if (!RegExp(
                        //         r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]+$')
                        //     .hasMatch(value!)) {
                        //   return "Enter Correct Phone Number";
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
                  DropdownButtonFormField(
                    value: discountedController.text.isNotEmpty
                        ? discountedController.text
                        : null,
                    decoration:
                        const InputDecoration(labelText: 'Discount Status'),
                    items: const [
                      DropdownMenuItem(value: 'true', child: Text('Approved')),
                      DropdownMenuItem(
                          value: 'false', child: Text('Not Approved')),
                    ],
                    onChanged: (newValue) {
                      discountedController.text = newValue.toString();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Select a Discount Status';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<File?>(
                    stream: _discountedImageStreamController.stream,
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
                          ImageUploader(
                            takeImage: _discountedTakeImage,
                            pickImage: _discountedPickImage,
                            buttonText: "Upload Discounted ID Image",
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
                } else {
                  if (formKey.currentState!.validate()) {
                    Map<String, dynamic> newCustomer = {
                      "name": nameController.text,
                      "contactNumber": contactNumberController.text,
                      "address": addressController.text,
                      "verified": "true",
                      "discounted": discountedController.text,
                      "__t": "Customer",
                      "email": emailController.text,
                      "password": passwordController.text,
                      "image": "",
                      'discountIdImage': "",
                    };
                    addCustomerToAPI(newCustomer);
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
    Map<String, dynamic> customerToEdit =
        customerDataList.firstWhere((data) => data['_id'] == id);

    TextEditingController nameController =
        TextEditingController(text: customerToEdit['name'].toString());
    TextEditingController contactNumberController =
        TextEditingController(text: customerToEdit['contactNumber'].toString());
    TextEditingController addressController =
        TextEditingController(text: customerToEdit['address'].toString());
    TextEditingController verifiedController =
        TextEditingController(text: customerToEdit['verified'].toString());
    TextEditingController discountedController =
        TextEditingController(text: customerToEdit['discounted'].toString());
    TextEditingController emailController =
        TextEditingController(text: customerToEdit['email']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Edit Customer',
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
                                    : (customerToEdit['image'] != null &&
                                            customerToEdit['image']
                                                .toString()
                                                .isNotEmpty)
                                        ? CircleAvatar(
                                            radius: 50,
                                            backgroundImage: NetworkImage(
                                              customerToEdit['image']
                                                  .toString(),
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
                        // } else if (!RegExp(
                        //         r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]+$')
                        //     .hasMatch(value!)) {
                        //   return "Enter Correct Phone Number";
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
                  DropdownButtonFormField(
                    value: verifiedController.text.isNotEmpty
                        ? verifiedController.text
                        : null,
                    decoration:
                        const InputDecoration(labelText: 'Verification Status'),
                    items: const [
                      DropdownMenuItem(value: 'true', child: Text('Verified')),
                      DropdownMenuItem(
                          value: 'false', child: Text('Not Verified')),
                    ],
                    onChanged: (newValue) {
                      verifiedController.text = newValue.toString();
                    },
                  ),
                  DropdownButtonFormField(
                    value: discountedController.text.isNotEmpty
                        ? discountedController.text
                        : null,
                    decoration:
                        const InputDecoration(labelText: 'Discount Status'),
                    items: const [
                      DropdownMenuItem(value: 'true', child: Text('Approved')),
                      DropdownMenuItem(
                          value: 'false', child: Text('Not Approved')),
                    ],
                    onChanged: (newValue) {
                      discountedController.text = newValue.toString();
                    },
                  ),
                  const SizedBox(height: 10.0),
                  StreamBuilder<File?>(
                    stream: _discountedImageStreamController.stream,
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
                                              (customerToEdit[
                                                          'discountIdImage'] ??
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
                                                  customerToEdit[
                                                      'discountIdImage']!,
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
                            takeImage: _discountedTakeImage,
                            pickImage: _discountedPickImage,
                            buttonText: "Upload Discounted ID Image",
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
                  customerToEdit['name'] = nameController.text;
                  customerToEdit['contactNumber'] =
                      contactNumberController.text;
                  customerToEdit['address'] = addressController.text;
                  customerToEdit['verified'] =
                      (verifiedController.text).toString();
                  customerToEdit['discounted'] =
                      (discountedController.text).toString();
                  customerToEdit['type'] = "Customer";
                  customerToEdit['email'] = emailController.text;

                  if (_profileImage != null) {
                    var editprofileUploadResponse =
                        await uploadProfileImageToServer(_profileImage!);
                    if (editprofileUploadResponse != null) {
                      customerToEdit["image"] =
                          editprofileUploadResponse["url"];
                    }
                  }

                  if (_discountedImage != null) {
                    var editDiscountedUploadResponse =
                        await uploadDiscountedImageToServer(_discountedImage!);
                    if (editDiscountedUploadResponse != null) {
                      customerToEdit["discountIdImage"] =
                          editDiscountedUploadResponse["url"];
                    }
                  }

                  final url = Uri.parse(
                      'https://lpg-api-06n8.onrender.com/api/v1/users/$id');
                  final headers = {'Content-Type': 'application/json'};

                  final response = await http.patch(
                    url,
                    headers: headers,
                    body: jsonEncode(customerToEdit),
                  );

                  if (response.statusCode == 200) {
                    setState(() {
                      _profileImage = null;
                      _discountedImage = null;
                    });

                    fetchData();
                    Navigator.pop(context);
                  } else {
                    print(
                        'Failed to update the customer. Status code: ${response.statusCode}');
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
                    customerDataList.removeWhere((data) => data['_id'] == id);
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
        title: const Text('Customer List'),
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
                        openAddCustomerDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF232937),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Add Customer',
                        style: TextStyle(color: Colors.white),
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
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            userData['image'] ?? '',
                          ),
                        ),
                        title: Text(
                          userData['name'] ?? '',
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
                              'Contact #: ${userData['contactNumber'] ?? ''}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              'Address: ${userData['address'] ?? ''}',
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
