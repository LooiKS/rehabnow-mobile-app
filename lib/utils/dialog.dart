import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future showLoadingDialog(BuildContext context) {
  return showDialog(
      barrierDismissible: !false,
      useRootNavigator: !true,
      useSafeArea: !true,
      context: context,
      builder: (context) => WillPopScope(
            onWillPop: () async => !false,
            child: AlertDialog(
                title: Text(
                  "Loading",
                  textAlign: TextAlign.center,
                ),
                // contentPadding: EdgeInsets.all(20),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator()),
                  ],
                )),
          ));
}

showAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  String confirmText = "OK",
  String cancelText = "Cancel",
  required Function() confirmCallback,
  Function()? cancelCallback,
  String? extraButtonText,
  Function()? extraButtonCallback,
}) {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        extraButtonCallback == null || extraButtonText == null
            ? Container()
            : ElevatedButton(
                child: Text(extraButtonText),
                onPressed: () {
                  Navigator.of(context).pop();
                  extraButtonCallback();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.blue,
                  ),
                ),
              ),
        cancelCallback == null
            ? Container()
            : ElevatedButton(
                child: Text(cancelText),
                onPressed: () {
                  Navigator.of(context).pop();
                  cancelCallback();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.orange,
                  ),
                ),
              ),
        ElevatedButton(
          child: Text(confirmText),
          onPressed: () {
            Navigator.of(context).pop();
            confirmCallback();
          },
        )
      ],
    ),
  );
}
