import 'package:flutter/material.dart';

class AppGradients {
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [Colors.teal.shade300, Colors.blue.shade400],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient get disabledGradient => LinearGradient(
    colors: [Colors.grey.shade300, Colors.grey.shade400],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
