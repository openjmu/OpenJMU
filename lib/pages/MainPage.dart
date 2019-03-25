import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/Constants.dart';
import '../events/ChangeThemeEvent.dart';
import '../events/LoginEvent.dart';
import '../events/LogoutEvent.dart';
import '../utils/DataUtils.dart';
import '../utils/ThemeUtils.dart';
import '../utils/ToastUtils.dart';
import 'NewLoginPage.dart';
import 'NewsListPage.dart';
import 'WeiboListPage.dart';
import 'DiscoveryPage.dart';
import 'MyInfoPage.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MainPageState();
}

class MainPageState extends State<MainPage> {
  final appBarTitles = ['首页', '新闻', '消息', '我的'];
  TextStyle tabTextStyleSelected = new TextStyle(color: ThemeUtils.currentColorTheme);
  final tabTextStyleNormal = new TextStyle(color: Colors.grey);

  Color themeColor = ThemeUtils.currentColorTheme;
  int _tabIndex = 0;

  var _body;
  var pages;

  bool isUserLogin = false;

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
    Constants.eventBus.on<LogoutEvent>().listen((event) {
      setState(() {
        this.isUserLogin = false;
      });
      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) {
        return new NewLoginPage();
      },));
    });
    DataUtils.getColorThemeIndex().then((index) {
      print('color theme index = $index');
      if (index != null) {
        ThemeUtils.currentColorTheme = ThemeUtils.supportColors[index];
        Constants.eventBus.fire(new ChangeThemeEvent(ThemeUtils.supportColors[index]));
      }
    });
    Constants.eventBus.on<ChangeThemeEvent>().listen((event) {
      setState(() {
        tabTextStyleSelected = new TextStyle(color: event.color);
        themeColor = event.color;
      });
    });
    pages = <Widget>[
      WeiboListPage(),
      NewsListPage(),
      DiscoveryPage(),
      MyInfoPage()
    ];
  }

  Image getTabImage(path) {
    return new Image.asset(path, width: 20.0, height: 20.0);
  }

  TextStyle getTabTextStyle(int curIndex) {
    if (curIndex == _tabIndex) {
      return tabTextStyleSelected;
    }
    return tabTextStyleNormal;
  }

  Text getTabTitle(int curIndex) {
    return new Text(appBarTitles[curIndex], style: getTabTextStyle(curIndex));
  }

  @override
  Widget build(BuildContext context) {
    return mainPage(context);
  }

  int last = 0;
  Future<bool> doubleClickBack() {
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

  WillPopScope mainPage(context) {
    _body = new IndexedStack(
      children: pages,
      index: _tabIndex,
    );
    return new WillPopScope(
        onWillPop: doubleClickBack,
        child: new Scaffold(
          appBar: new AppBar(
              title: new Center(
                  child: new Text(
                      appBarTitles[_tabIndex],
                      style: new TextStyle(color: Colors.white)
                  )
              ),
              iconTheme: new IconThemeData(color: Colors.white),
              backgroundColor: ThemeUtils.currentColorTheme
          ),
          body: _body,
          bottomNavigationBar: new BottomNavigationBar(
//            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  activeIcon: Icon(Icons.home, color: ThemeUtils.currentColorTheme),
                  icon: Icon(Icons.home, color: Colors.grey),
                  title: getTabTitle(0)
              ),
              BottomNavigationBarItem(
                  activeIcon: Icon(Icons.fiber_new, color: ThemeUtils.currentColorTheme),
                  icon: Icon(Icons.fiber_new, color: Colors.grey),
                  title: getTabTitle(1)
              ),
              BottomNavigationBarItem(
                  activeIcon: Icon(Icons.chat, color: ThemeUtils.currentColorTheme),
                  icon: Icon(Icons.chat, color: Colors.grey),
                  title: getTabTitle(2)
              ),
              BottomNavigationBarItem(
                  activeIcon: Icon(Icons.account_circle, color: ThemeUtils.currentColorTheme),
                  icon: Icon(Icons.account_circle, color: Colors.grey),
                  title: getTabTitle(3)
              )
            ],
            currentIndex: _tabIndex,
            onTap: (index) {
              setState((){
                _tabIndex = index;
              });
              print("Selected TabIndex: "+index.toString());
            },
          ),
//        drawer: new MyDrawer()
        )
    );
  }
}
