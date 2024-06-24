import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart'; // Import this package for clipboard functionality

class TextRecog extends StatefulWidget {
  const TextRecog({Key? key}) : super(key: key);

  @override
  State<TextRecog> createState() => _TextRecogState();
}

class _TextRecogState extends State<TextRecog> {
  File? selectedImage;
  String recognizedText = '';
  String detectedObject = '';

  Future<void> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    await requestPermissions();

    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        recognizedText = '';
        detectedObject = '';
      });
      recognizeTextAndObject(image.path);
    }
  }

  Future<void> recognizeTextAndObject(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);

    // Text recognition
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedTextResult =
        await textRecognizer.processImage(inputImage);

    // Object detection and labeling
    final options = ObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects: false,
      multipleObjects: true,
    );
    final objectDetector = ObjectDetector(options: options);
    final List<DetectedObject> objects =
        await objectDetector.processImage(inputImage);

    String objectLabels = '';
    if (objects.isNotEmpty) {
      for (DetectedObject object in objects) {
        for (Label label in object.labels) {
          objectLabels += label.text + ' ';
        }
      }
    }

    setState(() {
      recognizedText = recognizedTextResult.text;
      detectedObject = objectLabels.trim();
    });
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: recognizedText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recognized text copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Text Recognizer"),
        centerTitle: true,
      ),
      body: _widgetBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageSourceActionSheet(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _widgetBody() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _imageView(),
          _objectView(),
          _textView(),
          if (recognizedText.isNotEmpty)
            ElevatedButton(
              onPressed: _copyToClipboard,
              child: Text('Copy Text to Clipboard'),
            ),
        ],
      ),
    );
  }

  Widget _imageView() {
    if (selectedImage == null) {
      return Center(
        child: Text('Pick an image for text recognition and object detection'),
      );
    }
    return Center(
      child: Image.file(selectedImage!, width: 300, height: 300),
    );
  }

  Widget _objectView() {
    if (detectedObject.isEmpty) {
      return Center(
        child: Text('No objects detected'),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          detectedObject,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _textView() {
    if (recognizedText.isEmpty) {
      return Center(
        child: Text('Recognized text will appear here'),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          recognizedText,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)
        ),
      ),
    );
  }
}
