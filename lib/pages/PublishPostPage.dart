import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:core';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jxt/api/Api.dart';
import 'package:jxt/utils/DataUtils.dart';
import 'package:jxt/utils/NetUtils.dart';
import 'package:jxt/utils/ThemeUtils.dart';
import 'package:jxt/utils/ToastUtils.dart';

class PublishPostPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new PublishPostPageState();
  }
}

class PublishPostPageState extends State<PublishPostPage> {
  List<File> _imageList = [];
  List _imageIdList = [];
  TextEditingController _controller = new TextEditingController();
  bool isLoading = false;

  int currentLength = 0;
  int maxLength = 140;
  Color counterTextColor = Colors.grey;

  String msg = "";

  static double _iconWidth = 24.0;
  static double _iconHeight = 24.0;
  static Color _iconColor = Colors.grey;

  final Widget poundIcon = new SvgPicture.asset(
      "assets/icons/Topic.svg",
      color: Colors.grey,
      width: _iconWidth,
      height: _iconHeight
  );

  @override
  void initState() {
    super.initState();
  }

  Widget _counter() {
    return new Padding(
        padding: EdgeInsets.only(right: 11.0),
        child: new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Text(
                  "$currentLength/$maxLength",
                  style: new TextStyle(
                      color: counterTextColor
                  )
              )
            ]
        )
    );
  }

  Widget _toolbar() {
    return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
//          new IconButton(
//              onPressed: null,
//              icon: new Icon(Icons.add_circle_outline)
//          ),
          new IconButton(
              onPressed: () {},
//              icon: new Icon(Icons.add_comment)
              icon: poundIcon
          ),
          new IconButton(
              onPressed: () {

              },
              icon: new Icon(
                Icons.alternate_email,
                color: _iconColor,
              )
          ),
          new IconButton(
              onPressed: () {
                _addImage(ImageSource.camera);
              },
              icon: new Icon(
                Icons.add_a_photo,
                color: _iconColor,
              )
          ),
          new IconButton(
              onPressed: () {
                _addImage(ImageSource.gallery);
              },
              icon: new Icon(
                Icons.add_photo_alternate,
                color: _iconColor,
              )
          ),
        ]
    );
  }

  Future _addImage(imageSource) async {
    num size = _imageList.length;
    if (size >= 9) {
      showShortToast("最多只能添加9张图片！");
      return;
    }
    var image = await ImagePicker.pickImage(source: imageSource);
    if (image != null) {
      setState(() {
        _imageList.add(image);
      });
    }
  }

  Widget _body() {
    Widget textField = new Expanded(
        flex: 1,
        child: new Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            child: new TextField(
              decoration: new InputDecoration(
                  hintText: "分享新鲜事...",
                  hintStyle: new TextStyle(
                      color: Colors.grey,
                      fontSize: 18.0
                  ),
                  border: InputBorder.none,
                  labelStyle: new TextStyle(color: Colors.white, fontSize: 18.0),
                  counterStyle: new TextStyle(color: ThemeUtils.currentPrimaryColor)
              ),
              style: new TextStyle(fontSize: 18.0),
              cursorColor: Colors.grey,
              maxLines: null,
              maxLength: maxLength,
              controller: _controller,
              onChanged: (content) {
                if (content.length == maxLength) {
                  setState(() {
                    counterTextColor = Colors.red;
                  });
                } else {
                  if (counterTextColor != Colors.grey) {
                    setState(() {
                      counterTextColor = Colors.grey;
                    });
                  }
                }
                setState(() {
                  currentLength = content.length;
                });
              },
            )
        )
    );
    Widget gridView = new Builder(
      builder: (context) {
        return new GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          children: new List.generate(_imageList.length, (index) {
            // 用于生成GridView中的一个item
            return new Container(
                margin: const EdgeInsets.all(2.0),
                color: Colors.grey,
                child: new Image.file(_imageList[index], fit: BoxFit.cover)
            );
          }),
        );
      },
    );
    List<Widget> children = [
      textField,
      new Container(
          child: gridView
      ),
      _counter(), _toolbar()
    ];
    if (isLoading) {
      children.add(new Container(
        margin: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: new Center(
          child: new CircularProgressIndicator(),
        ),
      ));
    }
    return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children
    );
  }

  FormData createForm(file) {
    return FormData.from({
      "image": UploadFileInfo(file, basename(file.path)),
      "image_type": 0
    });
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageList.add(image);
    });
    DataUtils.getSid().then((sid) {
      getImageRequest(image, sid).catchError((e) {
        print(e.response);
      });
    });
  }

  void post(context) {
    String content = _controller.text;
    if (content == null || content.length == 0 || content.trim().length == 0) {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("内容不能为空！"),
      ));
    }
    try {
      DataUtils.getSid().then((sid) {
        List<Future> query = [];
        _imageIdList = [];
        for (File image in _imageList) {
          query.add(getImageRequest(image, sid));
        }
        _postImagesQuery(query).then((isComplete) {
          if (isComplete != null) {
            Map<String, dynamic> data = new Map();
            data['category'] = "text";
            data['content'] = Uri.encodeFull(content);
            String extraId = _imageIdList.toString();
            data['extra_id'] = extraId.substring(1, extraId.length - 1);
            _postContent(data, sid, context);
          }
        });
      });
    } catch (exception) {
      showCenterShortToast(exception);
    }
  }

  Future getImageRequest(image, sid) async {
    return NetUtils.postWithCookieAndHeaderSet(
        Api.postUploadImage,
        data: createForm(image),
        headers: NetUtils.buildPostHeaders(sid),
        cookies: NetUtils.buildPHPSESSIDCookies(sid)
    ).then((response) {
      int imageId = int.parse(jsonDecode(response)['image_id']);
      _imageIdList.add(imageId);
      return response;
    });
  }

  Future _postImagesQuery(query) async {
    return await Future.wait(query);
  }

  Future _postContent(content, sid, context) async {
    NetUtils.postWithCookieAndHeaderSet(
      Api.postContent,
      data: content,
      headers: NetUtils.buildPostHeaders(sid),
      cookies: NetUtils.buildPHPSESSIDCookies(sid),
    ).then((response) {
      print(response);
      if (jsonDecode(response)["tid"] != null) {
        showShortToast("动态发布成功！");
        Navigator.of(context).pop();
      } else {
        showShortToast("动态发布失败！");
      }
      return response;
    });
  }

