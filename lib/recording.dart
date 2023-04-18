/////////////////////////////////////
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:gallery_saver/gallery_saver.dart';
// import 'package:image_picker/image_picker.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   String firstButtonText = 'Take photo';
//   String secondButtonText = 'Record video';
//   double textSize = 20;

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         home: Scaffold(
//           body: Container(
            
//             color: Colors.white,
//             child: Column(
//               children: <Widget>[
//                 Flexible(
//                   flex: 1,
//                   child: Container(
//                     child: SizedBox.expand(

//                     ),
//                   ),
//                 ),
//                 Flexible(
//                   child: Container(
//                       child: SizedBox.expand(
//                         child: ElevatedButton(
//                           onPressed: _recordVideo,
//                           child: Text(secondButtonText,
//                               style: TextStyle(
//                                   fontSize: textSize, color: Colors.blueGrey)),
//                         ),
//                       )),
//                   flex: 1,
//                 )
//               ],
//             ),
//           ),
//         ));
//   }



//   void _recordVideo() async {
//     final ImagePicker picker = ImagePicker();
//     picker.pickVideo(source: ImageSource.camera)
//         .then((recordedVideo) {
//       if (recordedVideo != null && recordedVideo.path != null) {
//         setState(() {
//           secondButtonText = 'saving in progress...';
//         });
//         GallerySaver.saveVideo(recordedVideo.path).then((path) {
//           setState(() {
//             secondButtonText = 'video saved!';
//           });
//         });
//       }
//     });
//   }

// }



////////////////////////////////////////////////////////






import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'button.dart';
import 'dart:async';

List<CameraDescription> cameras = [];

Route _createRoute(page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end);
      final offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

class RecordingPage extends StatefulWidget {
  // const LoginPage({super.key});

  @override
  _RecordingPageState createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  bool isWorking = false;

  String result = "";

  CameraController? cameraController;

  CameraImage? imgCamera;


 
  

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/mobilenet_v1_1.0_224.tflite',
      labels: 'assets/mobilenet_v1_1.0_224.txt',
    );
  }

  initCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController?.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController?.startImageStream((imageFromStream) => {
              if (!isWorking)
                {
                  isWorking = true,
                  imgCamera = imageFromStream,
                  runModelOnStreamFrames(),
                }
            });
      });
    });
  }

  runModelOnStreamFrames() async {
    if (imgCamera != null) {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: imgCamera!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: imgCamera!.height,
        imageWidth: imgCamera!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );

      result = "";
      recognitions?.forEach((response) {
        result += response["label"]
            // +
            //     " " +
            //     (response["confidence"] as double).toStringAsFixed(2) +
            //     "\n\n"
            ;
      });
      setState(() {
        result;
      });
      isWorking = false;
    }
  }

  @override
  void initState() {
    loadModel();
    super.initState();
  }

  @override
  void dispose() async {
    await Tflite.close();
    cameraController!.dispose();
    super.dispose();
  }

    // Initialize an instance of Stopwatch
  final Stopwatch _stopwatch = Stopwatch();

  // Timer
  late Timer _timer;

  // The result which will be displayed on the screen
  String _result = '00:00:00';

  // This function will be called when the user presses the Start button
  void _start() {
    // Timer.periodic() will call the callback function every 100 milliseconds
    _timer = Timer.periodic(const Duration(milliseconds: 30), (Timer t) {
      // Update the UI
      setState(() {
        // result in hh:mm:ss format
        _result =
            '${_stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inMilliseconds % 100).toString().padLeft(2, '0')}';
      });
    });
    // Start the stopwatch
    _stopwatch.start();
    //start the camera
    initCamera();
  }

  // This function will be called when the user presses the Stop button
  void _stop() {
    _timer.cancel();
    _stopwatch.stop();

    Navigator.of(context).push(_createRoute(ButtonPage()));
  }

  // // This function will be called when the user presses the Reset button
  // void _reset() {
  //   _stop();
  //   _stopwatch.reset();

  //   // Update the UI
  //   setState(() {});
  // }

  

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Container(
            // padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
            color: Colors.white,
            // child: Container(
            //   color: Colors.black,
            // ),
            child: Column(
              children: [
                // Expanded(child: Text('data')),
                Stack(children: [
                  Container(
                    height:840,
                    child: imgCamera == null
                        ? Expanded(
                            flex: 12,
                            child: Container(
                              // color: Colors.red,
                              height:double.infinity,
                              width: double.infinity,
                            ),
                          )
                        : Expanded(
                            flex: 12,
                            child: Container(
                              width: double.infinity,
                              child: AspectRatio(
                                aspectRatio:
                                    cameraController!.value.aspectRatio,
                                child: CameraPreview(cameraController!),
                              ),
                            ),
                          ),
                  ),
                  Container(
                    height: 700,
                    child: Center(
                      child: Text(
                        result,
                        // textAlign: TextAlign.center,
                        // 'Detected Incident : ',
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'RobotoSlab',
                          fontWeight: FontWeight.bold,
                          backgroundColor: Colors.black87,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(
                   
                    child:Expanded(
                                child: imgCamera == null
                                    ? Text(
                                        '',
                                      )
                                    : Text(
                                        'Inference Time     : $_result',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontFamily: 'RobotoSlab',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )),
                  ),
                  
                   Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: 130,
                          height: 50,
                          child: imgCamera == null
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    _start() ;
                                  },
                                  child: Text(
                                    'Start',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 19),
                                  ),
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    _stop();
                                  },
                                  child: Text(
                                    'Exit',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 19),
                                  ),
                                ),
                        ),
                      ),
                ]),
                // SizedBox(
                //   height: 10,
                // ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
