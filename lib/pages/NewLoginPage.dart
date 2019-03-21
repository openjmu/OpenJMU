import 'package:flutter/material.dart';
import '../constants/Constants.dart';
import '../events/LoginEvent.dart';
import '../utils/DataUtils.dart';
import '../utils/ThemeUtils.dart';

class NewLoginPage extends StatefulWidget {
  @override
  NewLoginPageState createState() => NewLoginPageState();
}

class NewLoginPageState extends State<NewLoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username, _password;
  bool _isObscure = true;
  Color _defaultIconColor = Colors.grey;
  bool isUserLogin;

  @override
  void initState() {
    super.initState();
    DataUtils.isLogin().then((isLogin) {
      setState(() {
        this.isUserLogin = isLogin;
      });
    });
    Constants.eventBus.on<LoginEvent>().listen((event) {
      setState(() {
        this.isUserLogin = true;
      });
    });
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
                            Colors.pink
                          ],
                        ),
                      )
                  ),
                  new Form(
                      key: _formKey,
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: 50.0),
                        children: <Widget>[
                          SizedBox(
                            height: kToolbarHeight,
                          ),
                          SizedBox(height: 30.0),
                          buildTitle(),
                          //                      buildTitleLine(),
                          SizedBox(height: 60.0),
                          buildUsernameTextField(),
                          SizedBox(height: 30.0),
                          buildPasswordTextField(),
                          buildForgetPasswordText(context),
                          SizedBox(height: 30.0),
                          buildLoginButton(context),
                          SizedBox(height: 30.0),
//                          buildRegisterText(context),
                        ],
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
        child: Image.asset(
          './images/ic_jmu_logo.png',
          width: 100.0,
          height: 100.0,
        )
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

  Container buildUsernameTextField() {
    return new Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Color.fromRGBO(255,255,255,0.2)
        ),
        child: new TextFormField(
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(10.0),
            labelText: '用户名/工号/学号',
            labelStyle: new TextStyle(color: Colors.white),
          ),
          style: new TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          onSaved: (String value) => _username = value,
        )
    );
  }

  Container buildPasswordTextField() {
    return new Container(
        decoration: BoxDecoration(
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
          decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(10.0),
              labelText: '密码',
              labelStyle: new TextStyle(color: Colors.white),
              suffixIcon: IconButton(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: _defaultIconColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                      _defaultIconColor = _isObscure
                          ? Colors.grey
                          : Colors.white;
                    });
                  }
              )
          ),
          style: new TextStyle(color: Colors.white),
          cursorColor: Colors.white,
        )
    );
  }

  Column buildLoginButton(BuildContext context) {
    return Column(
      children: <Widget>[
        FlatButton(
          child: Icon(
            Icons.done,
            color: Colors.white,
          ),
          color: Color.fromRGBO(255,255,255,0.2),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              ///只有输入的内容符合要求通过才会到达此处
              _formKey.currentState.save();
              //TODO 执行登录方法
              DataUtils.doLogin(context, _username, _password);
            }
          },
          shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ]
    );
  }

  Padding buildForgetPasswordText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: FlatButton(
          padding: EdgeInsets.all(0.0),
          child: Text(
            '忘记密码',
            style: TextStyle(fontSize: 14.0, color: Colors.white70),
          ),
          onPressed: () {
//            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Align buildRegisterText(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
                '没有账号？',
                style: new TextStyle(color: Colors.white)
            ),
            GestureDetector(
              child: Text(
                '点击注册',
                style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
              ),
              onTap: () {
                //TODO 跳转到注册页面
                print('去注册');
//                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}