import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/PostController.dart';
import 'package:OpenJMU/model/CommentController.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/widgets/dialogs/LoadingDialog.dart';

class DeleteDialog extends Dialog {
  final Post post;
  final Comment comment;
  final String whatToDelete;

  DeleteDialog(this.whatToDelete, {this.post, this.comment, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformAlertDialog(
      title: Text("删除$whatToDelete"),
      content: Text("是否确认删除这条$whatToDelete？"),
      actions: <Widget>[
        PlatformButton(
          android: (BuildContext context) => MaterialRaisedButtonData(
            color: ThemeUtils.currentColorTheme,
            elevation: 0,
          ),
          child: Text('确认', style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(context).pop();
            if (this.comment != null) {
              Navigator.of(context).pop();
            }
            LoadingDialogController _loadingDialogController = new LoadingDialogController();
            showDialog(
                context: context,
                builder: (BuildContext dialogContext) => LoadingDialog("正在删除$whatToDelete", _loadingDialogController)
            );
            if (this.comment != null) {
              CommentAPI.deleteComment(this.comment.post.id, this.comment.id)
                  .then((response) {
                    _loadingDialogController.changeState("success", "$whatToDelete删除成功");
                    Constants.eventBus.fire(new PostCommentedEvent(this.post.id));
                  })
                  .catchError((e) { showCenterErrorShortToast("$whatToDelete删除失败"); });
            } else if (this.post != null) {
              PostAPI.deletePost(this.post.id).then((response) {
                _loadingDialogController.changeState("success", "$whatToDelete删除成功");
                Constants.eventBus.fire(new PostDeletedEvent(this.post.id));
              }).catchError((e) {
                print(e.toString());
                print(e.response?.toString());
                _loadingDialogController.changeState("failed", "$whatToDelete删除失败");
              });
            }
          },
        ),
        PlatformButton(
          android: (BuildContext context) => MaterialRaisedButtonData(
            color: Theme.of(context).dialogBackgroundColor,
            elevation: 0,
          ),
          child: Text('取消'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}