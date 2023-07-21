import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whiteboard/whiteboard.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(const MyApp());
}

class WhiteboardDrawing {
  Uint8List imageBytes;
  List<Offset> drawingPoints;
  DateTime dateTime;

  WhiteboardDrawing({
    required this.imageBytes,
    required this.drawingPoints,
    required this.dateTime,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whiteboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 8,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
      home: const WhiteboardScreen(),
    );
  }
}

class WhiteboardScreen extends StatefulWidget {
  const WhiteboardScreen({super.key});

  @override
  _WhiteboardScreenState createState() => _WhiteboardScreenState();
}

class _WhiteboardScreenState extends State<WhiteboardScreen> {
  var availableColor = [
    Colors.black,
    Colors.red,
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.brown,
  ];

  var selectedColor = Colors.black;
  var selectedWidth = 2.0;

  WhiteBoardController whiteBoardController = WhiteBoardController();

  List<WhiteboardDrawing> whiteboardDrawings = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                InteractiveViewer(
                  child: RepaintBoundary(
                    key: _whiteboardKey,
                    child: WhiteBoard(
                      backgroundColor: Colors.white,
                      controller: whiteBoardController,
                      strokeWidth: selectedWidth,
                      strokeColor: selectedColor,
                      isErasing: false,
                      onConvertImage: (list) {},
                      onRedoUndo: (t, m) {},
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (Color color in availableColor)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              foregroundDecoration: BoxDecoration(
                                border: selectedColor == color
                                    ? Border.all(color: Colors.blue, width: 4)
                                    : null,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: () => _showColorPickerDialog(),
                          child: Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: selectedColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.color_lens,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 80,
                  right: 0,
                  bottom: 150,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Slider(
                      value: selectedWidth,
                      min: 1,
                      max: 20,
                      onChanged: (value) {
                        setState(() {
                          selectedWidth = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  whiteBoardController.clear();
                },
                child: const Icon(Icons.layers_clear),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () async {
                  Uint8List? byteData = await _captureWhiteboardAsImage();
                  if (byteData != null) {
                    bool success = await _saveImageToDeviceGallery(byteData);
                    _showImageSavedSnackBar(success);
                  } else {
                    _showImageSavedSnackBar(false);
                  }
                },
                child: const Icon(Icons.save),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  whiteBoardController.redo();
                },
                child: const Icon(Icons.redo),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  whiteBoardController.undo();
                },
                child: const Icon(Icons.undo),
              ),
              Container(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.bottom),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context); // Go back to the dashboard
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final GlobalKey _whiteboardKey = GlobalKey();

  Future<Uint8List?> _captureWhiteboardAsImage() async {
    try {
      RenderRepaintBoundary boundary = _whiteboardKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Future<bool> _saveImageToDeviceGallery(Uint8List byteData) async {
    try {
      // Get the application documents directory
      Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      String appDirPath = appDocumentsDir.path;

      // Create a sub-directory for your application, if it doesn't exist
      String appSubDir = '$appDirPath/rive_animation';
      await Directory(appSubDir).create(recursive: true);

      // Generate a unique filename using the current timestamp
      String filename = '${DateTime.now().millisecondsSinceEpoch}.png';

      // Save the image to the dedicated app directory
      String filePath = '$appSubDir/$filename';
      File file = File(filePath);
      await file.writeAsBytes(byteData);

      // Save the image to the device's gallery
      final result = await ImageGallerySaver.saveFile(filePath);
      return result['isSuccess'];
    } catch (e) {
      return false;
    }
  }

  void _showImageSavedSnackBar(bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.cancel,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              success ? 'Image saved to gallery' : 'Failed to save image',
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black,
        elevation: 6,
      ),
    );
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
              // ignore: deprecated_member_use
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
