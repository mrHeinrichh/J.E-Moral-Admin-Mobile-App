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
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AccessoryPage extends StatefulWidget {
  @override
  _AccessoryPageState createState() => _AccessoryPageState();
}

class _AccessoryPageState extends State<AccessoryPage> {
  File? _image;
  final _imageStreamController = StreamController<File?>.broadcast();

  final formKey = GlobalKey<FormState>();
  bool loadingData = false;

  List<Map<String, dynamic>> accessoryDataList = [];
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
        'https://lpg-api-06n8.onrender.com/api/v1/items/?page=$page&limit=$limit'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> itemList = data['data'];

      final List<Map<String, dynamic>> accessoryData = itemList
          .where((item) => item['type'] == 'Accessory')
          .map((accessoryData) => accessoryData as Map<String, dynamic>)
          .toList();

      setState(() {
        accessoryDataList.clear();
        accessoryDataList.addAll(accessoryData);
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
          'https://lpg-api-06n8.onrender.com/api/v1/items/?search=$query&limit=300'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> filteredData = (data['data'] as List)
          .where((accessoryData) =>
              accessoryData is Map<String, dynamic> &&
              accessoryData['type'] == 'Accessory' &&
              (accessoryData['name']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  accessoryData['description']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  accessoryData['stock']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase())))
          .map((accessoryData) => accessoryData as Map<String, dynamic>)
          .toList();

      setState(() {
        accessoryDataList = filteredData;
      });
    } else {}
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

