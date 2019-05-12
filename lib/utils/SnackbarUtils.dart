import 'package:flutter/material.dart';

class SnackBarUtils {
    static void show(context, String text) {
        Scaffold.of(context).showSnackBar(
                SnackBar(content: Text(text))
        );
    }
}