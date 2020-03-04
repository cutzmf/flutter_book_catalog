import 'package:bookcatalog/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ThanksDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.succeedBuy, textAlign: TextAlign.center),
      actions: <Widget>[
        FlatButton(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              S.thanks,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          shape: StadiumBorder(),
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
        )
      ],
    );
  }
}