  Future<void> addAccessoryToAPI(Map<String, dynamic> newAccessory) async {
    final url = Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/items');
    final headers = {'Content-Type': 'application/json'};

    try {
      var uploadResponse = await uploadImageToServer(_image!);
      print("Upload Response: $uploadResponse");

      if (uploadResponse != null) {
        print("Image URL: ${uploadResponse["url"]}");
        newAccessory["image"] = uploadResponse["url"];

        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(newAccessory),
        );

        print("API Response: ${response.statusCode} - ${response.body}");

        if (response.statusCode == 201 || response.statusCode == 200) {
          fetchData();
          Navigator.pop(context);
        } else {
          print(
              'Failed to add or update the accessory. Status code: ${response.statusCode}');
        }
      } else {
        print("Image upload failed");
      }
    } catch (e) {
      print("Exception during API request: $e");
    }
  }

  void openAddAccessoryDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController stockController = TextEditingController();
    TextEditingController customerPriceController = TextEditingController();
    TextEditingController retailerPriceController = TextEditingController();
    bool isImageSelected = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add New Accessory',
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
                            buttonText: "Upload Accessory Image",
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
                    controller: nameController,
                    labelText: "Accessory Name",
                    hintText: 'Enter the Accessory Name',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the Accessory Name";
                      } else {
                        return null;
                      }
                    },
                  ),
                  EditTextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: descriptionController,
                    labelText: "Description",
                    hintText: 'Enter the Description',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Accessory Description';
                      }
                      return null;
                    },
                  ),
                  EditTextField(
                    controller: stockController,
                    labelText: "Stock",
                    hintText: 'Enter the Stock',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Accessory Stock';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  EditTextField(
                    controller: customerPriceController,
                    labelText: 'Customer Price',
                    hintText: 'Enter the Customer Price',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Price for Customer';
                      }
                      final RegExp numberRegex = RegExp(r'^\d+(\.\d+)?$');
                      if (!numberRegex.hasMatch(value)) {
                        return 'Please Enter a Valid Price Number';
                      }
                      return null;
                    },
                  ),
                  EditTextField(
                    controller: retailerPriceController,
                    labelText: 'Retailer Price',
                    hintText: 'Enter the Retailer Price',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Price for Retailer';
                      }
                      final RegExp numberRegex = RegExp(r'^\d+(\.\d+)?$');
                      if (!numberRegex.hasMatch(value)) {
                        return 'Please Enter a Valid Price Number';
                      }
                      return null;
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
                if (!isImageSelected) {
                  showCustomOverlay(
                      context, 'Please Upload the Accessory Image');
                } else {
                  if (formKey.currentState!.validate()) {
                    Map<String, dynamic> newAccessory = {
                      "name": nameController.text,
                      "category": "Accessories",
                      "description": descriptionController.text,
                      "weight": 0,
                      "stock": stockController.text,
                      "type": "Accessory",
                      "customerPrice": customerPriceController.text,
                      "retailerPrice": retailerPriceController.text,
                      "image": "",
                    };
                    addAccessoryToAPI(newAccessory);
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
    Map<String, dynamic> accessoryToEdit =
        accessoryDataList.firstWhere((data) => data['_id'] == id);

    TextEditingController nameController =
        TextEditingController(text: accessoryToEdit['name']);
    TextEditingController descriptionController =
        TextEditingController(text: accessoryToEdit['description']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Edit Accessory',
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
                                              (accessoryToEdit['image'] ?? '')
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
                                                  accessoryToEdit['image']!,
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
                            buttonText: "Upload Accessory Image",
                          ),
                        ],
                      );
                    },
                  ),
                  EditTextField(
                    controller: nameController,
                    labelText: "Accessory Name",
                    hintText: 'Enter the Accessory Name',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter the Accessory Name";
                      } else {
                        return null;
                      }
                    },
                  ),
                  EditTextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: descriptionController,
                    labelText: "Description",
                    hintText: 'Enter the Description',
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter the Accessory Description';
                      }
                      return null;
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
                  accessoryToEdit['name'] = nameController.text;
                  accessoryToEdit['description'] = descriptionController.text;
                  accessoryToEdit['type'] = "Accessory";

                  if (_image != null) {
                    var uploadResponse = await uploadImageToServer(_image!);
                    if (uploadResponse != null) {
                      accessoryToEdit["image"] = uploadResponse["url"];
                    }
                  }
                  final url = Uri.parse(
                      'https://lpg-api-06n8.onrender.com/api/v1/items/$id');
                  final headers = {'Content-Type': 'application/json'};

                  final response = await http.patch(
                    url,
                    headers: headers,
                    body: jsonEncode(accessoryToEdit),
                  );

                  if (response.statusCode == 200) {
                    setState(() {
                      _image = null;
                    });

                    fetchData();
                    Navigator.pop(context);
                  } else {
                    print(
                        'Failed to update the accessory. Status code: ${response.statusCode}');
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
    Map<String, dynamic> accessoryToEdit =
        accessoryDataList.firstWhere((data) => data['_id'] == id);
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
                        accessoryToEdit['image'] ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  const Divider(),
                  BodyMediumOver(
                    text: 'Name: ${accessoryToEdit['name']}',
                  ),
                  BodyMediumText(
                    text: 'Category: ${accessoryToEdit['category']}',
                  ),
                  BodyMediumOver(
                    text: 'Description: ${accessoryToEdit['description']}',
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
                    'https://lpg-api-06n8.onrender.com/api/v1/items/$id');
                final response = await http.delete(url);

                if (response.statusCode == 200) {
                  setState(() {
                    accessoryDataList.removeWhere((data) => data['_id'] == id);
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
          'Accessory List',
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
                            openAddAccessoryDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF050404).withOpacity(0.9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Add Accessory',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (accessoryDataList.isEmpty && !loadingData)
                      const Center(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 40),
                              Text(
                                'No accessories to display.',
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
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: accessoryDataList.length,
                              itemBuilder: (BuildContext context, int index) {
                                final accessoryData = accessoryDataList[index];
                                final id = accessoryData['_id'];

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
                                                  accessoryData['image'] ?? ''),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: TitleMedium(
                                            text: '${accessoryData['name']}'),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Divider(),
                                            BodyMediumText(
                                              text:
                                                  'Category: ${accessoryData['category']}',
                                            ),
                                            BodyMediumText(
                                              text:
                                                  'Description: ${accessoryData['description']}',
                                            ),
                                            BodyMediumText(
                                              text:
                                                  'Stocks: ${accessoryData['stock']}',
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
