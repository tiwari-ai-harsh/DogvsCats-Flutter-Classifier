import 'package:flutter/material.dart';
import 'dart:io' as Io;
import 'package:image/image.dart' as im;
import 'package:tflite/tflite.dart';

class DisplayPicture extends StatefulWidget {
  final String imagePath;

  const DisplayPicture({Key key, this.imagePath}) : super(key: key);

  @override
  _DisplayPictureState createState() => _DisplayPictureState();
}

class _DisplayPictureState extends State<DisplayPicture> {
  var results;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Picture')),
      body: Column(
        children: <Widget>[
          Image.file(Io.File(widget.imagePath)),
          results == null
              ? Text('Identify what\'s here with that button!!')
              : Text(
                  '${results}',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.present_to_all),
        onPressed: () {
          getResults();
        },
      ),
    );
  }

  Future getResults() async {
    String res = await Tflite.loadModel(
        model: "assets/cat_dog.tflite",
        labels: "assets/labels.txt",
        numThreads: 1 // defaults to 1
        );
    var recognitions = await Tflite.runModelOnImage(
        path: widget.imagePath,
        // required
        imageMean: 0.0,
        // defaults to 117.0
        imageStd: 255.0,
        // defaults to 1.0
        numResults: 1,
        // defaults to 5
        threshold: 0.2,
        // defaults to 0.1
        asynch: true // defaults to true
        );
//    await Tflite.close();
    print(recognitions);
    setState(() {
      results = recognitions[0]['label'];
    });
    return recognitions;
  }

  void resizeImage() {
    im.Image image =
        im.decodeImage(new Io.File(widget.imagePath).readAsBytesSync());

    im.Image thumbnail = im.copyResize(image, width: 160, height: 160);
    new Io.File(widget.imagePath)..writeAsBytesSync(im.encodePng(thumbnail));
  }
}
