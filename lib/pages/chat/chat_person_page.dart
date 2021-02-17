///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-07 11:14
///
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';

import 'package:openjmu/constants/constants.dart';

class ChatPersonPage extends StatefulWidget {
  const ChatPersonPage({
    Key key,
    this.uid = '164466',
  }) : super(key: key);

  final String uid;

  @override
  _ChatPersonPageState createState() => _ChatPersonPageState();
}

class _ChatPersonPageState extends State<ChatPersonPage> {
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  double get topBarHeight => 100.sp;

  List<Message> messages = <Message>[];
  bool shrinkWrap = true;
  bool emoticonPadActive = false;
  double _keyboardHeight = EmotionPad.emoticonPadDefaultHeight;
  String pendingMessage = '';

  @override
  void initState() {
    super.initState();
    Instances.eventBus.on<MessageReceivedEvent>().listen(
      (MessageReceivedEvent event) {
        if (event.senderUid == widget.uid ||
            event.senderUid == UserAPI.currentUser.uid) {
          final Message message = Message.fromEvent(event);
          if (message.content['content'] != Messages.inputting) {
            messages.insert(0, Message.fromEvent(event));
            if (mounted) {
              setState(() {});
            }
          }
        }
      },
    );
    _textEditingController.addListener(() {
      pendingMessage = _textEditingController.text;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget get topBar {
    return Container(
      height: Screens.topSafeHeight + topBarHeight,
      padding: EdgeInsets.only(
        top: Screens.topSafeHeight + 4.w,
        bottom: 4.w,
      ),
      decoration: BoxDecoration(border: Border(bottom: dividerBS(context))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const BackButton(),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              UserAPI.getAvatar(size: 50.0, uid: '164466'),
              Text(
                '陈嘉旺',
                style: context.textTheme.bodyText2.copyWith(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
          const BackButton(color: Colors.transparent),
        ],
      ),
    );
  }

  Widget get emoticonPadButton {
    return MaterialButton(
      padding: EdgeInsets.zero,
      elevation: 0.0,
      highlightElevation: 2.0,
      minWidth: 68.w,
      height: 52.w,
      color: emoticonPadActive ? currentThemeColor : Colors.grey[400],
      child: Center(
        child: Image.asset(
          R.ASSETS_EMOTION_ICONS_HANXIAO_PNG,
          width: 32.w,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.w),
      ),
      onPressed: updatePadStatus,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget get sendButton {
    return MaterialButton(
      padding: EdgeInsets.zero,
      elevation: 0.0,
      highlightElevation: 2.0,
      minWidth: 68.w,
      height: 52.w,
      color: currentThemeColor,
      disabledColor: Colors.grey[400],
      child: const Center(child: Icon(Icons.send, color: Colors.white)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.w),
      ),
      onPressed: pendingMessage.trim().isNotEmpty ? sendMessage : null,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget get messageTextField {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        constraints: BoxConstraints(
          minHeight: 52.w,
          maxHeight: 140.w,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.w),
          color: Theme.of(context).primaryColor,
        ),
        padding: EdgeInsets.all(14.w),
        child: ExtendedTextField(
          specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
          controller: _textEditingController,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: 'Say something...',
            hintStyle: TextStyle(
              textBaseline: TextBaseline.alphabetic,
              fontStyle: FontStyle.italic,
            ),
          ),
          style: context.textTheme.bodyText2.copyWith(
            fontSize: 20.sp,
            textBaseline: TextBaseline.alphabetic,
          ),
          maxLines: null,
          textInputAction: TextInputAction.unspecified,
        ),
      ),
    );
  }

  Widget get bottomBar => Theme(
        data: Theme.of(context).copyWith(
          splashFactory: InkSplash.splashFactory,
        ),
        child: Container(
          padding: EdgeInsets.only(
            bottom: !emoticonPadActive
                ? MediaQuery.of(context).padding.bottom
                : 0.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
          ),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                emoticonPadButton,
                messageTextField,
                sendButton,
              ],
            ),
          ),
        ),
      );

  Widget get messageList {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              controller: _scrollController,
              shrinkWrap: shrinkWrap,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (_, int i) => messageWidget(messages[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget messageWidget(Message message) {
    final int end = (message.content['content'] as String).indexOf('&<img>');
    return Container(
      margin: EdgeInsets.only(
        left: message.isSelf ? 60.0 : 8.0,
        right: message.isSelf ? 8.0 : 60.0,
        top: 8.0,
        bottom: 8.0,
      ),
      width: Screens.width,
      child: Align(
        alignment:
            message.isSelf ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 10.w,
          ),
          constraints: BoxConstraints(minHeight: 30.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: message.isSelf
                ? currentThemeColor.withOpacity(0.5)
                : Theme.of(context).canvasColor,
          ),
          child: ExtendedText(
            end == -1
                ? message.content['content'] as String
                : (message.content['content'] as String).substring(
                    0,
                    (message.content['content'] as String).indexOf('&<img>'),
                  ),
            style: TextStyle(fontSize: 19.sp),
            onSpecialTextTap: specialTextTapRecognizer,
            specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
          ),
        ),
      ),
    );
  }

  Widget get emoticonPad => EmotionPad(
        active: emoticonPadActive,
        height: _keyboardHeight,
        controller: _textEditingController,
      );

  void judgeShrink(BuildContext context) {
    if (_scrollController.hasClients) {
      final double maxExtent = _scrollController.position.maxScrollExtent;
      const double limitExtent = 50.0;
      if (maxExtent > limitExtent && shrinkWrap) {
        shrinkWrap = false;
      } else if (maxExtent <= limitExtent && !shrinkWrap) {
        shrinkWrap = true;
      }
    }
  }

  void sendMessage() {
    MessageUtils.sendTextMessage(pendingMessage, widget.uid);
    _textEditingController.clear();
    pendingMessage = '';
    if (mounted) {
      setState(() {});
    }
  }

  void updatePadStatus() {
    final VoidCallback change = () {
      emoticonPadActive = !emoticonPadActive;
      if (mounted) {
        setState(() {});
      }
    };
    if (emoticonPadActive) {
      change();
    } else {
      if (MediaQuery.of(context).viewInsets.bottom != 0.0) {
        InputUtils.hideKeyboard().whenComplete(
          () {
            Future<void>.delayed(300.milliseconds, () {}).whenComplete(change);
          },
        );
      } else {
        change();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    judgeShrink(context);
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight > 0) {
      emoticonPadActive = false;
    }
    _keyboardHeight = math.max(_keyboardHeight, keyboardHeight);

    return Scaffold(
      body: Column(
        children: <Widget>[
          topBar,
          messageList,
          bottomBar,
          emoticonPad,
        ],
      ),
    );
  }
}
