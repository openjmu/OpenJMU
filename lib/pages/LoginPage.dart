import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:OpenJMU/api/Api.dart';
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
    TextEditingController _usernameEditingController = TextEditingController();
    String _username, _password;
    bool _loginButtonDisabled = false;
    bool _isObscure = true;
    bool _usernameCanClear = false;
    Color _defaultIconColor = ThemeUtils.defaultColor;

    @override
    void initState() {
        super.initState();
        DataUtils.resetTheme();
        Constants.eventBus
            ..on<LoginEvent>().listen((event) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => MainPage(initIndex: widget.initIndex)),
                );
            })
            ..on<LoginFailedEvent>().listen((event) {
                setState(() {
                    _loginButtonDisabled = false;
                });
            })
        ;
        _usernameEditingController..addListener(() {
            if (this.mounted) {
                setState(() {
                    if (_usernameEditingController.text.length > 0 && !_usernameCanClear) {
                        _usernameCanClear = true;
                    } else if (_usernameEditingController.text.length == 0 && _usernameCanClear) {
                        _usernameCanClear = false;
                    }
                });
            }
        });
    }

    @override
    void dispose() {
        super.dispose();
        _usernameEditingController?.dispose();
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
                margin: EdgeInsets.only(bottom: Constants.suSetSp(10.0)),
                child: Image.asset(
                    'images/ic_jmu_logo_trans.png',
                    width: Constants.suSetSp(100.0),
                    height: Constants.suSetSp(100.0),
                ),
            ),
        );
    }

    Padding buildTitleLine() {
        return Padding(
            padding: EdgeInsets.all(Constants.suSetSp(4.0)),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    color: ThemeUtils.defaultColor,
                    width: Constants.suSetSp(100.0),
                    height: Constants.suSetSp(2.0),
                ),
            ),
        );
    }

    Padding buildUsernameTextField() {
        return Padding(
            padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(48.0)),
            child: DecoratedBox(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Constants.suSetSp(10.0)),
                    color: Color.fromRGBO(255, 255, 255, 0.2),
                ),
                child: TextFormField(
                    controller: _usernameEditingController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: Constants.suSetSp(24.0),
                        ),
                        suffixIcon: _usernameCanClear ? IconButton(
                            icon: Icon(
                                Icons.clear,
                                color: Colors.white,
                                size: Constants.suSetSp(24.0),
                            ),
                            onPressed: _usernameEditingController.clear,
                        ) : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(Constants.suSetSp(12.0)),
                        labelText: '工号/学号',
                        labelStyle: TextStyle(color: Colors.white, fontSize: Constants.suSetSp(18.0)),
                    ),
                    style: TextStyle(color: Colors.white, fontSize: Constants.suSetSp(18.0)),
                    cursorColor: Colors.white,
                    onSaved: (String value) => _username = value,
                    keyboardType: TextInputType.number,
                ),
            ),
        );
    }

    Padding buildPasswordTextField() {
        return Padding(
            padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(48.0)),
            child: DecoratedBox(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Constants.suSetSp(10.0)),
                    color: Color.fromRGBO(255, 255, 255, 0.2),
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
                        contentPadding: EdgeInsets.all(Constants.suSetSp(10.0)),
                        prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: Constants.suSetSp(24.0),
                        ),
                        labelText: '密码',
                        labelStyle: TextStyle(color: Colors.white, fontSize: Constants.suSetSp(18.0)),
                        suffixIcon: IconButton(
                            icon: Icon(
                                _isObscure
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                color: _defaultIconColor,
                                size: Constants.suSetSp(24.0),
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
                    style: TextStyle(color: Colors.white, fontSize: Constants.suSetSp(20.0)),
                    cursorColor: Colors.white,
                ),
            ),
        );
    }

    Widget buildLoginButton(context) {
        return Container(
            width: Constants.suSetSp(70.0),
            height: Constants.suSetSp(70.0),
            decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.2),
                shape: BoxShape.circle,
            ),
            child: !_loginButtonDisabled
                    ? IconButton(
                highlightColor: Colors.white,
                icon: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: Constants.suSetSp(36.0),
                ),
                onPressed: () {
                    if (_loginButtonDisabled) {
                        return null;
                    } else {
                        loginButtonPressed(context);
                    }
                },
            ) : Padding(
                padding: EdgeInsets.all(Constants.suSetSp(22.0)),
                child: CircularProgressIndicator(
                    strokeWidth: Constants.suSetSp(4.0),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
            ),
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
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: Constants.suSetSp(16.0),
                        ),
                    ),
                    onPressed: resetPassword,
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
                                return CommonWebPage.jump(context, "${Api.homePage}/license.html", "OpenJMU用户协议");
                            },
                    ),
                ],
                style: TextStyle(
                    fontSize: Constants.suSetSp(16.0),
                )
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
                                        SizedBox(height: Constants.suSetSp(100.0)),
                                        buildLogo(),
//                                        buildTitleLine(),
                                        SizedBox(height: Constants.suSetSp(30.0)),
                                        buildUsernameTextField(),
                                        SizedBox(height: Constants.suSetSp(30.0)),
                                        buildPasswordTextField(),
                                        buildForgetPasswordText(context),
                                        SizedBox(height: Constants.suSetSp(10.0)),
                                        buildUserAgreement(context),
                                        SizedBox(height: Constants.suSetSp(20.0)),
                                        buildLoginButton(context),
                                        SizedBox(height: Constants.suSetSp(50.0)),
//                                        buildRegisterText(context),
                                    ],
                                ),
                            ),
                        ],
                    ),
                ),
                resizeToAvoidBottomInset: false,
                resizeToAvoidBottomPadding: false,
            ),
        );
    }

}