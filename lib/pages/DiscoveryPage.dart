import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:core';

class DiscoveryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new DiscoveryPageState();
  }
}

class DiscoveryPageState extends State<DiscoveryPage> {
//  File _image;
//
//  FormData createForm(file) {
//    return FormData.from({
//      "image": UploadFileInfo(file, basename(file.path)),
//      "image_type": 0
//    });
//  }
//
//  Future getImage() async {
//    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
//    setState(() {
//      _image = image;
//    });
//  }

  @override
  Widget build(BuildContext context) {
//    return Scaffold(
//      body: new Column(
//        mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
////          new FlatButton(
////            child: new Icon(Icons.fastfood),
////            onPressed: () {
////              print("测试内容");
////            }
////          ),
//            new Container(
//                child: new Center(
//                  child: _image == null
//                      ? Text('No image selected.')
//                      : Image.file(_image),
//                )
//            ),
//          ]
//      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: getImage,
//        tooltip: 'Pick Image',
//        child: Icon(Icons.add_a_photo),
//      ),
//    );
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
              padding: const EdgeInsets.all(10.0),
              child: new Center(
                child: new Column(
                  children: <Widget>[
                    new Text("正在开发"),
                    new Text("晚些再来看噢")
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }

}

