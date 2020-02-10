///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-07 11:14
///
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';

import 'package:openjmu/constants/constants.dart';

class ChatPersonPage extends StatefulWidget {
  final int uid;

  const ChatPersonPage({
    Key key,
    this.uid = 164466,
  }) : super(key: key);

  @override
  _ChatPersonPageState createState() => _ChatPersonPageState();
}

class _ChatPersonPageState extends State<ChatPersonPage> {
  final _textEditingController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final topBarHeight = suSetSp(100.0);

  List<Message> messages = [];
  bool shrinkWrap = true;
  bool emoticonPadActive = false;
  double _keyboardHeight = EmotionPad.emoticonPadDefaultHeight;
  String pendingMessage = '';

  @override
  void initState() {
    super.initState();
    Instances.eventBus
      ..on<MessageReceivedEvent>().listen((event) {
        if (event.senderUid == widget.uid || event.senderUid == UserAPI.currentUser.uid) {
          final message = Message.fromEvent(event);
          if (message.content['content'] != Messages.inputting) {
            messages.insert(0, Message.fromEvent(event));
            if (mounted) setState(() {});
          }
        }
      });
    _textEditingController.addListener(() {
      pendingMessage = _textEditingController.text;
      if (mounted) setState(() {});
    });
  }

  Widget get topBar => Container(
        height: Screens.topSafeHeight + topBarHeight,
        padding: EdgeInsets.only(
          top: Screens.topSafeHeight + suSetSp(4.0),
          bottom: suSetSp(4.0),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).canvasColor,
              width: suSetSp(1.5),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BackButton(),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                UserAPI.getAvatar(size: 50.0, uid: 164466),
                Text(
                  '陈嘉旺',
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontSize: suSetSp(19.0),
                        fontWeight: FontWeight.w500,
                      ),
                )
              ],
            ),
            BackButton(color: Colors.transparent),
          ],
        ),
      );

  Widget get emoticonPadButton => MaterialButton(
        padding: EdgeInsets.zero,
        elevation: 0.0,
        highlightElevation: 2.0,
        minWidth: suSetSp(68.0),
        height: suSetSp(52.0),
        color: emoticonPadActive ? currentThemeColor : Colors.grey[400],
        child: Center(
          child: Image.asset(
            'assets/emotionIcons/憨笑.png',
            width: suSetSp(32.0),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(suSetSp(30.0)),
        ),
        onPressed: updatePadStatus,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );

  Widget get sendButton => MaterialButton(
        padding: EdgeInsets.zero,
        elevation: 0.0,
        highlightElevation: 2.0,
        minWidth: suSetSp(68.0),
        height: suSetSp(52.0),
        color: currentThemeColor,
        disabledColor: Colors.grey[400],
        child: Center(
          child: Icon(
            Icons.send,
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(suSetSp(30.0)),
        ),
        onPressed: pendingMessage.trim().isNotEmpty ? sendMessage : null,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );

  Widget get messageTextField => Expanded(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: suSetSp(8.0),
          ),
          constraints: BoxConstraints(
            minHeight: suSetSp(52.0),
            maxHeight: suSetSp(140.0),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(suSetSp(30.0)),
            color: Theme.of(context).primaryColor,
          ),
          padding: EdgeInsets.all(suSetSp(14.0)),
          child: ExtendedTextField(
            specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
            controller: _textEditingController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: 'Say something...',
              hintStyle: TextStyle(
                textBaseline: TextBaseline.alphabetic,
                fontStyle: FontStyle.italic,
              ),
            ),
            style: Theme.of(context).textTheme.body1.copyWith(
                  fontSize: suSetSp(20.0),
                  textBaseline: TextBaseline.alphabetic,
                ),
            maxLines: null,
            textInputAction: TextInputAction.unspecified,
          ),
        ),
      );

  Widget get bottomBar => Theme(
        data: Theme.of(context).copyWith(
          splashFactory: InkSplash.splashFactory,
        ),
        child: Container(
          padding: EdgeInsets.only(
            bottom: !emoticonPadActive ? MediaQuery.of(context).padding.bottom : 0.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
          ),
          child: Padding(
            padding: EdgeInsets.all(suSetSp(10.0)),
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

  Widget get messageList => Expanded(
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
                itemBuilder: (_, i) => messageWidget(messages[i]),
              ),
            ),
          ],
        ),
      );

  Widget messageWidget(Message message) {
    final end = (message.content['content'] as String).indexOf('&<img>');
    return Container(
      margin: EdgeInsets.only(
        left: message.isSelf ? 60.0 : 8.0,
        right: message.isSelf ? 8.0 : 60.0,
        top: 8.0,
        bottom: 8.0,
      ),
      width: Screens.width,
      child: Align(
        alignment: message.isSelf ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: suSetSp(16.0),
            vertical: suSetSp(10.0),
          ),
          constraints: BoxConstraints(
            minHeight: suSetSp(30.0),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color:
                message.isSelf ? currentThemeColor.withOpacity(0.5) : Theme.of(context).canvasColor,
          ),
          child: ExtendedText(
            end == -1
                ? '${(message.content['content'] as String)}'
                : '${(message.content['content'] as String).substring(
                    0,
                    (message.content['content'] as String).indexOf('&<img>'),
                  )}',
            style: TextStyle(
              fontSize: suSetSp(19.0),
            ),
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
        route: 'message',
        controller: _textEditingController,
      );

  void judgeShrink(context) {
    if (_scrollController.hasClients) {
      final maxExtent = _scrollController.position.maxScrollExtent;
      final limitExtent = 50.0;
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
    if (mounted) setState(() {});
  }

  void updatePadStatus() {
    final change = () {
      emoticonPadActive = !emoticonPadActive;
      if (mounted) setState(() {});
    };
    if (emoticonPadActive) {
      change();
    } else {
      if (MediaQuery.of(context).viewInsets.bottom != 0.0) {
        SystemChannels.textInput.invokeMethod('TextInput.hide').whenComplete(
          () async {
            Future.delayed(const Duration(milliseconds: 300), () {}).whenComplete(change);
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
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
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
