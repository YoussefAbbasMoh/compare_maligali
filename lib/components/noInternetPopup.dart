import 'package:restart_app/restart_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showDialogBox(BuildContext context) => showCupertinoDialog<String>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text("في مشكله في اتصالك بالانترنت"),
          content: const Text(" حمل البرنامج تاني "),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Restart.restartApp();
                },
                child: const Text("اوافق"))
          ],
        ));
