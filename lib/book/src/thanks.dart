import 'package:bookcatalog/strings.dart';
import 'package:flutter/material.dart';

class ThanksDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.succeedBuy, textAlign: TextAlign.center),
      actions: <Widget>[
        FloatingActionButton(
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
          backgroundColor: Colors.black,
        )
      ],
    );
  }
}
