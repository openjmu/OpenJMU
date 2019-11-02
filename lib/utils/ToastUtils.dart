import 'package:fluttertoast/fluttertoast.dart';

import 'package:OpenJMU/constants/Constants.dart';

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
  );
}

void showCenterErrorShortToast(String text) {
  Fluttertoast.showToast(
    msg: text,
    backgroundColor: ThemeUtils.defaultColor,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
  );
}

void showTopShortToast(String text) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
  );
}

void cancelToast() {
  Fluttertoast.cancel();
}
