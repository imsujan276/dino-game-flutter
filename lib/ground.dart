import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'game-object.dart';
import 'sprite.dart';

Sprite groundSprite = Sprite(
  imagePath: "assets/images/ground.png",
  imageWidth: 2399,
  imageHeight: 24,
);

class Ground extends GameObject {
  final Offset worldLocation;

  Ground({required this.worldLocation});

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      (worldLocation.dx - runDistance) * worldToPixelRatio,
      screenSize.height / 1.75 - groundSprite.imageHeight,
      groundSprite.imageWidth.toDouble(),
      groundSprite.imageHeight.toDouble(),
    );
  }

  @override
  Widget render() {
    return Image.asset(groundSprite.imagePath);
  }
}

List<Ground> kGround = [
  Ground(worldLocation: const Offset(0, 0)),
  Ground(worldLocation: Offset(groundSprite.imageWidth / 10, 0))
];
