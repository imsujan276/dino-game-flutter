// ignore_for_file: file_names

import 'package:flutter/material.dart';

abstract class GameObject {
  Widget render();
  Rect getRect(Size screenSize, double runDistance);
  void update(Duration lastUpdate, Duration elapsedTime) {}
}
