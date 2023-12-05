import 'dart:async';
import 'dart:io';
import 'dart:convert';
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
  TextEditingController searchController =
      TextEditingController(); // Controller for the search field

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
  int limit = 5;

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

  Future<void> _editProfilePickImage() async {
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

  Future<void> _editDiscountedPickImage() async {
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

        // Parse the response JSON
        final parsedResponse = json.decode(responseBody);

        // Check if 'data' is present in the response
        if (parsedResponse.containsKey('data')) {
          final List<dynamic> data = parsedResponse['data'];

          // Check if 'path' is present in the first item of the 'data' array
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
              userData is Map<String, dynamic> &&
              userData['__t'] == 'Customer') // Filter for 'Customer'
          .map((userData) => userData as Map<String, dynamic>)
          .toList();

      setState(() {
        // Clear the existing data before adding new data
        customerDataList.clear();
        customerDataList.addAll(customerData);
        currentPage = page; // Update the current page number
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
      print("Upload Response: $profileUploadResponse");

      if (profileUploadResponse != null) {
        print("Image URL: ${profileUploadResponse["url"]}");
        newCustomer["image"] = profileUploadResponse["url"];
      } else {
        print("Profile Image upload failed");
        return;
      }
    }

    if (_discountedImage != null) {
      var discountedUploadResponse =
          await uploadDiscountedImageToServer(_discountedImage!);
      print("Upload Response: $discountedUploadResponse");

      if (discountedUploadResponse != null) {
        print("Image URL: ${discountedUploadResponse["url"]}");
        newCustomer["discountIdImage"] = discountedUploadResponse["url"];
      } else {
        print("Discounted Image upload failed");
        return;
      }
    }

    // var profileUploadResponse =
    //     await uploadProfileImageToServer(_profileImage!);
    // print("Upload Response: $profileUploadResponse");

    // if (profileUploadResponse != null) {
    //   print("Image URL: ${profileUploadResponse["url"]}");
    //   newCustomer["image"] = profileUploadResponse["url"];
    // } else {
    //   print("Profile Image upload failed");
    //   return;
    // }

    // var discountedUploadResponse =
    //     await uploadDiscountedImageToServer(_discountedImage!);
    // print("Upload Response: $discountedUploadResponse");

    // if (discountedUploadResponse != null) {
    //   print("Image URL: ${discountedUploadResponse["url"]}");
    //   newCustomer["discountIdImage"] = discountedUploadResponse["url"];
    // } else {
    //   print("Discounted Image upload failed");
    //   return;
    // }

    // newCustomer["image"] = profileUploadResponse["url"];
    // newCustomer["discountIdImage"] = discountedUploadResponse["url"];

    // print("  newCustomer: $newCustomer");

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

  void updateData(String id) {
    // Find the customer data to edit
    Map<String, dynamic> customerToEdit =
        customerDataList.firstWhere((data) => data['_id'] == id);

    // Create controllers for each field
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
    // TextEditingController typeController =
    //     TextEditingController(text: customerToEdit['__t']);
    // TextEditingController discountIdImageController = TextEditingController(
    //     text: customerToEdit['discountIdImage'].toString());
    // TextEditingController emailController =
    //     TextEditingController(text: customerToEdit['email']);
    // TextEditingController passwordController =
    //     TextEditingController(text: customerToEdit['password']);
    // TextEditingController imageController =
    //     TextEditingController(text: customerToEdit['image'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Customer'),
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
                              ? (customerToEdit['image']?.toString() ?? '')
                                      .isNotEmpty
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                          customerToEdit['image']?.toString() ??
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
                          // } else if (!RegExp(r'^[a-z A-Z]+$').hasMatch(value!)) {
                          //   return "Enter Correct Name";
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
                  StreamBuilder<File?>(
                    stream: _discountedImageStreamController.stream,
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          const SizedBox(height: 10.0),
                          const Divider(),
                          const SizedBox(height: 10.0),
                          snapshot.data == null
                              ? (customerToEdit['discountIdImage']
                                              ?.toString() ??
                                          '')
                                      .isNotEmpty
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                          customerToEdit['discountIdImage']
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
                              await _editDiscountedPickImage();
                            },
                            child: const Text(
                              "Upload Discounted Image",
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
                  // TextFormField(
                  //     controller: emailController,
                  //     decoration: const InputDecoration(labelText: 'Email'),
                  //     validator: (value) {
                  //       if (value!.isEmpty) {
                  //         return "Please Enter Email";
                  //       } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
                  //           .hasMatch(value!)) {
                  //         return "Enter Correct Email";
                  //       } else {
                  //         return null;
                  //       }s
                  //     }),
                  // TextFormField(
                  //   controller: passwordController,
                  //   decoration: const InputDecoration(labelText: 'Password'),
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return "Please Enter Password";
                  //     } else {
                  //       return null;
                  //     }
                  //   },
                  // ),
                ],
              ),
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
                if (formKey.currentState!.validate()) {
                  customerToEdit['name'] = nameController.text;
                  customerToEdit['contactNumber'] =
                      contactNumberController.text;
                  customerToEdit['address'] = addressController.text;
                  customerToEdit['verified'] =
                      (verifiedController.text).toString();
                  customerToEdit['discounted'] =
                      (discountedController.text).toString();
                  customerToEdit['__t'] = "Customer";
                  customerToEdit['discountIdImage'] = "";
                  // customerToEdit['email'] = emailController.text;
                  // customerToEdit['password'] = passwordController.text;
                  customerToEdit['image'] = "";

                  if (_profileImage != null) {
                    var editprofileUploadResponse =
                        await uploadProfileImageToServer(_profileImage!);
                    print("Upload Response: $editprofileUploadResponse");

                    if (editprofileUploadResponse != null) {
                      print("Image URL: ${editprofileUploadResponse["url"]}");
                      customerToEdit["image"] =
                          editprofileUploadResponse["url"];
                    } else {
                      print("Profile Image upload failed");
                      return;
                    }
                  }

                  if (_discountedImage != null) {
                    var editDiscountedUploadResponse =
                        await uploadDiscountedImageToServer(_discountedImage!);
                    print("Upload Response: $editDiscountedUploadResponse");

                    if (editDiscountedUploadResponse != null) {
                      print(
                          "Image URL: ${editDiscountedUploadResponse["url"]}");
                      customerToEdit["discountIdImage"] =
                          editDiscountedUploadResponse["url"];
                    } else {
                      print("Discounted Image upload failed");
                      return;
                    }
                  }

                  final url = Uri.parse(
                      'https://lpg-api-06n8.onrender.com/api/v1/users/$id');
                  final headers = {'Content-Type': 'application/json'};

                  print("Address: ${customerToEdit['address']}");

                  final response = await http.patch(
                    url,
                    headers: headers,
                    body: jsonEncode(customerToEdit),
                  );

                  if (response.statusCode == 200) {
                    fetchData();
                    Navigator.pop(context);
                  } else {
                    print(
                        'Failed to update the customer. Status code: ${response.statusCode}');
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

  void openAddCustomerDialog() {
    // Create controllers for each field
    TextEditingController nameController = TextEditingController();
    TextEditingController contactNumberController = TextEditingController();
    TextEditingController addressController = TextEditingController();
    TextEditingController verifiedController = TextEditingController();
    TextEditingController discountedController = TextEditingController();
    // TextEditingController typeController = TextEditingController();
    // TextEditingController discountIdImageController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    // TextEditingController imageController = TextEditingController();

    // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    bool isProfileImageUploaded = false;
    // bool isDiscountedImageUploaded = false;

    File? profileImage;
    // File? discountedImage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // key: _scaffoldKey,
          title: const Text('Add New Customer'),
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
                          // } else if (!RegExp(r'^[a-z A-Z]+$').hasMatch(value!)) {
                          //   return "Enter Correct Name";
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Select Verified Status";
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
                        return "Please Select Discounted Status";
                      } else {
                        return null;
                      }
                    },
                  ),
                  StreamBuilder<File?>(
                    stream: _discountedImageStreamController.stream,
                    builder: (context, snapshot) {
                      // discountedImage = snapshot.data;
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
                              await _discountedPickImage();
                            },
                            child: const Text(
                              "Upload Discounted Image",
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
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isProfileImageUploaded = profileImage != null;
                });
                if (!isProfileImageUploaded) {
                  showCustomOverlay(context, 'Please Upload a Profile Image');
                } else {
                  if (formKey.currentState!.validate()) {
                    Map<String, dynamic> newCustomer = {
                      "name": nameController.text,
                      "contactNumber": contactNumberController.text,
                      "address": addressController.text,
                      "verified": verifiedController.text,
                      "discounted": discountedController.text,
                      "__t": "Customer",
                      "discountIdImage": "",
                      "email": emailController.text,
                      "password": passwordController.text,
                      "image": "",
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
                    customerDataList.removeWhere((data) => data['_id'] == id);
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
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Customer CRUD',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
        iconTheme: IconThemeData(color: Color(0xFF232937)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            color: Color(0xFF232937),
            onPressed: () {
              openAddCustomerDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
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
                          // Remove input field border
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle the search button click
                        search(searchController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors
                            .black, // Change the button background color to black
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20), // Apply border radius
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
                      color:
                          Color(0xFF232937), // You can change the border color
                      width: 1.0,
                      // You can change the border width
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: DataTable(
                    columns: <DataColumn>[
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Contact Number')),
                      DataColumn(label: Text('Address')),
                      DataColumn(label: Text('Verified')),
                      DataColumn(label: Text('Discounted')),
                      DataColumn(label: Text('Type')),
                      DataColumn(
                        label: Text('Actions'),
                        tooltip: 'Update and Delete',
                      ),
                    ],
                    rows: customerDataList.map((userData) {
                      final id = userData['_id'];

                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(userData['name'] ?? ''),
                              placeholder: false),
                          DataCell(Text(userData['contactNumber'] ?? ''),
                              placeholder: false),
                          DataCell(Text(userData['address'] ?? ''),
                              placeholder: false),
                          DataCell(Text(userData['verified'].toString() ?? ''),
                              placeholder: false),
                          DataCell(
                              Text(userData['discounted'].toString() ?? ''),
                              placeholder: false),
                          DataCell(Text(userData['__t'] ?? ''),
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
                        // Load the previous page of data
                        fetchData(page: currentPage - 1);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors
                            .black, // Change the button background color to black
                      ),
                      child: Text('Previous'),
                    ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Load the next page of data
                      fetchData(page: currentPage + 1);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors
                          .black, // Change the button background color to black
                    ),
                    child: Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
