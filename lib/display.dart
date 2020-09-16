import 'package:flutter/animation.dart';
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
  var isCaculating = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Dogs Vs Cats'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Image.file(Io.File(widget.imagePath)),
          Column(
            children: <Widget>[
              isCaculating == false
                  ? Center(
                child: Text('Press Bottom Button to Calculate'),
              )
                  : results == null
                  ? Center(
                child: Column(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text('Calculating...')
                  ],
                ),
              )
                  : Center(
                child: Column(
                  children: <Widget>[
                    Text('It is a:'),
                    Text(
                      '${results}',
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w900),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, left: 20.0),
        child: Row(
          children: <Widget>[
            FloatingActionButton.extended(
              tooltip: 'Tap to Calculate',
              label: Text('Calculate'),
              icon: Icon(Icons.memory),
              onPressed: () {
                setState(() {
                  results = null;
                  isCaculating = true;
                });
                getResults();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future getResults() async {
    Future.delayed(Duration(milliseconds: 10000));
    String res = await Tflite.loadModel(
        model: "assets/converted_model.tflite",
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
    print(recognitions);
    setState(() {
      results = recognitions[0]['label'];
    });
    return recognitions;
  }
}
