import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../providers/video-provider.dart';

const String baseUrl = 'https://www.xynie.com/feeds/short-videos-app';

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

Future<bool> checkInternet() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

buildErrorDialog(BuildContext context, String title, String contant,
    {VoidCallback? callback}) {
  Widget okButton = TextButton(
    child: const Text("OK",
        style: TextStyle(
            color: Colors.black,
            decorationColor: Colors.black,
            fontFamily: 'poppins')),
    onPressed: () {
      if (callback == null) {
        Navigator.pop(context);
      } else {
        callback();
      }
    },
  );

  if (Platform.isAndroid) {
    AlertDialog alert = AlertDialog(
      title: Text(title,
          style: const TextStyle(
              color: Colors.black,
              decorationColor: Colors.black,
              fontFamily: 'poppins')),
      content: Text(contant,
          style: const TextStyle(
              color: Colors.black,
              decorationColor: Colors.black,
              fontFamily: 'poppins')),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  if (Platform.isIOS) {
    CupertinoAlertDialog cupertinoAlertDialog = CupertinoAlertDialog(
      title: Text(title,
          style: const TextStyle(
              color: Colors.black,
              decorationColor: Colors.black,
              fontFamily: 'poppins')),
      content: Text(contant,
          style: const TextStyle(
              color: Colors.black,
              decorationColor: Colors.black,
              fontFamily: 'poppins')),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return cupertinoAlertDialog;
      },
    );
  }
  // show the dialog
}


Widget spinKit = Container(
  decoration: const BoxDecoration(
    borderRadius: BorderRadius.all(Radius.elliptical(15.0, 15.0)),
    gradient: LinearGradient(
      begin: Alignment(-1.0, 1.0),
      end: Alignment(1.0, -1.0),
      colors: <Color>[Colors.black12, Colors.black12],
    ),
    // color: buttonColor,
  ),
  width: 90.0,
  height: 90.0,
  child: const SpinKitChasingDots(
    color: Colors.white,
    size: 40.0,
  ),
);

Widget commanScreen({required Scaffold scaffold, required bool isLoading}) {
  return KeyboardDismisser(
      gestures: const [GestureType.onTap, GestureType.onPanUpdateDownDirection],
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: spinKit,
        child: Container(color: Colors.white, child: scaffold),
      ));
}

const Color whiteColor = Colors.white;
const Color blueColor = Colors.blueAccent;
const Color backGroundColor = Color(0xFF01BFA4);
