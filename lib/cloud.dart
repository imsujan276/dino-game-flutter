import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'game-object.dart';
import 'sprite.dart';

Sprite cloudSprite = Sprite(
  imagePath: "assets/images/cloud.png",
  imageWidth: 82,
  imageHeight: 27,
);

class Cloud extends GameObject {
  final Offset worldLocation;

  Cloud({required this.worldLocation});

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      (worldLocation.dx - runDistance) * worldToPixelRatio / 5,
      screenSize.height / 3 - cloudSprite.imageHeight - worldLocation.dy,
      cloudSprite.imageWidth.toDouble(),
      cloudSprite.imageHeight.toDouble(),
    );
  }

  @override
  Widget render() {
    return Image.asset(cloudSprite.imagePath);
  }
}

List<Cloud> kClouds = [
  Cloud(worldLocation: const Offset(50, -20)),
  Cloud(worldLocation: const Offset(150, -10)),
  Cloud(worldLocation: const Offset(250, -30)),
];
