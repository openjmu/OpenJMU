import 'package:fluttertoast/fluttertoast.dart';

void showLongToast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG
  );
}

void showShortToast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT
  );
}

void showCenterShortToast(String text) {
  Fluttertoast.showToast(
      msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
    timeInSecForIos: 1
  );
}

void cancelToast() {
  Fluttertoast.cancel();
}
void showSnackBar(){


}