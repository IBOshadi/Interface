import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'homePage.dart';
import 'recording.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ),
  );
 
}


 


