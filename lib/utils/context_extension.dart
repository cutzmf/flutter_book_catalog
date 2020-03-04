import 'package:flutter/widgets.dart';

extension MediaQueryExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
}
