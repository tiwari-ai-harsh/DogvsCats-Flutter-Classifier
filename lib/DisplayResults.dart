import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:io' as Io;
import 'package:image/image.dart' as im;
import 'package:tflite/tflite.dart';


class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  const DisplayPictureScreen({this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display the Picture'),
      ),
      body: Image.file(Io.File(imagePath)),
    );
  }

  Future _getResults(String filePath) async {
    await _resizePhoto();

    String res = await Tflite.loadModel(
        model: "assets/catsvsdogs.tflite",
        labels: "assets/labels.txt",
        numThreads: 1 // defaults to 1
    );
    var recognitions = await Tflite.runModelOnImage(
        path: filePath,   // required
        imageMean: 0.0,   // defaults to 117.0
        imageStd: 255.0,  // defaults to 1.0
        numResults: 2,    // defaults to 5
        threshold: 0.2,   // defaults to 0.1
        asynch: true      // defaults to true
    );
    await Tflite.close();

    return recognitions;
  }

  Future<String> _resizePhoto() async {
    im.Image image = im.decodeImage(new Io.File(imagePath).readAsBytesSync());

    im.Image thumbnail = im.copyResize(image, width: 160, height: 160);

    new Io.File(imagePath)
      ..writeAsBytesSync(im.encodePng(thumbnail));

    return imagePath;
  }
}

