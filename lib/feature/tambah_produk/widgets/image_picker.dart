import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final void Function(String?) onImagePicked;
  final String? initialImage;

  const ImagePickerWidget({
    super.key,
    required this.onImagePicked,
    this.initialImage,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _imageFile;
  String? base64String;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    base64String = widget.initialImage;
  }

  Future<XFile?> _compressImage(File file) async {
    final directory = await Directory.systemTemp.createTemp();
    final targetPath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 50,
    );
    if (kDebugMode) {
      print('Compressed file size: ${compressedFile!.path}');
    }
    return compressedFile;
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
    );

    if (kDebugMode) {
      print('Initial image size: ${await pickedFile!.length()} bytes');
    }

    if (pickedFile != null) {
      File originalFile = File(pickedFile.path);
      XFile? compressedFile = await _compressImage(originalFile);

      if (kDebugMode) {
        print('Compressed image size: ${await compressedFile!.length()} bytes');
      }

      setState(() {
        _imageFile = File(compressedFile!.path);
      });

      if (_imageFile != null) {
        List<int> imageBytes = await _imageFile!.readAsBytes();
        base64String = base64Encode(imageBytes);
        widget.onImagePicked(base64String);
      }
    }
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Buka Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPickerOptions(context),
      child: Container(
        width: 100, // Sesuaikan ukuran container
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _imageFile!,
                  fit: BoxFit.cover,
                ),
              )
            : (base64String != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      base64Decode(base64String!),
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.camera_alt,
                    color: Colors.black54,
                    size: 30,
                  )),
      ),
    );
  }
}
