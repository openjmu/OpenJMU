import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
//  Animation<double> _animation;
  AnimationController _animationController;

  final _formKey = GlobalKey<FormState>();
  String _username, _password;
  bool _loginButtonDisabled = false;
  bool _isObscure = true;
  Color _defaultIconColor = ThemeUtils.defaultColor;

  @override
  void initState() {
    super.initState();
    DataUtils.resetTheme();
//    _animationController =
//        AnimationController(duration: const Duration(seconds: 1), vsync: this);
//    _animation = Tween<double>(begin: 120, end: 100).animate(_animationController)
//      ..addListener(() {
//        setState(() {
//        });
//      });
//    _animationController.forward();
//    Constants.eventBus.on<LoginFailedEvent>().listen((event) {
//      if (this.mounted) {
//        setState(() {
//          _loginButtonDisabled = false;
//        });
//      }
//    });
    Constants.eventBus.on<LoginFailedEvent>().listen((event) {
      setState(() {
        _loginButtonDisabled = false;
      });
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  int last = 0;
  Future<bool> doubleBackExit() {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - last > 800) {
      showShortToast("再按一次退出应用");
      last = DateTime.now().millisecondsSinceEpoch;
      return Future.value(false);
    } else {
      cancelToast();
      return Future.value(true);
    }
  }

  Container buildLogo() {
    return new Container(
      margin: EdgeInsets.only(bottom: 8.0),
        child: new Image.asset(
          './images/ic_jmu_logo_trans.png',
//          width: _animation.value,
//          height: _animation.value,
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
                prefixIcon: Icon(Icons.person, color: Colors.white),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10.0),
                labelText: '工号/学号',
                labelStyle: new TextStyle(color: Colors.white, fontSize: 18.0),
              ),
              style: new TextStyle(color: Colors.white, fontSize: 18.0),
              cursorColor: Colors.white,
              onSaved: (String value) => _username = value,
              keyboardType: TextInputType.number,
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
                  prefixIcon: Icon(Icons.lock, color: Colors.white),
                  labelText: '密码',
                  labelStyle: new TextStyle(color: Colors.white, fontSize: 18.0),
                  suffixIcon: new IconButton(
                      icon: new Icon(
                        Icons.remove_red_eye,
                        color: _defaultIconColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                          _defaultIconColor = _isObscure
                              ? ThemeUtils.defaultColor
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

  Column buildLoginButton(context) {
    return new Column(
        children: <Widget>[
          !_loginButtonDisabled
          ? new Container(
              padding: EdgeInsets.all(8.0),
              child: new IconButton(
                highlightColor: Colors.white,
                icon: new Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 30
                ),
                onPressed: () {
                  if (_loginButtonDisabled) {
                    return null;
                  } else {
                    loginButtonPressed(context);
                  }
                },
            ),
            decoration: new BoxDecoration(
                color: Color.fromRGBO(255,255,255,0.2),
                shape: BoxShape.circle
            )
          )
          : new Container(
              padding: EdgeInsets.all(20.0),
              child: new SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: new CircularProgressIndicator(
                      strokeWidth: 3.0,
                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)
                  )
              ),
              decoration: new BoxDecoration(
                  color: Color.fromRGBO(255,255,255,0.2),
                  shape: BoxShape.circle
              )
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

//  Align buildRegisterText(BuildContext context) {
//    return new Align(
//      alignment: Alignment.center,
//      child: new Padding(
//        padding: EdgeInsets.only(top: 10.0),
//        child: new Row(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            new Text(
//                '没有账号？',
//                style: new TextStyle(color: Colors.white)
//            ),
//            new GestureDetector(
//              child: new Text(
//                '点击注册',
//                style: new TextStyle(color: Colors.white, decoration: TextDecoration.underline),
//              ),
//              onTap: () {
//                print('去注册');
////                Navigator.pop(context);
//              },
//            ),
//          ],
//        ),
//      ),
//    );
//  }

  void loginButtonPressed(context) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _loginButtonDisabled = true;
      });
      DataUtils.doLogin(context, _username, _password).catchError((e) {
        setState(() {
          _loginButtonDisabled = false;
        });
      });
    }
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
                return CommonWebPage.jump(context, "https://net.jmu.edu.cn/info/1309/2476.htm", "集大通行证登录说明");
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: doubleBackExit,
        child: new Scaffold(
            body: Builder(
                builder: (context) =>
                new Stack(
                    children: <Widget>[
                      new Container(
                        decoration: BoxDecoration(
                            color: ThemeUtils.defaultColor
                        ),
                      ),
                      new Form(
                          key: _formKey,
                          child: new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                buildLogo(),
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
        )
    );
  }

}