import 'dart:io';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/pages/MainPage.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';

class LoginPage extends StatefulWidget {
    final int initIndex;

    LoginPage({this.initIndex, Key key}) : super(key: key);

    @override
    LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {

    final _formKey = GlobalKey<FormState>();
    String _username, _password;
    bool _loginButtonDisabled = false;
    bool _isObscure = true;
    Color _defaultIconColor = ThemeUtils.defaultColor;

    @override
    void initState() {
        super.initState();
        DataUtils.resetTheme();
        Constants.eventBus
            ..on<LoginEvent>().listen((event) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainPage(initIndex: widget.initIndex)));
            })
            ..on<LoginFailedEvent>().listen((event) {
                setState(() {
                    _loginButtonDisabled = false;
                });
            });
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

    Hero buildLogo() {
        return Hero(
            tag: "Logo",
            child: Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: Image.asset(
                    'images/ic_jmu_logo_trans.png',
                    width: 100.0,
                    height: 100.0,
                ),
            ),
        );
    }

    Padding buildTitleLine() {
        return Padding(
            padding: EdgeInsets.all(4.0),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    color: ThemeUtils.defaultColor,
                    width: 100.0,
                    height: 2.0,
                ),
            ),
        );
    }

    Padding buildUsernameTextField() {
        return Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.0),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Color.fromRGBO(255, 255, 255, 0.2),
                ),
                child: TextFormField(
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                            Platform.isAndroid ? Icons.person : Ionicons.getIconData("ios-person"),
                            color: Colors.white,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10.0),
                        labelText: '工号/学号',
                        labelStyle: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                    cursorColor: Colors.white,
                    onSaved: (String value) => _username = value,
                    keyboardType: TextInputType.number,
                ),
            ),
        );
    }

    Padding buildPasswordTextField() {
        return Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.0),
            child:  Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Color.fromRGBO(255,255,255,0.2),
                ),
                child: TextFormField(
                    onFieldSubmitted: (value) {
                        if (_loginButtonDisabled) {
                            return null;
                        } else {
                            loginButtonPressed(context);
                        }
                    },
                    onSaved: (String value) => _password = value,
                    obscureText: _isObscure,
                    validator: (String value) {
                        if (value.isEmpty) return '请输入密码';
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10.0),
                        prefixIcon: Icon(
                            Platform.isAndroid ? Icons.lock : Ionicons.getIconData("ios-lock"),
                            color: Colors.white,
                        ),
                        labelText: '密码',
                        labelStyle: TextStyle(color: Colors.white, fontSize: 18.0),
                        suffixIcon: IconButton(
                            icon: Icon(
                                _isObscure
                                        ? Platform.isAndroid ? Icons.visibility : Ionicons.getIconData("ios-eye")
                                        : Platform.isAndroid ? Icons.visibility_off : Ionicons.getIconData("ios-eye-off"),
                                color: _defaultIconColor,
                            ),
                            onPressed: () {
                                setState(() {
                                    _isObscure = !_isObscure;
                                    _defaultIconColor = _isObscure
                                            ? ThemeUtils.defaultColor
                                            : Colors.white;
                                });
                            },
                        ),
                    ),
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                    cursorColor: Colors.white,
                ),
            ),
        );
    }

    Column buildLoginButton(context) {
        return Column(
            children: <Widget>[
                !_loginButtonDisabled
                        ? Container(
                    padding: EdgeInsets.all(8.0),
                    child: IconButton(
                        highlightColor: Colors.white,
                        icon: Icon(
                            Platform.isAndroid ? Icons.arrow_forward : FontAwesome.getIconData("arrow-right"),
                            color: Colors.white,
                            size: 30,
                        ),
                        onPressed: () {
                            if (_loginButtonDisabled) {
                                return null;
                            } else {
                                loginButtonPressed(context);
                            }
                        },
                    ),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(255,255,255,0.2),
                        shape: BoxShape.circle,
                    ),
                )
                        : Container(
                    padding: EdgeInsets.all(20.0),
                    child: SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: CircularProgressIndicator(
                            strokeWidth: 3.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                    ),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(255,255,255,0.2),
                        shape: BoxShape.circle,
                    ),
                ),
            ],
        );
    }

    Padding buildForgetPasswordText(BuildContext context) {
        return Padding(
            padding: EdgeInsets.all(0.0),
            child: Align(
                alignment: Alignment.center,
                child: FlatButton(
                    padding: EdgeInsets.all(0.0),
                    child: Text(
                        '忘记密码？',
                        style: TextStyle(color: Colors.white70),
                    ),
                    onPressed: () {
                        resetPassword();
                    },
                ),
            ),
        );
    }

    RichText buildUserAgreement(context) {
        return RichText(
            text: TextSpan(
                children: <TextSpan>[
                    TextSpan(text: "登录即表明同意", style: TextStyle(color: Colors.white70)),
                    TextSpan(
                        text: "用户协议",
                        style: TextStyle(color: Colors.lightBlueAccent),
                        recognizer: TapGestureRecognizer()
                            ..onTap = () {
                                return CommonWebPage.jump(context, "https://openjmu.xyz/license.html", "OpenJMU用户协议");
                            },
                    ),
                ],
            ),
        );
    }

