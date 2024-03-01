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

class FaqPage extends StatefulWidget {
  @override
  _FaqPageState createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  File? _image;
  final _imageStreamController = StreamController<File?>.broadcast();

  final formKey = GlobalKey<FormState>();

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

  Future<void> addFaqToAPI(Map<String, dynamic> newFaq) async {
    final url = Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/faqs');
    final headers = {'Content-Type': 'application/json'};

    if (_image != null) {
      var profileUploadResponse = await uploadImageToServer(_image!);
      print("Upload Response: $profileUploadResponse");

      if (profileUploadResponse != null) {
        print("Image URL: ${profileUploadResponse["url"]}");
        newFaq["image"] = profileUploadResponse["url"];
      } else {
        print("FAQ Image upload failed");
        return;
      }
    }

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(newFaq),
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
    } else {}
  }

  void openAddFaqDialog() {
    TextEditingController questionController = TextEditingController();
    TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New FAQ'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Divider(),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: questionController,
                    decoration: const InputDecoration(labelText: 'Question'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Frequently Asked Question';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: answerController,
                    decoration: const InputDecoration(labelText: 'Answer'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the FAQ Answer';
                      }
                      return null;
                    },
                  ),
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
                          ImageUploader(
                            takeImage: _takeImage,
                            pickImage: _pickImage,
                            buttonText: "Upload FAQ Image",
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
                  Map<String, dynamic> newFaq = {
                    "question": questionController.text,
                    "answer": answerController.text,
                    "image": "",
                  };
                  addFaqToAPI(newFaq);
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
    Map<String, dynamic> faqToEdit =
        faqDataList.firstWhere((data) => data['_id'] == id);

    TextEditingController questionController =
        TextEditingController(text: faqToEdit['question']);
    TextEditingController answerController =
        TextEditingController(text: faqToEdit['answer']);

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
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: questionController,
                    decoration: const InputDecoration(labelText: 'Question'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Frequently Asked Question';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: answerController,
                    decoration: const InputDecoration(labelText: 'Answer'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the FAQ Answer';
                      }
                      return null;
                    },
                  ),
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
                          ImageUploader(
                            takeImage: _takeImage,
                            pickImage: _pickImage,
                            buttonText: "Upload FAQ Image",
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
                  faqToEdit['question'] = questionController.text;
                  faqToEdit['answer'] = answerController.text;

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
                    setState(() {
                      _image = null;
                    });

                    fetchData();
                    Navigator.pop(context);
                  } else {
                    print(
                        'Failed to update the faq. Status code: ${response.statusCode}');
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
                    'https://lpg-api-06n8.onrender.com/api/v1/faqs/$id');
                final response = await http.delete(url);

                if (response.statusCode == 200) {
                  setState(() {
                    faqDataList.removeWhere((data) => data['_id'] == id);
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
        title: const Text('FAQ List'),
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
                        openAddFaqDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF232937),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Add FAQ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: faqDataList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final userData = faqDataList[index];
                    final id = userData['_id'];

                    return Card(
                      elevation: 4,
                      child: ListTile(
                        title: TitleMedium(text: userData['question']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            BodyMediumText(
                              text: 'Answer: ${userData['answer']}',
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
