///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-03-08 17:07
///
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:extended_text_field/extended_text_field.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: 'openjmu://login', routeName: '登录页')
class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  /// Focus nodes for input field. Basically for dismiss.
  /// 输入框的焦点实例。主要用于点击其他位置时失焦动作。
  final FocusNode usernameNode = FocusNode();
  final FocusNode passwordNode = FocusNode();

  /// Form state.
  /// 表单状态
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// TEC for fields.
  /// 字段的输入控制器
  final TextEditingController _usernameController = TextEditingController(
    text: DataUtils.recoverWorkId(), // 加载保存的学工号
  );
  final TextEditingController _passwordController = TextEditingController();

  /// Gradient for background transition.
  /// 背景渐变颜色组
  List<Color> get colorGradient => <Color>[defaultLightColor, Colors.pink[400]];

  bool get loginButtonEnable => !(_login || _loginDisabled);

  /// Animation controller for background transition.
  /// 背景渐变的动画控制器，单位为角度。
  AnimationController backgroundAnimateController;

  /// Rotate duration for background transition.
  /// 背景渐变旋转的周期
  Duration get backgroundRotateDuration => 10.seconds;

  /// Common animate duration.
  /// 通用的动画周期
  Duration get animateDuration => kRadialReactionDuration;

  /// White text style.
  /// 白色的文字样式
  TextStyle get whiteTextStyle => TextStyle(
        color: Colors.white,
        fontSize: 18.sp,
      );

  String _username = DataUtils.recoverWorkId() ?? ''; // 账户变量
  String _password = ''; // 密码变量
  bool _agreement = false; // 是否已勾选统一协议
  bool _login = false; // 是否正在登陆
  bool _loginDisabled = true; // 是否允许登陆
  bool _isObscure = true; // 是否开启密码显示
  bool _usernameCanClear = false; // 账户是否可以清空
  bool _keyboardAppeared = false; // 键盘是否出现

  @override
  void initState() {
    super.initState();

    /// Binding state ticker to animation controller.
    /// 绑定当前状态实例至动画控制器
    backgroundAnimateController = AnimationController.unbounded(
      vsync: this,
      duration: backgroundRotateDuration,
      value: 0,
    );

    /// Start animation when post.
    /// 第一帧开始执行背景渐变动画
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      animateBackground();
    });

    /// Initialize `_usernameCanClear`.
    /// 初始化账户是否清空标志位
    _usernameCanClear = _username?.isNotEmpty ?? false;

    /// Bind text fields listener.
    /// 绑定输入部件的监听
    _usernameController.addListener(usernameListener);
    _passwordController.addListener(passwordListener);
  }

  @override
  void dispose() {
    /// Dispose all controllers.
    /// 销毁所有控制器
    backgroundAnimateController?.dispose();
    _usernameController?.dispose();
    _passwordController?.dispose();
    usernameNode
      ..unfocus()
      ..dispose();
    passwordNode
      ..unfocus()
      ..dispose();
    _formKey.currentState?.reset();
    _formKey.currentState?.dispose();

    super.dispose();
  }

  /// Function calling background animate.
  /// 背景动画执行方法
  Future<void> animateBackground({bool reset = false}) async {
    /// If `reset` then reset value to zero.
    /// 如果为递归调用重置，则将值重新设置为0。
    if (reset) {
      backgroundAnimateController.value = 0;
    }
    await backgroundAnimateController.animateTo(360,
        duration: backgroundRotateDuration);

    /// Call function itself to keep the animation running after previous is done.
    /// 动画执行完成后递归调用动画以保证动画执行
    unawaited(animateBackground(reset: true));
  }

  /// Listener for username text field.
  /// 账户输入字段的监听
  void usernameListener() {
    _username = _usernameController.text;
    if (mounted) {
      if (_usernameController.text.isNotEmpty && !_usernameCanClear) {
        setState(() {
          _usernameCanClear = true;
        });
      } else if (_usernameController.text.isEmpty && _usernameCanClear) {
        setState(() {
          _usernameCanClear = false;
        });
      }
    }
  }

  /// Listener for password text field.
  /// 密码输入字段的监听
  void passwordListener() {
    _password = _passwordController.text;
  }

  /// Function called after login button pressed.
  /// 登录按钮的回调
  void loginButtonPressed(BuildContext context) {
    try {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        setState(() {
          _login = true;
        });
        DataUtils.login(_username, _password).then((bool result) {
          if (result) {
            navigatorState.pushNamedAndRemoveUntil(
              Routes.openjmuHome,
              (_) => false,
              arguments: <String, dynamic>{'initAction': null},
            );
          } else {
            _login = false;
            if (mounted) {
              setState(() {});
            }
          }
        }).catchError((dynamic e) {
          LogUtils.e('Failed when login: $e');
          showCenterErrorToast('登录失败');
          _login = false;
          if (mounted) {
            setState(() {});
          }
        });
      }
    } catch (e) {
      LogUtils.e('Failed when login: $e');
      showCenterErrorToast('登录失败');
    }
  }

  /// Function called after forgot button pressed.
  /// 忘记密码按钮的回调
  Future<void> forgotPassword() async {
    final bool confirm = await ConfirmationDialog.show(
      context,
      title: '忘记密码',
      content: '找回密码详见\n网络中心主页 -> 集大通行证',
      confirmLabel: '查看',
      cancelLabel: '返回',
      showConfirm: true,
    );
    if (confirm) {
      unawaited(API.launchWeb(
        url: 'https://net.jmu.edu.cn/info/1309/2476.htm',
        title: '网页链接',
        withCookie: false,
      ));
    }
  }

  /// Function called when validating fields.
  /// 校验表单的方法
  ///
  /// `_username`/`_password`/`_agreement` all needs to be passed.
  /// 账号、密码、协议均需要完成才可登录。
  void validateForm() {
    if (_username.isNotEmpty &&
        _password.isNotEmpty &&
        _agreement &&
        _loginDisabled) {
      setState(() {
        _loginDisabled = false;
      });
    } else if (_username.isEmpty || _password.isEmpty || !_agreement) {
      setState(() {
        _loginDisabled = true;
      });
    }
  }

  /// Set input fields alignment to avoid blocked by insets
  /// when the input methods was shown/hidden.
  /// 键盘弹出或收起时设置输入字段的对齐方式以防止遮挡。
  void setAlignment(BuildContext context) {
    final double inputMethodHeight = MediaQuery.of(context).viewInsets.bottom;
    if (inputMethodHeight > 1.0 && !_keyboardAppeared) {
      setState(() {
        _keyboardAppeared = true;
      });
    } else if (inputMethodHeight <= 1.0 && _keyboardAppeared) {
      setState(() {
        _keyboardAppeared = false;
      });
    }
  }

  /// Function called when triggered listener.
  /// 触发页面监听器时，所有的输入框失焦，隐藏键盘。
  void dismissFocusNodes() {
    if (usernameNode?.hasFocus ?? false) {
      usernameNode?.unfocus();
    }
    if (passwordNode?.hasFocus ?? false) {
      passwordNode.unfocus();
    }
  }

  /// Animated background.
  /// 会旋转的背景
  ///
  /// Using [pythagoreanTheorem] to calculate radius that can cover the
  /// whole screen when rotating.
  /// 使用勾股定理计算半径，使得旋转时仍然可以铺满屏幕
  Widget get animatingBackground {
    final double radius =
        pythagoreanTheorem(Screens.width, Screens.height); // 半径
    final double horizontalOffset = radius - Screens.width; // 水平偏移
    final double verticalOffset = radius - Screens.height; // 垂直偏移

    return Positioned(
      left: -horizontalOffset,
      right: -horizontalOffset,
      top: -verticalOffset,
      bottom: -verticalOffset,
      child: AnimatedBuilder(
        animation: backgroundAnimateController,
        builder: (BuildContext _, Widget child) {
          return SizedBox(
            width: radius,
            height: radius,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(
                  math.pi / 180 * backgroundAnimateController.value),
              child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colorGradient,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Wrapper for content part.
  /// 内容块包装
  Widget contentWrapper({@required List<Widget> children}) {
    return Positioned.fill(
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerUp: (PointerUpEvent event) {
          dismissFocusNodes();
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 30.w,
              vertical: 30.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  /// Logo on top.
  /// 顶部Logo
  Widget get topLogo => Text(
        'OpenJmu',
        style: whiteTextStyle.copyWith(
          fontFamily: 'Chocolate',
          fontSize: 40.sp,
        ),
      );

  /// Welcome tip widget.
  /// 欢迎语部件
  Widget get welcomeTip => Container(
        margin: EdgeInsets.symmetric(vertical: 15.h),
        height: 100.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '欢迎使用',
              style: whiteTextStyle.copyWith(
                  fontSize: 40.sp, fontWeight: FontWeight.w600),
            ),
            Text(
              '登录以继续',
              style: whiteTextStyle.copyWith(fontSize: 22.sp),
            ),
          ],
        ),
      );

  /// Announcement widget.
  /// 公告部件
  Widget get announcementWidget => Selector<SettingsProvider, bool>(
        selector: (_, SettingsProvider provider) =>
            provider.announcementsEnabled,
        builder: (_, bool announcementEnabled, __) {
          if (announcementEnabled) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 15.h),
              child: const AnnouncementWidget(
                backgroundColor: Colors.black26,
                radius: 10.0,
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      );

  /// Input field wrapper.
  /// 输入区域包装
  ///
  /// [title] 标签文字, [child] 内容部件
  Widget inputFieldWrapper({
    @required String title,
    @required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      width: double.maxFinite,
      height: 100.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.w),
        color: Colors.black.withOpacity(0.15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: whiteTextStyle.copyWith(fontSize: 18.sp),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              cursorColor: Colors.white,
              textSelectionColor: Colors.white54,
              textSelectionHandleColor: Colors.white,
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  /// Username field.
  /// 账户输入部件
  Widget get usernameField => inputFieldWrapper(
        title: '学号/工号',
        child: Row(
          children: <Widget>[
            Expanded(
              child: ExtendedTextField(
                focusNode: usernameNode,
                controller: _usernameController,
                onChanged: (String value) => _username = value,
                keyboardType: TextInputType.number,
                enabled: !_login,
                scrollPadding: EdgeInsets.zero,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: whiteTextStyle.copyWith(fontSize: 36.sp),
                textSelectionControls: WhiteTextSelectionControls(),
              ),
            ),
            if (_usernameCanClear)
              SizedBox.fromSize(
                size: Size.square(40.w),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white,
                    size: 40.w,
                  ),
                  onPressed: _usernameController.clear,
                ),
              ),
          ],
        ),
      );

  /// Password field.
  /// 密码输入部件
  Widget get passwordField => inputFieldWrapper(
        title: '密码',
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                focusNode: passwordNode,
                controller: _passwordController,
                onSaved: (String value) => _password = value,
                obscureText: _isObscure,
                validator: (String value) {
                  if (value.isEmpty) {
                    return '请输入密码';
                  }
                  return null;
                },
                enabled: !_login,
                scrollPadding: EdgeInsets.zero,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: whiteTextStyle.copyWith(fontSize: 36.sp),
              ),
            ),
            SizedBox.fromSize(
              size: Size.square(40.w),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withOpacity(_isObscure ? 0.25 : 1.0),
                  size: 40.w,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
            ),
          ],
        ),
      );

  /// Agreement checkbox.
  /// 用户协议复选框
  Widget get agreementCheckbox => SizedBox.fromSize(
        size: Size.square(60.w),
        child: RoundedCheckbox(
          value: _agreement,
          activeColor: Colors.white30,
          inactiveColor: Colors.black12,
          onChanged: !_login
              ? (bool value) {
                  setState(() {
                    _agreement = value;
                  });
                  validateForm();
                }
              : null,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );

  /// Agreement tips.
  /// 用户协议提示
  Widget get agreementTip => Text.rich(
        TextSpan(
          children: <TextSpan>[
            const TextSpan(text: '登录即代表您同意'),
            TextSpan(
              text: '《用户协议》',
              style: const TextStyle(decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  API.launchWeb(
                    url: '${API.homePage}/license.html',
                    title: 'OpenJMU 用户协议',
                  );
                },
            ),
          ],
          style: whiteTextStyle.copyWith(fontSize: 18.sp),
        ),
        maxLines: 1,
        overflow: TextOverflow.fade,
      );

  /// Agreement widget.
  /// 用户协议部件。包含复选框和提示。
  Widget get agreementWidget => Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            agreementCheckbox,
            agreementTip,
          ],
        ),
      );

  /// Login button.
  /// 登录按钮
  Widget get loginButton => AnimatedOpacity(
        duration: animateDuration,
        opacity: _loginDisabled ? 0.5 : 1.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: loginButtonEnable ? () => loginButtonPressed(context) : null,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            height: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.w),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2.h),
                  blurRadius: 5.h,
                ),
              ],
              color: Colors.white,
            ),
            child: Row(children: <Widget>[
              Text(
                '登录',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.sp,
                ),
              ),
              const Spacer(flex: 1),
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: maxBorderRadius,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      defaultLightColor,
                    ),
                    value: _login ? null : 0.0,
                  ),
                ),
              ),
            ]),
          ),
        ),
      );

  /// Actions down below.
  /// 其他操作项。包含“账号查询”、“忘记密码”。
  Widget get otherActions => SizedBox(
        height: 30.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              padding: EdgeInsets.zero,
              child: Text('账号查询', style: whiteTextStyle),
              onPressed: () {
                API.launchWeb(
                  url: 'http://myid.jmu.edu.cn/ids/EmployeeNoQuery.aspx',
                  title: '集大通行证 - 工号查询',
                );
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text('|', style: whiteTextStyle),
            FlatButton(
              padding: EdgeInsets.zero,
              child: Text('忘记密码', style: whiteTextStyle),
              onPressed: forgotPassword,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    setAlignment(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: WillPopScope(
        onWillPop: doubleBackExit,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: <Widget>[
              animatingBackground,
              contentWrapper(
                children: <Widget>[
                  topLogo,
                  Expanded(
                    flex: 6,
                    child: Form(
                      key: _formKey,
                      onChanged: validateForm,
                      child: AnimatedAlign(
                        duration: animateDuration,
                        curve: Curves.easeInOut,
                        alignment: _keyboardAppeared
                            ? Alignment.topCenter
                            : Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            welcomeTip,
                            announcementWidget,
                            usernameField,
                            passwordField,
                            agreementWidget,
                            loginButton,
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  otherActions,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WhiteTextSelectionControls extends ExtendedMaterialTextSelectionControls {
  final double _kHandleSize = 22.0;

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textHeight,
  ) {
    final Widget handle = SizedBox(
      width: _kHandleSize,
      height: _kHandleSize,
      child: CustomPaint(
        painter:
            ExtendedMaterialTextSelectionHandlePainter(color: Colors.white),
      ),
    );

    // [handle] is a circle, with a rectangle in the top left quadrant of that
    // circle (an onion pointing to 10:30). We rotate [handle] to point
    // straight up or up-right depending on the handle type.
    switch (type) {
      case TextSelectionHandleType.left: // points up-right
        return Transform.rotate(angle: math.pi / 2.0, child: handle);
      case TextSelectionHandleType.right: // points up-left
        return handle;
      case TextSelectionHandleType.collapsed: // points up
        return Transform.rotate(angle: math.pi / 4.0, child: handle);
    }
    assert(type != null);
    return null;
  }
}
