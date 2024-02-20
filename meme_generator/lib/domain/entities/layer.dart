import 'package:meme_generator/domain/entities/image_layer.dart';
import 'package:meme_generator/domain/entities/text_layer.dart';

abstract class Layer {
  Layer({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.scale,
  });

  final String id;
  final String type;
  double x;
  double y;
  double scale;

  Map<String, dynamic> toJson();

  factory Layer.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'text':
        return TextLayer.fromJson(json);
      case 'image':
        return ImageLayer.fromJson(json);
      default:
        throw ArgumentError('Invalid layer type: ${json['type']}');
    }
  }

  Layer copyWith({
    String? id,
    String? type,
    double? x,
    double? y,
    double? scale,
  });
}
