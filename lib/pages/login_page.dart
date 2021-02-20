///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-03-08 17:07
///
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:video_player/video_player.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: 'openjmu://login', routeName: '登录页')
class LoginPage extends StatefulWidget {
  const LoginPage({Key key, this.initAction}) : super(key: key);

  final int initAction;

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with RouteAware {
  /// Common animate duration.
  /// 通用的动画周期
  Duration get animateDuration => kRadialReactionDuration;

  /// TEC for fields.
  /// 字段的输入控制器
  final TextEditingController _usernameController = TextEditingController(
    text: DataUtils.recoverWorkId(), // 加载保存的学工号
  );
  final TextEditingController _passwordController = TextEditingController();

  /// 账户变量
  final ValueNotifier<String> _username = ValueNotifier<String>(
    DataUtils.recoverWorkId() ?? '',
  );

  /// 密码变量
  final ValueNotifier<String> _password = ValueNotifier<String>('');

  /// 是否已勾选同意协议
  final ValueNotifier<bool> _agreement = ValueNotifier<bool>(false);

  /// 账户是否可以清空
  final ValueNotifier<bool> _usernameCanClear = ValueNotifier<bool>(false);

  /// 是否允许登陆
  final ValueNotifier<bool> _loginButtonEnabled = ValueNotifier<bool>(false);

  /// 是否正在登陆
  final ValueNotifier<bool> _isLogin = ValueNotifier<bool>(false);

  /// 是否开启密码显示
  final ValueNotifier<bool> _isObscure = ValueNotifier<bool>(true);

  /// 键盘是否出现
  final ValueNotifier<bool> _keyboardAppeared = ValueNotifier<bool>(false);

  /// 是否处于预览页面
  final ValueNotifier<bool> _isPreview = ValueNotifier<bool>(true);

  /// 背景视频的控制器
  final VideoPlayerController videoController = VideoPlayerController.asset(
    R.ASSETS_LOGIN_BACKGROUND_VIDEO_MP4,
  );

  @override
  void initState() {
    super.initState();
    // Initialize `_usernameCanClear`.
    // 初始化账户是否清空标志位
    _usernameCanClear.value = _username.value.isNotEmpty;

    // Bind text fields listener.
    // 绑定输入部件的监听
    _usernameController.addListener(usernameListener);
    _passwordController.addListener(passwordListener);

    initializeVideo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Instances.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    // Dispose all controllers.
    // 销毁所有控制器
    _usernameController?.dispose();
    _passwordController?.dispose();
    _username?.dispose();
    _password?.dispose();
    _agreement?.dispose();
    _usernameCanClear?.dispose();
    _loginButtonEnabled?.dispose();
    _isLogin?.dispose();
    _isObscure?.dispose();
    _keyboardAppeared?.dispose();
    _isPreview?.dispose();
    videoController
      ..setLooping(false)
      ..pause()
      ..dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    videoController.play();
  }

  @override
  void didPushNext() {
    // 跳转至其他页面时，取消输入框聚焦
    dismissFocusNodes();
    videoController.pause();
  }

  /// Listener for username text field.
  /// 账户输入字段的监听
  void usernameListener() {
    _username.value = _usernameController.text;
    if (_usernameController.text.isNotEmpty && !_usernameCanClear.value) {
      _usernameCanClear.value = true;
    } else if (_usernameController.text.isEmpty && _usernameCanClear.value) {
      _usernameCanClear.value = false;
    }
    validateForm();
  }

  /// Listener for password text field.
  /// 密码输入字段的监听
  void passwordListener() {
    _password.value = _passwordController.text;
    validateForm();
  }

  /// 初始化视频控制器及配置
  Future<void> initializeVideo() async {
    await Future.wait(<Future<void>>[
      videoController.setLooping(true),
      videoController.setVolume(0.0),
      videoController.initialize(),
    ]);
    videoController.play();
  }

  /// Function called after login button pressed.
  /// 登录按钮的回调
  Future<void> loginButtonPressed(BuildContext context) async {
    if (_isLogin.value) {
      return;
    }
    try {
      _isLogin.value = true;
      final bool result = await DataUtils.login(
        _username.value,
        _password.value,
      );
      if (result) {
        await videoController.setLooping(false);
        await videoController.pause();
        navigatorState.pushNamedAndRemoveUntil(
          Routes.openjmuHome.name,
          (_) => false,
          arguments: Routes.openjmuHome.d(initAction: widget.initAction),
        );
      } else {
        _isLogin.value = false;
      }
    } catch (e) {
      LogUtils.e('Failed when login: $e');
      showCenterErrorToast('登录失败');
      _isLogin.value = false;
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
      API.launchWeb(
        url: 'https://net.jmu.edu.cn/jdtx/jdtxzdlsm.htm',
        title: '网页链接',
        withCookie: false,
      );
    }
  }

  /// Function called when validating fields.
  /// 校验表单的方法
  ///
  /// `_username`, `_password`, `_agreement` all needs to be passed.
  /// 账号、密码、协议均需要完成才可登录。
  void validateForm() {
    if (_username.value.isNotEmpty &&
        _password.value.isNotEmpty &&
        _agreement.value &&
        !_loginButtonEnabled.value) {
      _loginButtonEnabled.value = true;
    } else if (_username.value.isEmpty ||
        _password.value.isEmpty ||
        !_agreement.value) {
      _loginButtonEnabled.value = false;
    }
  }

  /// Set input fields alignment to avoid blocked by insets
  /// when the input methods was shown/hidden.
  /// 键盘弹出或收起时设置输入字段的对齐方式以防止遮挡。
  void setAlignment(BuildContext context) {
    final double inputMethodHeight = MediaQuery.of(context).viewInsets.bottom;
    if (inputMethodHeight > 1.0 && !_keyboardAppeared.value) {
      _keyboardAppeared.value = true;
    } else if (inputMethodHeight <= 1.0 && _keyboardAppeared.value) {
      _keyboardAppeared.value = false;
    }
  }

  /// Function called when triggered listener.
  /// 触发页面监听器时，所有的输入框失焦，隐藏键盘。
  void dismissFocusNodes() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// Video player for the background video.
  /// 背景视频播放器
  Widget videoWidget(BuildContext context) {
    return Positioned.fill(child: VideoPlayer(videoController));
  }

  /// Filter for the video player.
  /// 视频播放的滤镜
  Widget videoFilter(BuildContext context) {
    return Positioned.fill(
      child: ValueListenableBuilder<bool>(
        valueListenable: _isPreview,
        builder: (_, bool value, __) => AnimatedContainer(
          duration: animateDuration * 5,
          color: value ? Colors.black45 : context.theme.colorScheme.surface,
        ),
      ),
    );
  }

  /// Logo on top.
  /// 顶部Logo
  Widget get topLogo {
    return SvgPicture.asset(
      R.IMAGES_OPENJMU_LOGO_TEXT_SVG,
      color: _isPreview.value ? Colors.white : defaultLightColor,
      height: 20.w,
    );
  }

  /// Welcome tip widget.
  /// 欢迎语部件
  Widget get welcomeTip {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 18.w),
      child: Text(
        '欢迎使用',
        style: TextStyle(
          color: _isPreview.value ? Colors.white : null,
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Announcement widget.
  /// 公告部件
  Widget get announcementWidget {
    return Selector<SettingsProvider, bool>(
      selector: (_, SettingsProvider p) => p.announcementsEnabled,
      builder: (_, bool enabled, __) {
        if (!enabled) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 15.w),
          child: AnnouncementWidget(
            backgroundColor: defaultLightColor.withOpacity(0.75),
            height: 60.w,
            radius: 15.0,
          ),
        );
      },
    );
  }

  /// Username field.
  /// 账户输入部件
  Widget get usernameField {
    return _InputFieldWrapper(
      title: '学号/工号',
      disabledNotifier: _isLogin,
      controller: _usernameController,
      actionName: '账号查询',
      actionOnTap: () => API.launchWeb(
        url: 'http://myid.jmu.edu.cn/ids/EmployeeNoQuery.aspx',
        title: '集大通行证 - 工号查询',
      ),
      keyboardType: TextInputType.number,
      suffixWidget: ValueListenableBuilder<bool>(
        valueListenable: _usernameCanClear,
        builder: (_, bool canClear, __) {
          if (!canClear) {
            return const SizedBox.shrink();
          }
          return SizedBox.fromSize(
            size: Size.square(36.w),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.clear, size: 36.w),
              onPressed: _usernameController.clear,
            ),
          );
        },
      ),
    );
  }

  /// Password field.
  /// 密码输入部件
  Widget get passwordField {
    return ValueListenableBuilder<bool>(
      valueListenable: _isObscure,
      builder: (_, bool isObscure, __) {
        return _InputFieldWrapper(
          title: '密码',
          disabledNotifier: _isLogin,
          controller: _passwordController,
          obscureText: isObscure,
          actionName: '忘记密码',
          actionOnTap: forgotPassword,
          suffixWidget: SizedBox.fromSize(
            size: Size.square(36.w),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                isObscure ? Icons.visibility_off : Icons.visibility,
                color: isObscure ? null : defaultLightColor,
                size: 36.w,
              ),
              onPressed: () {
                _isObscure.value = !_isObscure.value;
              },
            ),
          ),
        );
      },
    );
  }

  /// Agreement checkbox.
  /// 用户协议复选框
  Widget get agreementCheckbox {
    return SizedBox.fromSize(
      size: Size.square(60.w),
      child: ValueListenableBuilder<bool>(
        valueListenable: _agreement,
        builder: (_, bool isAgreed, __) {
          return ValueListenableBuilder<bool>(
            valueListenable: _isLogin,
            builder: (_, bool isLogin, __) {
              return RoundedCheckbox(
                value: _agreement.value,
                activeColor: defaultLightColor,
                inactiveColor: context.textTheme.bodyText2.color,
                onChanged: !isLogin
                    ? (bool value) {
                        _agreement.value = value;
                        validateForm();
                      }
                    : null,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            },
          );
        },
      ),
    );
  }

  /// Agreement tips.
  /// 用户协议提示
  Widget get agreementTip {
    return Text.rich(
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
        style: TextStyle(
          color: _isPreview.value ? Colors.white : null,
          fontSize: 18.sp,
        ),
      ),
      maxLines: 1,
      overflow: TextOverflow.fade,
    );
  }

  /// Agreement widget.
  /// 用户协议部件。包含复选框和提示。
  Widget get agreementWidget {
    return ValueListenableBuilder<bool>(
      valueListenable: _isPreview,
      builder: (_, bool value, __) => Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!value) agreementCheckbox,
            agreementTip,
          ],
        ),
      ),
    );
  }

  Widget _previewLoginButton(BuildContext context) {
    return Tapper(
      onTap: () {
        _isPreview.value = false;
        Future<void>.delayed(animateDuration * 5, () {
          videoController.pause();
        });
      },
      child: Container(
        height: 72.w,
        margin: EdgeInsets.only(bottom: 30.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.w),
          color: currentThemeColor,
        ),
        alignment: Alignment.center,
        child: Text(
          '登录',
          style: TextStyle(
            color: Colors.white,
            height: 1.2,
            fontSize: 22.sp,
          ),
        ),
      ),
    );
  }

  /// Wrapper for content part.
  /// 内容块包装
  Widget contentWrapper(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isPreview,
      builder: (_, bool value, __) => Tapper(
        onTap: dismissFocusNodes,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(30.w),
            child: SizedBox.expand(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  topLogo,
                  welcomeTip,
                  const Spacer(),
                  if (value) _previewLoginButton(context),
                  if (value) agreementWidget,
                  if (!value)
                    Expanded(
                      flex: 30,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _keyboardAppeared,
                        builder: (_, bool isAppear, __) {
                          return AnimatedAlign(
                            duration: animateDuration,
                            curve: Curves.easeInOut,
                            alignment: isAppear
                                ? Alignment.topCenter
                                : Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                announcementWidget,
                                usernameField,
                                passwordField,
                                agreementWidget,
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  if (!value) const Spacer(flex: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Login button.
  /// 登录按钮
  Widget loginButton(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isPreview,
      builder: (_, bool isPreview, Widget child) {
        if (isPreview) {
          return const AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: SizedBox.shrink(),
          );
        }
        return child;
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _loginButtonEnabled,
        builder: (_, bool isEnabled, __) {
          return PositionedDirectional(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            start: 0.0,
            end: 0.0,
            child: Tapper(
              onTap: isEnabled ? () => loginButtonPressed(context) : null,
              child: AnimatedContainer(
                duration: animateDuration,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                height: 84.w,
                color: isEnabled ? defaultLightColor : Colors.black54,
                child: Center(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isLogin,
                    builder: (_, bool isLogin, __) {
                      return AnimatedSwitcher(
                        duration: animateDuration,
                        child: isLogin
                            ? const LoadMoreSpinningIcon(
                                isRefreshing: true,
                                color: Colors.white,
                                size: 32,
                              )
                            : Text(
                                '登录',
                                style: TextStyle(
                                  color: Colors.white,
                                  height: 1.2,
                                  letterSpacing: 1.sp,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setAlignment(context);
    return ValueListenableBuilder<bool>(
      valueListenable: _isPreview,
      builder: (_, bool v, Widget c) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: v || context.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: c,
      ),
      child: WillPopScope(
        onWillPop: doubleBackExit,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: DefaultTextStyle.merge(
            style: TextStyle(fontSize: 18.sp),
            child: Stack(
              children: <Widget>[
                videoWidget(context),
                videoFilter(context),
                contentWrapper(context),
                loginButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Input field wrapper.
/// 输入区域包装
///
/// [title] 标签文字, [child] 内容部件
class _InputFieldWrapper extends StatelessWidget {
  const _InputFieldWrapper({
    Key key,
    @required this.title,
    @required this.disabledNotifier,
    this.actionName,
    this.actionOnTap,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixWidget,
  }) : super(key: key);

  final String title;
  final String actionName;
  final VoidCallback actionOnTap;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final ValueNotifier<bool> disabledNotifier;
  final Widget suffixWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.w),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            height: 100.w,
            color: context.theme.dividerColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (actionName != null)
                      Tapper(
                        onTap: actionOnTap,
                        child: Text(
                          actionName,
                          style: const TextStyle(color: defaultLightColor),
                        ),
                      ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: disabledNotifier,
                        builder: (_, bool isDisabled, __) {
                          return ExtendedTextField(
                            controller: controller,
                            keyboardType: keyboardType,
                            enabled: !isDisabled,
                            obscureText: obscureText,
                            obscuringCharacter: '*',
                            scrollPadding: EdgeInsets.zero,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: TextStyle(height: 1.26, fontSize: 36.sp),
                          );
                        },
                      ),
                    ),
                    if (suffixWidget != null) suffixWidget,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
