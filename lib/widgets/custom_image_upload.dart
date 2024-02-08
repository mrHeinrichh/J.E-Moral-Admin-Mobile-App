import 'package:flutter/material.dart';

class ImageUploaderValidator extends StatelessWidget {
  final VoidCallback takeImage;
  final VoidCallback pickImage;
  final String buttonText;
  final Function(bool) onImageSelected;

  const ImageUploaderValidator({
    required this.takeImage,
    required this.pickImage,
    required this.buttonText,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.camera),
                      title: const Text('Take a Photo'),
                      onTap: () {
                        Navigator.pop(context);
                        takeImage();
                        onImageSelected(true);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Choose from Gallery'),
                      onTap: () {
                        Navigator.pop(context);
                        pickImage();
                        onImageSelected(true);
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Align(
            alignment: Alignment.center,
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 15.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class ImageUploader extends StatelessWidget {
  final VoidCallback takeImage;
  final VoidCallback pickImage;
  final String buttonText;

  const ImageUploader({
    required this.takeImage,
    required this.pickImage,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.camera),
                      title: const Text('Take a Photo'),
                      onTap: () {
                        Navigator.pop(context);
                        takeImage();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Choose from Gallery'),
                      onTap: () {
                        Navigator.pop(context);
                        pickImage();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Align(
            alignment: Alignment.center,
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 15.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
