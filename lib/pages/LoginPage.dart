import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/pages/MainPage.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:OpenJMU/widgets/RoundedCheckBox.dart';
import 'package:OpenJMU/widgets/dialogs/AnnouncementDialog.dart';


class LoginPage extends StatefulWidget {
    final int initIndex;

    LoginPage({this.initIndex, Key key}) : super(key: key);

    @override
    LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final ScrollController _formScrollController = ScrollController();
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    String _username = "", _password = "";

    bool _agreement = false;
    bool _login = false;
    bool _loginDisabled = true;
    bool _isObscure = true;
    bool _usernameCanClear = false;

    Color _defaultIconColor = ThemeUtils.defaultColor;

    bool showAnnouncement = false;
    List announcements = [];

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
                if (mounted) setState(() {
                    _login = false;
                });
            })
        ;
        _usernameController..addListener(() {
            if (this.mounted) {
                _username = _usernameController.text;
                if (_usernameController.text.length > 0 && !_usernameCanClear) {
                    setState(() {
                        _usernameCanClear = true;
                    });
                } else if (_usernameController.text.length == 0 && _usernameCanClear) {
                    setState(() {
                        _usernameCanClear = false;
                    });
                }
            }
        });
        _passwordController..addListener(() {
            if (this.mounted) {
                _password = _passwordController.text;
            }
        });
        getAnnouncement();
    }

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        ThemeUtils.setDark(true);
    }

    @override
    void dispose() {
        super.dispose();
        _usernameController?.dispose();
        _passwordController?.dispose();
    }

    void getAnnouncement() async {
        Map<String, dynamic> data = jsonDecode((await NetUtils.get(API.announcement)).data);
        if (data['enabled']) {
            showAnnouncement = data['enabled'];
            announcements = data['announcements'];
        }
        if (this.mounted) setState((){});
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

    Widget logo() {
        return Column(
            children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(bottom: Constants.suSetSp(10.0)),
                            child: Hero(
                            tag: "Logo",
                            child: Image.asset(
                                    'images/ic_jmu_logo_trans.png',
                                    color: Colors.white,
                                    width: Constants.suSetSp(80.0),
                                    height: Constants.suSetSp(80.0),
                                ),
                            ),
                        ),
                    ],
                ),
                Constants.emptyDivider(height: Constants.suSetSp(40.0)),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                        Text(
                            "OPENJMU",
                            style: TextStyle(
                                color: Colors.grey[850],
                                fontSize: Constants.suSetSp(50.0),
                                fontFamily: "chocolate",
                            ),
                        ),
                    ],
                ),
            ],
        );
    }

    Widget announcement() {
        return GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Container(
                margin: EdgeInsets.symmetric(
                    vertical: Constants.suSetSp(5.0),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: Constants.suSetSp(15.0),
                    vertical: Constants.suSetSp(10.0),
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Constants.suSetSp(5.0)),
                    color: ThemeUtils.defaultColor.withAlpha(0x44),
                ),
                child: Row(
                    children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(right: Constants.suSetSp(6.0)),
                            child: Icon(
                                Icons.error_outline,
                                size: Constants.suSetSp(18.0),
                                color: ThemeUtils.currentThemeColor,
                            ),
                        ),
                        Expanded(child: Text(
                            "${announcements[0]['title']}",
                            style: TextStyle(
                                color: ThemeUtils.currentThemeColor,
                                fontSize: Constants.suSetSp(18.0),
                            ),
                            overflow: TextOverflow.ellipsis,
                        )),
                        Padding(
                            padding: EdgeInsets.only(left: Constants.suSetSp(6.0)),
                            child: Icon(
                                Icons.keyboard_arrow_right,
                                size: Constants.suSetSp(18.0),
                                color: ThemeUtils.currentThemeColor,
                            ),
                        ),
                    ],
                ),
            ),
            onTap: () {
                showDialog<Null>(
                    context: context,
                    builder: (BuildContext context) => AnnouncementDialog(announcements[0]),
                );
            },
        );
    }

    Widget usernameTextField() {
        return TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
                prefixIcon: Icon(
                    Icons.person,
                    color: Colors.black,
                    size: Constants.suSetSp(24.0),
                ),
                suffixIcon: _usernameCanClear ? IconButton(
                    icon: Icon(
                        Icons.clear,
                        color: Colors.black,
                        size: Constants.suSetSp(24.0),
                    ),
                    onPressed: _usernameController.clear,
                ) : null,
                border: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black,
                    ),
                ),
                contentPadding: EdgeInsets.all(Constants.suSetSp(12.0)),
                labelText: '工号/学号',
                labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: Constants.suSetSp(18.0),
                ),
            ),
            style: TextStyle(
                color: Colors.black,
                fontSize: Constants.suSetSp(18.0),
            ),
            cursorColor: Colors.black,
            onSaved: (String value) => _username = value,
            validator: (String value) {
                if (value.isEmpty) return '请输入账户';
            },
            keyboardType: TextInputType.number,
        );
    }

    Widget passwordTextField() {
        return TextFormField(
            controller: _passwordController,
            onSaved: (String value) => _password = value,
            obscureText: _isObscure,
            validator: (String value) {
                if (value.isEmpty) return '请输入密码';
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black,
                    ),
                ),
                contentPadding: EdgeInsets.all(Constants.suSetSp(10.0)),
                prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.black,
                    size: Constants.suSetSp(24.0),
                ),
                labelText: '密码',
                labelStyle: TextStyle(color: Colors.black, fontSize: Constants.suSetSp(18.0)),
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
                                    ? Colors.black
                                    : ThemeUtils.defaultColor;
                        });
                    },
                ),
            ),
            style: TextStyle(color: Colors.black, fontSize: Constants.suSetSp(20.0)),
            cursorColor: Colors.black,
        );
    }

    Padding noAccountButton(BuildContext context) {
        return Padding(
            padding: EdgeInsets.zero,
            child: Align(
                alignment: Alignment.center,
                child: FlatButton(
                    padding: EdgeInsets.all(0.0),
                    child: Text(
                        '没有账号？',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: Constants.suSetSp(16.0),
                        ),
                    ),
                    onPressed: () {},
                ),
            ),
        );
    }

    Padding forgetPasswordButton(BuildContext context) {
        return Padding(
            padding: EdgeInsets.zero,
            child: Align(
                alignment: Alignment.center,
                child: FlatButton(
                    padding: EdgeInsets.all(0.0),
                    child: Text(
                        '忘记密码？',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: Constants.suSetSp(16.0),
                        ),
                    ),
                    onPressed: resetPassword,
                ),
            ),
        );
    }

    Widget userAgreementCheckbox(context) {
        return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                RoundedCheckbox(
                    value: _agreement,
                    inactiveColor: Colors.black,
                    onChanged: (value) {
                        setState(() {
                            _agreement = value;
                        });
                        validateForm();
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                RichText(
                    text: TextSpan(
                        children: <TextSpan>[
                            TextSpan(text: "登录即表明同意", style: TextStyle(color: Colors.black)),
                            TextSpan(
                                text: "用户协议",
                                style: TextStyle(color: Colors.redAccent),
                                recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                        return CommonWebPage.jump(
                                            context,
                                            "${API.homePage}/license.html",
                                            "OpenJMU用户协议",
                                        );
                                    },
                            ),
                        ],
                        style: TextStyle(fontSize: Constants.suSetSp(15.0)),
                    ),
                ),
            ],
        );
    }

    Widget loginButton(context) {
        return GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Container(
                width: Constants.suSetSp(120.0),
                height: Constants.suSetSp(50.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Constants.suSetSp(6.0)),
                    boxShadow: <BoxShadow>[
                        BoxShadow(
                            blurRadius: Constants.suSetSp(10.0),
                            color: Color(0xffea1f1f).withAlpha(50),
                            offset: Offset(0.0, Constants.suSetSp(10.0)),
                        )
                    ],
                    gradient: LinearGradient(colors: <Color>[
                        Color(0xfff68184), Color(0xffea1f1f),
                    ]),
                ),
                child: Center(
                    child: !_login ? SizedBox(
                        height: Constants.suSetSp(20.0) * 1.2,
                        child: Text(
                            "登录",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: Constants.suSetSp(20.0),
                            ),
                        ),
                    ) : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            SizedBox(
                                width: Constants.suSetSp(24.0),
                                height: Constants.suSetSp(24.0),
                                child: Constants.progressIndicator(color: Colors.white),
                            ),
                        ],
                    ),
                ),
            ),
            onTap: () {
                if (_login || _loginDisabled) {
                    return null;
                } else {
                    loginButtonPressed(context);
                }
            },
        );
    }

    Widget loginForm(context) => Form(
        key: _formKey,
        child: ScrollConfiguration(
            behavior: NoGlowScrollBehavior(),
            child: ListView(
                controller: _formScrollController,
                padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(50.0)),
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                    Constants.emptyDivider(height: Constants.suSetSp(80.0)),
                    logo(),
                    Constants.emptyDivider(height: Constants.suSetSp(40.0)),
                    Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Constants.suSetSp(10.0),
                            vertical: Constants.suSetSp(10.0),
                        ),
                        decoration: BoxDecoration(
                            boxShadow: <BoxShadow>[
                                BoxShadow(
                                    blurRadius: 20.0,
                                    color: Theme.of(context).dividerColor,
                                )
                            ],
                            color: Theme.of(context).cardColor,
                        ),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                                if (showAnnouncement) announcement(),
                                usernameTextField(),
                                Constants.emptyDivider(height: Constants.suSetSp(10.0)),
                                passwordTextField(),
                                Constants.emptyDivider(height: Constants.suSetSp(10.0)),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                        noAccountButton(context),
                                        forgetPasswordButton(context),
                                    ],
                                ),
                            ],
                        ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: Constants.suSetSp(20.0)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                                userAgreementCheckbox(context),
                                loginButton(context),
                            ],
                        ),
                    ),
                    Constants.emptyDivider(height: Constants.suSetSp(30.0)),
                ],
            ),
        ),
        onChanged: validateForm,
    );

    void loginButtonPressed(context) {
        if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            setState(() {
                _login = true;
            });
            DataUtils.doLogin(context, _username, _password).catchError((e) {
                setState(() {
                    _login = false;
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

    void validateForm() {
        if (_username != "" && _password != "" && _agreement && _loginDisabled) {
            setState(() {
                _loginDisabled = false;
            });
        } else if (_username == "" || _password == "" || !_agreement) {
            setState(() {
                _loginDisabled = true;
            });
        }
    }

    void tryScrollForm(context) {
        bool keyboardAppearing;
        double bottom = MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom;
        if (MediaQuery.of(context).viewInsets.bottom != 0.0) {
            keyboardAppearing = true;
        } else {
            keyboardAppearing = false;
        }
        if (_formScrollController.hasClients && keyboardAppearing) {
            _formScrollController.animateTo(
                bottom,
                duration: Duration(milliseconds: 200),
                curve: Curves.linear,
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        tryScrollForm(context);
        return WillPopScope(
            onWillPop: doubleBackExit,
            child: Scaffold(
                backgroundColor: Colors.white,
                body: Stack(
                    children: <Widget>[
                        Positioned(
                            right: 0.0,
                            top: 0.0,
                            child: Image.asset(
                                "images/login_top.png",
                                width: MediaQuery.of(context).size.width - Constants.suSetSp(60.0),
                                fit: BoxFit.fitWidth,
                            ),
                        ),
                        loginForm(context),
                    ],
                ),
                resizeToAvoidBottomInset: true,
            ),
        );
    }

}