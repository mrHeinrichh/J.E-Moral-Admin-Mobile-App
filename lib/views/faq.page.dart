import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/services.dart';

class FaqPage extends StatefulWidget {
  @override
  _FaqPageState createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  File? _image;
  final _imageStreamController = StreamController<File?>.broadcast();

  List<Map<String, dynamic>> faqDataList = [];
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
        'https://lpg-api-06n8.onrender.com/api/v1/faqs/?page=$page&limit=$limit'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> faqData = (data['data'] as List)
          .where((faqData) => faqData is Map<String, dynamic>)
          .map((faqData) => faqData as Map<String, dynamic>)
          .toList();

      setState(() {
        faqDataList.clear();
        faqDataList.addAll(faqData);
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
  }

  Future<void> addFaqToAPI(Map<String, dynamic> newFaq) async {
    final url = Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/faqs');
    final headers = {'Content-Type': 'application/json'};

    try {
      var uploadResponse = await uploadImageToServer(_image!);
      print("Upload Response: $uploadResponse");

      if (uploadResponse != null) {
        print("Image URL: ${uploadResponse["url"]}");
        newFaq["image"] = uploadResponse["url"];

        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(newFaq),
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
        'https://lpg-api-06n8.onrender.com/api/v1/faqs/?search=$query'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> faqData = (data['data'] as List)
          .where((faqData) =>
              faqData is Map<String, dynamic> &&
              faqData.containsKey('question'))
          .map((faqData) => faqData as Map<String, dynamic>)
          .toList();

      setState(() {
        faqDataList = faqData;
      });
    } else {
      // Handle the case when the response status code is not 200
    }
  }

  void openAddFaqDialog() {
    // Create controllers for each field
    TextEditingController questionController = TextEditingController();
    TextEditingController answerController = TextEditingController();

    TextEditingController imageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New FAQ'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: questionController,
                    decoration: InputDecoration(labelText: 'Question'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the faq question';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: answerController,
                    decoration: InputDecoration(labelText: 'Answer'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the faq answer';
                      }
                      return null;
                    },
                  ),
                  Text(
                    "\nFAQ Image",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.grey[700],
                    ),
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
                              "Upload Image",
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
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Additional conditions for image validation
                  if (_image == null) {
                    showCustomOverlay(context, 'Please Upload an Image');
                  } else {
                    // Create a new faq object from the input data
                    Map<String, dynamic> newFaq = {
                      "question": questionController.text,
                      "answer": answerController.text,
                      "image": imageController.text,
                    };

                    // Call the function to add the new faq to the API
                    addFaqToAPI(newFaq);
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

  void updateData(String id) {
    Map<String, dynamic> faqToEdit =
        faqDataList.firstWhere((data) => data['_id'] == id);

    TextEditingController questionController =
        TextEditingController(text: faqToEdit['question']);
    TextEditingController answerController =
        TextEditingController(text: faqToEdit['answer']);
    TextEditingController imageController =
        TextEditingController(text: faqToEdit['image']);
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Data'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: questionController,
                    decoration: InputDecoration(labelText: 'Question'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the faq question';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: answerController,
                    decoration: InputDecoration(labelText: 'Answer'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the faq answer';
                      }
                      return null;
                    },
                  ),
                  Text(
                    "\nFAQ Image",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.grey[700],
                    ),
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
                              ? (faqToEdit['image']?.toString() ?? '')
                                      .isNotEmpty
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                          faqToEdit['image']?.toString() ?? ''),
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
                              "Upload Image",
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
                if (_formKey.currentState!.validate()) {
                  faqToEdit['question'] = questionController.text;
                  faqToEdit['answer'] = answerController.text;

                  // Upload new image only if available
                  if (_image != null) {
                    var uploadResponse = await uploadImageToServer(_image!);
                    if (uploadResponse != null) {
                      print("Image URL: ${uploadResponse["url"]}");
                      faqToEdit["image"] = uploadResponse["url"];
                    } else {
                      print("Image upload failed");
                    }
                  }
                  final url = Uri.parse(
                      'https://lpg-api-06n8.onrender.com/api/v1/faqs/$id');
                  final headers = {'Content-Type': 'application/json'};

                  final response = await http.patch(
                    url,
                    headers: headers,
                    body: jsonEncode(faqToEdit),
                  );

                  if (response.statusCode == 200) {
                    fetchData();
                    Navigator.pop(context);
                  } else {
                    print(
                        'Failed to update the faq. Status code: ${response.statusCode}');
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
                    'https://lpg-api-06n8.onrender.com/api/v1/faqs/$id');
                final response = await http.delete(url);

                if (response.statusCode == 200) {
                  // Data has been successfully deleted
                  // Update the UI to remove the deleted data
                  setState(() {
                    faqDataList.removeWhere((data) => data['_id'] == id);
                  });

                  Navigator.pop(context); // Close the dialog
                } else {
                  // Handle any other status codes (e.g., 400 for validation errors, 500 for server errors, etc.)
                  print(
                      'Failed to delete the data. Status code: ${response.statusCode}');
                  // You can also display an error message to the announcement
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
          'FAQ CRUD',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
        iconTheme: IconThemeData(color: Color(0xFF232937)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            color: Color(0xFF232937),
            onPressed: () {
              // Open the dialog to add a new faq
              openAddFaqDialog();
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
                    color: Color(0xFF232937), // You can change the border color
                    width: 1.0,
                    // You can change the border width
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: DataTable(
                  columns: <DataColumn>[
                    DataColumn(label: Text('Question')),
                    DataColumn(label: Text('Answer')),
                    DataColumn(label: Text('Image')),
                    DataColumn(
                      label: Text('Actions'),
                      tooltip: 'Update and Delete',
                    ),
                  ],
                  rows: faqDataList.map((faqData) {
                    final id = faqData['_id'];
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(faqData['question'] ?? ''),
                            placeholder: false),
                        DataCell(Text(faqData['answer'] ?? ''),
                            placeholder: false),
                        DataCell(Text(faqData['image'] ?? ''),
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
    );
  }
}
