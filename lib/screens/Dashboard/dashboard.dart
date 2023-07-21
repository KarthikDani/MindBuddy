import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rive_animation/screens/Brainstorming/drawing_room.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<String> capturedFiles = [];

  @override
  void initState() {
    super.initState();
    loadCapturedFiles();
  }

  Future<void> loadCapturedFiles() async {
    try {
      // Get the application documents directory
      Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      String appDirPath = appDocumentsDir.path;

      // Create a sub-directory for your application, if it doesn't exist
      String appSubDir = '$appDirPath/rive_animation';

      // Load the list of captured files from the dedicated app directory
      Directory appDir = Directory(appSubDir);
      List<FileSystemEntity> files = appDir.listSync();
      setState(() {
        capturedFiles = files.map((file) => file.path).toList();
      });
    } catch (e) {
      // Handle any errors that may occur during loading
      // You can add error handling code here if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Implement sorting functionality
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'date',
                child: Text(
                  'Sort by Date',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem(
                value: 'name',
                child: Text(
                  'Sort by Name',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
            color: Colors.black,
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: capturedFiles.length,
        itemBuilder: (context, index) {
          String filePath = capturedFiles[index];
          return GestureDetector(
            onTap: () {
              // Navigate to the WhiteboardScreen with the selected file data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WhiteboardScreen(),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(filePath), fit: BoxFit.cover),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WhiteboardScreen(),
            ),
          );
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
