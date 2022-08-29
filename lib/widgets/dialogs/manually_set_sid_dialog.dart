///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-12 11:35
///
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';

class ManuallySetSidDialog extends StatefulWidget {
  @override
  _ManuallySetSidDialogState createState() => _ManuallySetSidDialogState();
}

class _ManuallySetSidDialogState extends State<ManuallySetSidDialog> {
  late final TextEditingController _tec = TextEditingController(
    text: UserAPI.currentUser.sid ?? '',
  )..addListener(() {
      setState(() {
        sid = _tec.text;
        canSave = _tec.text != UserAPI.currentUser.sid;
      });
    });

  String sid = '';
  bool canSave = false;

  void updateSid(BuildContext context) {
    currentUser = currentUser.copyWith(sid: sid);
    Navigator.of(context).pop();
    LogUtil.d('$currentUser');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(12.w),
              ),
              width: MediaQuery.of(context).size.width - 100.w,
              padding: EdgeInsets.only(top: 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Text(
                      'Set SID Manually (DEBUG)',
                      style: context.textTheme.headline6,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: TextField(
                      autofocus: true,
                      style: context.textTheme.bodyText2?.copyWith(
                        fontSize: 18.sp,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                      controller: _tec,
                      maxLength: 32,
                      maxLines: null,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 6.h),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[850]!),
                        ),
                        hintText: currentUser.signature,
                        hintStyle: const TextStyle(
                            textBaseline: TextBaseline.alphabetic),
                      ),
                      cursorColor: currentThemeColor,
                    ),
                  ),
                  SizedBox(
                    height: 60.h,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: CupertinoDialogAction(
                            isDefaultAction: true,
                            child: Text(
                              '取消',
                              style: TextStyle(fontSize: 18.sp),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Expanded(
                          child: CupertinoDialogAction(
                            child: Text(
                              '保存',
                              style: TextStyle(
                                color: canSave
                                    ? currentThemeColor
                                    : Theme.of(context).disabledColor,
                                fontSize: 18.sp,
                              ),
                            ),
                            onPressed:
                                canSave ? () => updateSid(context) : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gap.v(MediaQuery.of(context).viewInsets.bottom)
        ],
      ),
    );
  }
}
