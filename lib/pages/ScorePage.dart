import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart' hide Element;
import 'package:flutter/cupertino.dart' hide Element;
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' show Document, Element;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:OpenJMU/api/API.dart';
//import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';


class ScorePage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController checkCodeController = TextEditingController();
    final FocusNode focusNode = FocusNode();

    Database database;
    Batch batch;

    Image content;
    String viewState;
    List<String> terms = [];
    List<Map<String, dynamic>> scores = [];
    bool scoreUpdated = false;

    String score;

    @override
    void initState() {
        super.initState();
        preLogin();
//        initializeDatabase();
    }

    @override
    void dispose() {
        super.dispose();
        checkCodeController?.dispose();
    }

    Future initializeDatabase() async {
        String databasesPath = await getDatabasesPath();
        print(databasesPath);
        String path = join(databasesPath, 'score.db');
        print(path);
        print(await databaseExists(path));
        await deleteDatabase(path);
        database = await openDatabase(path, version: 1,
            onCreate: (Database db, int version) async {
                await db.execute('CREATE TABLE STUDENT('
                        'STUDENT_CODE VARCHAR(255) PRIMARY KEY NOT NULL,'
                        'STUDENT_NAME VARCHAR(255) NOT NULL,'
                        'STUDENT_TERMS VARCHAR(255) NOT NULL'
                        ')');
                await db.execute('CREATE TABLE TERM ('
                        'ID INTEGER PRIMARY KEY NOT NULL,'
                        'TERM_CODE MEDIUMINT NOT NULL,'
                        'TERM_NAME VARCHAR(255) NOT NULL'
                        ')');
                await db.execute('CREATE TABLE COURSE ('
                        'ID INTEGER PRIMARY KEY NOT NULL,'
                        'TERM_CODE MEDIUMINT NOT NULL,'
                        'COURSE_CODE VARCHAR(255) NOT NULL,'
                        'COURSE_DURATION SMALLINT NOT NULL,'
                        'COURSE_NAME VARCHAR(255) NOT NULL,'
                        'COURSE_POINT DOUBLE NOT NULL,'
                        'COURSE_TYPE VARCHAR(255) NOT NULL'
                        ')');
                await db.execute('CREATE TABLE SCORE ('
                        'ID INTEGER PRIMARY KEY NOT NULL,'
                        'COURSE_CODE VARCHAR(255) NOT NULL,'
                        'SCORE DOUBLE NOT NULL,'
                        'GRADE_POINT DOUBLE NOT NULL,'
                        'EXAM_STATUS VARCHAR(255) NOT NULL,'
                        'EXAM_TYPE VARCHAR(255) NOT NULL'
                        ')');
            },
        );
        batch = database.batch();
    }

    Future<Null> closeDatabases(Database db) async {
        await db.close();
    }

    Future<Null> insertColumn(String table, Map<String, dynamic> column) async {
        batch.insert(table, column);
        var results = await batch.commit();
        print(results);
    }

    Future<List<Map<String, dynamic>>> showTable(String table) async {
        return await database.query(table);
    }

    Future preLogin() async {
        List<int> checkCode = (await NetUtils.getBytes(Api.jwglCheckCode)).data;
        setState(() {
            content = Image.memory(Uint8List.fromList(checkCode));
        });
        UserAPI.cookiesForJWGL = NetUtils.cookieJar.loadForRequest(
            Uri.parse(Api.jwglCheckCode),
        );

        Document loginPage = parse((await NetUtils.get(
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
                    'TxtUserName': '${UserAPI.currentUser.workId}',
                    'TxtPassword': passwordController.text,
                    'TxtVerifCode': captcha,
                    'BtnLoginImage.x': '0',
                    'BtnLoginImage.y': '0'
                },
                options: Options(
                    cookies: UserAPI.cookiesForJWGL,
                    headers: {
                        'Referer': '${Api.jwglHost}/',
                        'Origin': Api.jwglHost,
                    },
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
        Document preScorePage = parse((await NetUtils.get(
            Api.jwglStudentScoreAll,
        )).data);
        getTerms(preScorePage);
        viewState = preScorePage.getElementById("__VIEWSTATE").attributes["value"];

        Document scorePage = parse((await NetUtils.dio.post(
            Api.jwglStudentScoreAll,
            data: {
                '__VIEWSTATE': viewState,
                '__EVENTTARGET': 'ctl00\$ContentPlaceHolder1\$pageNumber',
                '__EVENTARGUMENT': '',
                'ctl00\$ContentPlaceHolder1\$semesterList': '',
                'ctl00\$ContentPlaceHolder1\$pageNumber': '200',
            },
            options: Options(
                cookies: UserAPI.cookiesForJWGL,
                headers: {
                    'Referer': '${Api.jwglStudentScoreAll}',
                    'Origin': Api.jwglHost,
                },
                contentType: ContentType.parse("application/x-www-form-urlencoded"),
                followRedirects: true,
            ),
        )).data.toString());
        scores.clear();
        List<Element> scoreRow = scorePage.getElementById("ctl00_ContentPlaceHolder1_scoreList").children[0].children;
        scoreRow.forEach((row) {
            if (row.children[0].text != "学期") {
                Map<String, dynamic> score = {
                    'term'       : row.children[0].text,
                    'courseCode' : row.children[1].text,
                    'courseName' : row.children[2].text,
                    'courseTime' : row.children[3].text,
                    'coursePoint': row.children[4].text,
                    'courseType' : row.children[5].text,
                    'examType'   : row.children[6].text,
                    'examStatus' : row.children[7].text,
                    'examScore'  : row.children[8].text,
                    'examPoint'  : row.children[9].text,
                };
                scores.add(score);
            }
        });
        setState(() {
            scoreUpdated = true;
        });
    }

    Future loginFailed() async {
        showShortToast("登录失败");
        await preLogin();
    }

    void getTerms(Document page) {
        terms.clear();
        List<Element> termsElements = page.getElementById("ctl00_ContentPlaceHolder1_semesterList").children;
        termsElements.forEach((element) {
            terms.add(element.attributes['value']);
        });
        print(terms.join(',').substring(1));
    }


    @override
    Widget build(BuildContext context) {
        return Scaffold(
//            appBar: AppBar(
//                leading: IconButton(
//                    onPressed: () async {
//                        await closeDatabases(database);
//                        Navigator.pop(context);
//                    },
//                    icon: Icon(Icons.arrow_back),
//                ),
//                title: Text(
//                    "测试标题",
//                    style: Theme.of(context).textTheme.title.copyWith(
//                        fontSize: Constants.suSetSp(21.0),
//                    ),
//                ),
//                centerTitle: true,
//            ),
            body: SafeArea(
                top: true,
                child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
//                        Column(
//                            mainAxisSize: MainAxisSize.min,
//                            children: <Widget>[
//                                FlatButton(
//                                    onPressed: () async {
//                                        await insertColumn('STUDENT', {
//                                            'STUDENT_CODE': UserUtils.currentUser.workId,
//                                            'STUDENT_NAME': UserUtils.currentUser.name,
//                                            'STUDENT_TERMS': "20151,20152"
//                                        });
//                                    },
//                                    child: Text("Insert your information."),
//                                ),
//                                FlatButton(
//                                    onPressed: () async {
//                                        print(await showTable('STUDENT'));
//                                    },
//                                    child: Text("Show table."),
//                                ),
//                                FlatButton(
//                                    onPressed: () async {
//                                        print((await database.query(
//                                            "STUDENT",
//                                            where: 'STUDENT_CODE = ${UserUtils.currentUser.workId}',
//                                        )).isNotEmpty);
//                                    },
//                                    child: Text("Check if current user's row exist."),
//                                ),
//                            ],
//                        ),
                        content != null ? content : Container(),
                        TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                                prefixText: "密码",
                            ),
                            obscureText: true,
                        ),
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
                        if (scoreUpdated) ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: scores.length,
                            itemBuilder: (context, index) {
                                return ListTile(
                                    leading: Text(scores[index]['courseName']),
                                    title: Text(scores[index]['examScore']),
                                    subtitle: Text(scores[index]['examPoint']),
                                );
                            },
                        ),
                    ],
                ),
            ),
        );
    }
}
