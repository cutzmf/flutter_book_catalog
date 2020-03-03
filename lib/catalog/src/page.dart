import 'package:bookcatalog/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: Text(S.booksCatalog),
      ),
    );
  }
}
