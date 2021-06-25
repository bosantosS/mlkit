import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:mlkit/providers/auth_provider.dart';
import 'package:mlkit/utils/scanner_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  //HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

    //For scanner
    CameraLensDirection _direction = CameraLensDirection.back;//Usar camara trasera
    CameraController _cameraCtrl;//Funciones y control de camara
    String _textRecognized;

    //Ciclo de vida de un Widget
    //https://medium.com/@resand/ciclo-de-vida-de-flutter-para-desarrolladores-android-e-ios-4bc4dfcd7169
      
  
  @override
    void initState() { 
      super.initState();
      initCamera(); 
    }

    void initCamera() async {
      _textRecognized = "";
      final CameraDescription description = await ScannerUtils.getCamera(_direction);
      setState(() {
              _cameraCtrl = CameraController(
                description,
                ResolutionPreset.high
              );
            });
      // Initializar la camera luego de configrar el Ctrl
      await _cameraCtrl.initialize();
      print('Camera works!');
    }

    @override
    void dispose() { 
      super.dispose();
      _cameraCtrl?.dispose();
    }

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: 
          Stack(
            fit: StackFit.expand,//Como posiciona los elementos
            children: <Widget>[
              _cameraCtrl == null 
              ? Container(
                color: Theme.of(context).primaryColor,
              )
              : Container(
                height: MediaQuery.of(context).size.height,
                child: CameraPreview(_cameraCtrl),
              ),
              if(_textRecognized != "")
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Hemos encontrado el texto: ',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      Text(
                        _textRecognized,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),

                      )
                    ],),
                ),
                Positioned(
                  bottom: 50,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _textRecognized == ""
                        ? GestureDetector(
                          child: Container(
                            width: 60.0,
                            height: 60.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.camera, size: 40.0,color: Colors.white),
                              onPressed: (){
                                takePicture();
                              },
                            )
                          )
                        )
                        : Column(
                          children: <Widget>[
                            FlatButton(
                              color: Colors.white,
                              child: Text(
                                'Take another picture',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              onPressed: () {
                                setState(
                                  (){
                                    _textRecognized ="";
                                  }
                                );

                              },
                            )
                          ],
                        )
                      ],
                    ),
                  )
                  
                )
              
            ],
          ),
        
    );
  }

  void takePicture() async {
    // Preparar almacenamiento temp
    Directory tempDir = await getTemporaryDirectory();
    bool dirExists = await tempDir.exists();
    String tempPath =  tempDir.path + "/" + DateTime.now().millisecond.toString();
    


    // Preparar la camera y tomar la foto
    await _cameraCtrl.initialize();
    final XFile fileImg = await _cameraCtrl.takePicture();
    tempPath = fileImg.path;
    print('Take a picture');


    // Reconocer el texto con Firebase ML kit
    final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    FirebaseVisionImage preProcessImage = new FirebaseVisionImage.fromFilePath(tempPath);
    VisionText textRecognized = await textRecognizer.processImage(preProcessImage);
    String text = textRecognized.text;

    setState(() {
          _textRecognized = text;
    });

  }

  
}