import 'dart:convert';
import 'dart:typed_data';

import 'package:meme_generator/domain/entities/layer.dart';

class ImageLayer extends Layer {
  ImageLayer({
    required super.id,
    required super.x,
    required super.y,
    required super.scale,
    required this.width,
    required this.height,
    required this.data,
  }) : super(type: 'image');

  final double width;
  final double height;
  final Uint8List data;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'x': x,
      'y': y,
      'scale': scale,
      'width': width,
      'height': height,
      'data': base64Encode(data),
    };
  }

  ImageLayer.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          x: json['x'],
          y: json['y'],
          scale: json['scale'],
          width: json['width'],
          height: json['height'],
          data: base64Decode(json['data']),
        );

  @override
  ImageLayer copyWith({
    String? id,
    String? type,
    double? x,
    double? y,
    double? scale,
    double? width,
    double? height,
    Uint8List? data,
  }) {
    return ImageLayer(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      width: width ?? this.width,
      height: height ?? this.height,
      data: data ?? this.data,
    );
  }
}
