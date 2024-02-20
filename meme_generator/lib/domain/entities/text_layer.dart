import 'dart:ui';

import 'package:meme_generator/domain/entities/layer.dart';

class TextLayer extends Layer {
  TextLayer({
    required super.id,
    required super.x,
    required super.y,
    required super.scale,
    required this.text,
    required this.align,
  }) : super(type: 'text');

  String text;
  final TextAlign align;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'x': x,
      'y': y,
      'scale': scale,
      'text': text,
      'align': align.name,
    };
  }

  TextLayer.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          x: json['x'],
          y: json['y'],
          scale: json['scale'],
          text: json['text'],
          align: TextAlign.values.byName(json['align']),
        );

  @override
  TextLayer copyWith({
    String? id,
    String? type,
    double? x,
    double? y,
    double? scale,
    String? text,
    Color? color,
    TextAlign? align,
  }) {
    return TextLayer(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      text: text ?? this.text,
      align: align ?? this.align,
    );
  }
}
