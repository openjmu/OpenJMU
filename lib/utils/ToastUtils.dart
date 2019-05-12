import 'package:fluttertoast/fluttertoast.dart';

import 'package:OpenJMU/utils/ThemeUtils.dart';

void showLongToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
    );
}

void showShortToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
    );
}

void showCenterShortToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
    );
}

void showCenterErrorShortToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        backgroundColor: ThemeUtils.defaultColor,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
    );
}

void showTopShortToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIos: 1,
    );
}

void cancelToast() {
    Fluttertoast.cancel();
}
