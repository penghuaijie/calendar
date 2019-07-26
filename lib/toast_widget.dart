import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';


class ShowToast {
  showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        fontSize: 16,
        textColor: Colors.white,
        backgroundColor: Colors.black.withOpacity(0.8),
        timeInSecForIos: 2
    );
  }
}