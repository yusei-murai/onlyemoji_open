import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AppBarUtils {
  static AppBar createAppbar(BuildContext context,button) {
    return AppBar(
      backgroundColor: Theme.of(context).canvasColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      actions: <Widget>[
        button,
      ],
    );
  }

  static AppBar screenAppBar(BuildContext context,String title) {
    return AppBar(
      title: Text(title,style: const TextStyle(color: Colors.black),),
      centerTitle: true,
      backgroundColor: Theme.of(context).canvasColor,
      elevation: 1,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }
}

class SnackBarUtils{
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> doneSnackBar(String msg,BuildContext context){
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(msg),
      ),
    );
  }
}

class QrUtils{
  static QrImage qrImage(String str){
    return QrImage(
      data: str,
      version: QrVersions.auto,
      size: 200.0,
    );
  }
}
