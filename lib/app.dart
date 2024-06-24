import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_picker/gallery_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class TextRecog extends StatefulWidget {
  const TextRecog({super.key});

  @override
  State<TextRecog> createState() => _TextRecogState();
}

class _TextRecogState extends State<TextRecog> {
  File? selectedImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Text Recognizer"),
        centerTitle: true,
      ),
      body: _widgetBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<MediaFile>? media = await GalleryPicker.pickMedia(
            context: context,
            singleMedia: true,
          );
          print('this is media ${media}');
          if (media != null && media.isNotEmpty) {
            var data = await media.first.getFile();
            print('this is data $data');
            setState(() {
              selectedImage = data;
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _widgetBody() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _imageView(),
      ],
    );
  }

  Widget _imageView() {
    if (selectedImage == null) {
      return Center(
        child: Text('Pick and image for text recognition'),
      );
    }
    return Center(
      child: Image.file(selectedImage!, width: 300, height: 300),
    );
  }

  Future<void> requestPermissions() async {
    if (await Permission.storage.request().isGranted &&
        await Permission.camera.request().isGranted) {
      print('Permissions granted');
    } else {
      print('Permissions not granted');
    }
  }
}
