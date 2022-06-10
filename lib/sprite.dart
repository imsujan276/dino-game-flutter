// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Sprite {
  String imagePath;
  int imageWidth;
  int imageHeight;
  Sprite({
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
  });

  Sprite copyWith({
    String? imagePath,
    int? imageWidth,
    int? imageHeight,
  }) {
    return Sprite(
      imagePath: imagePath ?? this.imagePath,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'imagePath': imagePath,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
    };
  }

  factory Sprite.fromMap(Map<String, dynamic> map) {
    return Sprite(
      imagePath: map['imagePath'] as String,
      imageWidth: map['imageWidth'] as int,
      imageHeight: map['imageHeight'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Sprite.fromJson(String source) => Sprite.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Sprite(imagePath: $imagePath, imageWidth: $imageWidth, imageHeight: $imageHeight)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Sprite &&
      other.imagePath == imagePath &&
      other.imageWidth == imageWidth &&
      other.imageHeight == imageHeight;
  }

  @override
  int get hashCode => imagePath.hashCode ^ imageWidth.hashCode ^ imageHeight.hashCode;
}