//    Align buildRegisterText(BuildContext context) {
//        return Align(
//            alignment: Alignment.center,
//            child: Padding(
//                padding: EdgeInsets.only(top: 10.0),
//                child: Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                        Text(
//                            '没有账号？',
//                            style: TextStyle(color: Colors.white),
//                        ),
//                        GestureDetector(
//                            child: Text(
//                                '点击注册',
//                                style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
//                            ),
//                            onTap: () {
//                                print('去注册');
////                                Navigator.pop(context);
//                            },
//                        ),
//                    ],
//                ),
//            ),
//        );
//    }

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

    void resetPassword() async {
        return showPlatformDialog<Null>(
            context: context,
            builder: (BuildContext dialogContext) {
                return PlatformAlertDialog(
                    title: Text('忘记密码'),
                    content: SingleChildScrollView(
                        child: ListBody(
                            children: <Widget>[
                                Text('找回密码详见'),
                                Text('网络中心主页 -> 集大通行证'),
                            ],
                        ),
                    ),
                    actions: <Widget>[
                        FlatButton(
                            child: Text('返回'),
                            onPressed: () {
                                Navigator.of(dialogContext).pop();
                            },
                        ),
                        FlatButton(
                            child: Text('查看'),
                            onPressed: () {
                                Navigator.of(dialogContext).pop();
                                return CommonWebPage.jump(
                                    context,
                                    "https://net.jmu.edu.cn/info/1309/2476.htm",
                                    "集大通行证登录说明",
                                    withCookie: false,
                                );
                            },
                        ),
                    ],
                );
            },
        );
    }

    @override
    Widget build(BuildContext context) {
        return WillPopScope(
            onWillPop: doubleBackExit,
            child: Scaffold(
                body: Builder(
                    builder: (context) => Stack(
                        children: <Widget>[
                            Container(
                                decoration: BoxDecoration(
                                    color: ThemeUtils.defaultColor,
                                ),
                            ),
                            Form(
                                key: _formKey,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                        SizedBox(height: 100.0),
                                        buildLogo(),
//                                        buildTitleLine(),
                                        SizedBox(height: 30.0),
                                        buildUsernameTextField(),
                                        SizedBox(height: 30.0),
                                        buildPasswordTextField(),
                                        buildForgetPasswordText(context),
                                        SizedBox(height: 10.0),
                                        buildUserAgreement(context),
                                        SizedBox(height: 20.0),
                                        buildLoginButton(context),
                                        SizedBox(height: 50.0),
//                                        buildRegisterText(context),
                                    ],
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }

}