import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart' as ok;

void showToast(String text) {
  ok.showToast(text, position: ok.ToastPosition.bottom);
}

void showCenterToast(String text) {
  ok.showToast(text, position: ok.ToastPosition.center);
}

void showErrorToast(String text) {
  ok.showToast(
    text,
    backgroundColor: Colors.redAccent,
  );
}

void showCenterErrorToast(String text) {
  ok.showToast(
    text,
    position: ok.ToastPosition.center,
    backgroundColor: Colors.redAccent,
  );
}

void showTopToast(String text) {
  ok.showToast(text, position: ok.ToastPosition.top);
}