//  void sendPost(ctx, token) async {
//    String content = _controller.text;
//    if (content == null || content.length == 0 || content.trim().length == 0) {
//      Scaffold.of(ctx).showSnackBar(new SnackBar(
//        content: new Text("请输入动弹内容！"),
//      ));
//    }
//    try {
//      Map<String, String> params = new Map();
//      params['msg'] = content;
//      params['access_token'] = token;
////     构造一个MultipartRequest对象用于上传图片
//      var request = new http.MultipartRequest('POST', Uri.parse(Api.PUB_TWEET));
//      request.fields.addAll(params);
//      if (fileList != null && fileList.length > 0) {
//        // 这里虽然是添加了多个图片文件，但是开源中国提供的接口只接收一张图片
//        for (File f in fileList) {
//          // 文件流
//          var stream = new http.ByteStream(
//              DelegatingStream.typed(f.openRead()));
//          // 文件长度
//          var length = await f.length();
//          // 文件名
//          var filename = f.path.substring(f.path.lastIndexOf("/") + 1);
//          // 将文件加入到请求体中
//          request.files.add(new http.MultipartFile(
//              'img', stream, length, filename: filename));
//        }
//      }
//      setState(() {
//        isLoading = true;
//      });
//     发送请求
//      var response = await request.send();
//     解析请求返回的数据
//      response.stream.transform(utf8.decoder).listen((value) {
//        print(value);
//        if (value != null) {
//          var obj = json.decode(value);
//          var error = obj['error'];
//          setState(() {
//            if (error != null && error == '200') {
//              // 成功
//              setState(() {
//                isLoading = false;
//                msg = "发布成功";
//                fileList.clear();
//              });
//              _controller.clear();
//            } else {
//              setState(() {
//                isLoading = false;
//                msg = "发布失败：$error";
//              });
//            }
//          });
//        }
//      });
//    } catch (exception) {
//      print(exception);
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          elevation: 1,
          leading: new BackButton(color: ThemeUtils.currentColorTheme),
          title: new Center(
              child: new Text(
                  "发布动态",
                  style: new TextStyle(
                      color: ThemeUtils.currentColorTheme,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold
                  )
              )
          ),
          iconTheme: new IconThemeData(color: ThemeUtils.currentColorTheme),
          brightness: ThemeUtils.currentBrightness,
          actions: <Widget>[
            new Builder(
              builder: (ctx) {
                return new IconButton(icon: new Icon(Icons.send), onPressed: () {
                  DataUtils.isLogin().then((isLogin) {
                    if (isLogin) {
                      return null;
                    } else {
                      return null;
                    }
                  }).then((token) {
//                  sendPost(ctx, token);
                    post(ctx);
                  });
                });
              },
            )
          ],
        ),
        body: _body()
    );
  }
}