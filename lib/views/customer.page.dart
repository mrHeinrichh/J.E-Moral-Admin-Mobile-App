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

class CustomerPage extends StatefulWidget {
  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  File? _profileImage;
  final _profileImageStreamController = StreamController<File?>.broadcast();

  final formKey = GlobalKey<FormState>();
  bool loadingData = false;

  List<Map<String, dynamic>> customerDataList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    _profileImageStreamController.close();
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
        loadingData = false;
      });
    } else {
      throw Exception('Failed to load data from the API');
    }
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
    final response = await http.get(
      Uri.parse(
          'https://lpg-api-06n8.onrender.com/api/v1/users/?search=$query&limit=1000'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> filteredData = (data['data'] as List)
          .where((userData) =>
              userData is Map<String, dynamic> &&
              userData['__t'] == "Customer" &&
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
        customerDataList = filteredData;
      });
    } else {}
  }

  void openAddCustomerDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController contactNumberController = TextEditingController();
    TextEditingController addressController = TextEditingController();
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
                } else {
                  if (formKey.currentState!.validate()) {
                    Map<String, dynamic> newCustomer = {
                      "name": nameController.text,
                      "contactNumber": contactNumberController.text,
                      "address": addressController.text,
                      "verified": "true",
                      "__t": "Customer",
                      "email": emailController.text,
                      "password": passwordController.text,
                      "image": "",
                    };
                    addCustomerToAPI(newCustomer);
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
    Map<String, dynamic> customerToEdit =
        customerDataList.firstWhere((data) => data['_id'] == id);

    TextEditingController nameController =
        TextEditingController(text: customerToEdit['name'].toString());
    TextEditingController contactNumberController =
        TextEditingController(text: customerToEdit['contactNumber'].toString());
    TextEditingController addressController =
        TextEditingController(text: customerToEdit['address'].toString());
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
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
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
                  customerToEdit['name'] = nameController.text;
                  customerToEdit['contactNumber'] =
                      contactNumberController.text;
                  customerToEdit['address'] = addressController.text;
                  customerToEdit['email'] = emailController.text;
                  customerToEdit['__t'] = "Customer";

                  if (_profileImage != null) {
                    var editprofileUploadResponse =
                        await uploadProfileImageToServer(_profileImage!);
                    if (editprofileUploadResponse != null) {
                      customerToEdit["image"] =
                          editprofileUploadResponse["url"];
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
                    });

                    fetchData();
                    Navigator.pop(context);
                  } else {
                    print(
                        'Failed to update the customer. Status code: ${response.statusCode}');
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
    Map<String, dynamic> customerToEdit =
        customerDataList.firstWhere((data) => data['_id'] == id);

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
                        customerToEdit['image'].toString(),
                      ),
                    ),
                  ),
                  const Divider(),
                  BodyMediumOver(
                    text: 'Name: ${customerToEdit['name']}',
                  ),
                  BodyMediumText(
                    text: 'Mobile #: ${customerToEdit['contactNumber']}',
                  ),
                  BodyMediumOver(
                    text: 'Address: ${customerToEdit['address']}',
                  ),
                  BodyMediumOver(
                    text: 'Email Address: ${customerToEdit['email']}',
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
                  customerToEdit['password'] = passwordController.text;

                  final url = Uri.parse(
                      'https://lpg-api-06n8.onrender.com/api/v1/users/$id/password');
                  final headers = {'Content-Type': 'application/json'};

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
    Map<String, dynamic> customerToEdit =
        customerDataList.firstWhere((data) => data['_id'] == id);
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
                        customerToEdit['image'].toString(),
                      ),
                    ),
                  ),
                  const Divider(),
                  BodyMediumOver(
                    text: 'Name: ${customerToEdit['name']}',
                  ),
                  BodyMediumText(
                    text: 'Mobile #: ${customerToEdit['contactNumber']}',
                  ),
                  BodyMediumOver(
                    text: 'Address: ${customerToEdit['address']}',
                  ),
                  BodyMediumOver(
                    text: 'Email Address: ${customerToEdit['email']}',
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
                    customerDataList.removeWhere((data) => data['_id'] == id);
                  });

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
          'Customer List',
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
                            openAddCustomerDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF050404).withOpacity(0.9),
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
                    if (customerDataList.isEmpty && !loadingData)
                      const Center(
                        child: Column(
                          children: [
                            SizedBox(height: 40),
                            Text(
                              'No customers to display.',
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
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: customerDataList.length,
                              itemBuilder: (BuildContext context, int index) {
                                final userData = customerDataList[index];
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
                                          title: TitleMedium(
                                              text: '${userData['name']}'),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Divider(),
                                              BodyMediumText(
                                                  text:
                                                      'Mobile #: ${userData['contactNumber']}'),
                                              BodyMediumText(
                                                  text:
                                                      'Email: ${userData['email']}'),
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
                                                width: 40,
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
                                                width: 20,
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
