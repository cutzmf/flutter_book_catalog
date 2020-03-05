import 'package:flutter/widgets.dart';

extension MediaQueryExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get safeBottom => MediaQuery.of(this).padding.bottom;
}
