import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:jxt/utils/DataUtils.dart';
import 'package:jxt/utils/ThemeUtils.dart';
import 'package:jxt/widgets/CommonWebPage.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username, _password;
  bool _isObscure = true;
  Color _defaultIconColor = ThemeUtils.currentColorTheme;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Builder(
            builder: (context) =>
            new Stack(
                children: <Widget>[
                  new Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomCenter,
                        colors: const <Color>[
                          ThemeUtils.defaultColor,
                          Colors.redAccent
                        ],
                      ),
                    ),
                  ),
                  new Form(
                      key: _formKey,
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          buildTitle(),
//                          buildTitleLine(),
                          SizedBox(height: 20.0),
                          buildUsernameTextField(),
                          SizedBox(height: 30.0),
                          buildPasswordTextField(),
                          buildForgetPasswordText(context),
                          SizedBox(height: 10.0),
                          buildLoginButton(context),
                          SizedBox(height: 50.0),
//                          buildRegisterText(context),
                        ]
                      )
                  )
                ]
            )
        )
    );
  }

  Padding buildTitle() {
    return Padding(
        padding: EdgeInsets.all(8.0),
//      child: Text(
//        '登录',
//        style: TextStyle(fontSize: 42.0),
//      ),
        child: new Image.asset(
          './images/ic_jmu_logo.png',
          width: 100.0,
          height: 100.0,
        )
    );
  }

  Padding buildTitleLine() {
    return new Padding(
      padding: EdgeInsets.all(4.0),
      child: new Align(
        alignment: Alignment.bottomCenter,
        child: new Container(
          color: ThemeUtils.defaultColor,
          width: 100.0,
          height: 2.0,
        ),
      ),
    );
  }

  Padding buildUsernameTextField() {
    return new Padding(
      padding: EdgeInsets.symmetric(horizontal: 48.0),
      child: new Container(
          decoration: new BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Color.fromRGBO(255,255,255,0.2)
          ),
          child: new TextFormField(
            decoration: new InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(10.0),
              labelText: '用户名/工号/学号',
              labelStyle: new TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            style: new TextStyle(color: Colors.white, fontSize: 20.0),
            cursorColor: Colors.white,
            onSaved: (String value) => _username = value,
          )
      )
    );
  }

  Padding buildPasswordTextField() {
    return new Padding(
      padding: EdgeInsets.symmetric(horizontal: 48.0),
      child:  new Container(
        decoration: new BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Color.fromRGBO(255,255,255,0.2)
        ),
        child: new TextFormField(
          onSaved: (String value) => _password = value,
          obscureText: _isObscure,
          validator: (String value) {
            if (value.isEmpty) {
              return '请输入密码';
            }
          },
          decoration: new InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(10.0),
              labelText: '密码',
              labelStyle: new TextStyle(color: Colors.white, fontSize: 20.0),
              suffixIcon: new IconButton(
                  icon: new Icon(
                    Icons.remove_red_eye,
                    color: _defaultIconColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                      _defaultIconColor = _isObscure
                          ? ThemeUtils.currentColorTheme
                          : Colors.white;
                    });
                  }
              )
          ),
          style: new TextStyle(color: Colors.white, fontSize: 20.0),
          cursorColor: Colors.white,
        )
      )
    );
  }

  Column buildLoginButton(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Container(
          child: new FlatButton(
            padding: EdgeInsets.all(16.0),
            color: Color.fromRGBO(255,255,255,0.2),
            highlightColor: Colors.white,
            textColor: Colors.white,
            child: new Icon(
              Icons.send,
              color: Colors.white,
              size: 30
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                //TODO 执行登录方法
                DataUtils.doLogin(context, _username, _password);
              }
            },
            shape: CircleBorder(),
//          shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
        ),
      ]
    );
  }

  Padding buildForgetPasswordText(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.all(0.0),
      child: new Align(
        alignment: Alignment.center,
        child: new FlatButton(
          padding: EdgeInsets.all(0.0),
          child: new Text(
            '忘记密码？',
            style: new TextStyle(fontSize: 14.0, color: Colors.white70),
          ),
          onPressed: () {
            resetPassword();
          },
        ),
      ),
    );
  }

  Align buildRegisterText(BuildContext context) {
    return new Align(
      alignment: Alignment.center,
      child: new Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
                '没有账号？',
                style: new TextStyle(color: Colors.white)
            ),
            new GestureDetector(
              child: new Text(
                '点击注册',
                style: new TextStyle(color: Colors.white, decoration: TextDecoration.underline),
              ),
              onTap: () {
                print('去注册');
//                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> resetPassword() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return PlatformAlertDialog(
          title: new Text('忘记密码'),
          content: SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('找回密码详见'),
                new Text('网络中心主页 -> 集大通行证'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('返回'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            new FlatButton(
              child: new Text('查看'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (context) {
                      return new CommonWebPage(title: "集大通行证登录说明", url: "https://net.jmu.edu.cn/info/1309/2476.htm");
                    }
                ));
              },
            ),
          ],
        );
      },
    );
  }

}