import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:meme_generator/domain/entities/layer.dart';
import 'package:meme_generator/domain/extensions/color_extension.dart';

class Template {
  const Template({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.preview,
    required this.layers,
  });

  final String id;
  final String name;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color foregroundColor;
  final Uint8List preview;
  final List<Layer> layers;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'width': width,
      'height': height,
      'background_color': backgroundColor.toHex(),
      'foreground_color': foregroundColor.toHex(),
      'preview': base64Encode(preview),
      'layers': layers.map((layer) => layer.toJson()).toList(),
    };
  }

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'],
      name: json['name'],
      width: json['width'],
      height: json['height'],
      backgroundColor: json['background_color'].toString().fromHex(),
      foregroundColor: json['foreground_color'].toString().fromHex(),
      preview: base64Decode(json['preview']),
      layers: (json['layers'] as List)
          .map((layer) => Layer.fromJson(layer))
          .toList(),
    );
  }

  Template copyWith({
    String? id,
    String? name,
    double? width,
    double? height,
    Color? backgroundColor,
    Color? foregroundColor,
    Uint8List? preview,
    List<Layer>? layers,
  }) {
    return Template(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      preview: preview ?? this.preview,
      layers: layers ?? this.layers,
    );
  }
}
