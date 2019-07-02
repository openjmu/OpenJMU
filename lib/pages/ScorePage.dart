import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' show Document;

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/UserUTils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';


class ScorePage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
    final TextEditingController checkCodeController = TextEditingController();
    final FocusNode focusNode = FocusNode();

    Image content;
    String viewState;
    Map<String, dynamic> headers = {
        'Referer': '${Api.jwglHost}/',
        'Origin': Api.jwglHost,
    };

    String score;

    @override
    void initState() {
        super.initState();
        preLogin();
    }

    @override
    void dispose() {
        super.dispose();
        checkCodeController?.dispose();
    }

    Future preLogin() async {
        List<int> checkCode = (await NetUtils.getBytes(Api.jwglCheckCode)).data;
        setState(() {
            content = Image.memory(Uint8List.fromList(checkCode));
        });
        UserUtils.cookiesForJWGL = NetUtils.cookieJar.loadForRequest(
            Uri.parse(Api.jwglCheckCode),
        );

        Document loginPage = parse((await NetUtils.getWithCookieSet(
            Api.jwglLogin,
        )).data.toString());
        viewState = loginPage.getElementById("__VIEWSTATE").attributes["value"];
    }

    Future tryLogin(String captcha) async {
        try {
            await NetUtils.dio.post(
                Api.jwglLogin,
                data: {
                    '__VIEWSTATE': viewState,
                    'TxtUserName': "201521033021",
                    'TxtPassword': "DoMyOwn525#lcj",
                    'TxtVerifCode': captcha,
                    'BtnLoginImage.x': '0',
                    'BtnLoginImage.y': '0'
                },
                options: Options(
                    cookies: UserUtils.cookiesForJWGL,
                    headers: headers,
                    contentType: ContentType.parse("application/x-www-form-urlencoded"),
                    followRedirects: true,
                ),
            );
            loginFailed();
        } on DioError catch (e) {
            e.response.statusCode == 302 ? await loginSuccess() : await loginFailed();
        }
    }

    Future loginSuccess() async {
        showShortToast("登录成功");
        Document scorePage = parse((await NetUtils.getWithCookieSet(
            Api.jwglStudentScoreAll,
        )).data.toString());
        setState(() {
            score = scorePage.getElementById("ctl00_ContentPlaceHolder1_scoreList").text;
        });
    }

    Future loginFailed() async {
        showShortToast("登录失败");
        await preLogin();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: SafeArea(
                top: true,
                child: SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                            content != null ? content : Container(),
                            TextField(
                                controller: checkCodeController,
                                focusNode: focusNode,
                            ),
                            FlatButton(
                                onPressed: () async {
                                    focusNode.unfocus();
                                    await tryLogin(checkCodeController.text);
                                },
                                child: Text("Login"),
                            ),
                            if (score != null) Text(score),
                        ],
                    ),
                ),
            ),
        );
    }
}
