import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meme_generator/domain/entities/image_layer.dart';
import 'package:meme_generator/domain/entities/layer.dart';
import 'package:meme_generator/domain/entities/template.dart';
import 'package:meme_generator/domain/entities/text_layer.dart';
import 'package:meme_generator/domain/extensions/color_extension.dart';
import 'package:meme_generator/infrastructure/utils.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image/image.dart' as img;

enum _EditorType { template, meme }

class Editor extends StatefulWidget {
  const Editor._(
    this.template,
    this._type,
    this.onTemplateChanged,
    this.onSaved, {
    Key? key,
  }) : super(key: key);

  const Editor.template(
    Template template, {
    Key? key,
    required ValueChanged<Template> onTemplateChanged,
    required ValueChanged<Uint8List> onSaved,
  }) : this._(template, _EditorType.template, onTemplateChanged, onSaved,
            key: key);

  const Editor.meme(
    Template template, {
    Key? key,
    required ValueChanged<Template> onTemplateChanged,
    required ValueChanged<Uint8List> onSaved,
  }) : this._(template, _EditorType.meme, onTemplateChanged, onSaved, key: key);

  final Template template;
  final _EditorType _type;
  final ValueChanged<Template> onTemplateChanged;
  final ValueChanged<Uint8List>? onSaved;

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  Layer? selectedLayer;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    late final double scale;

    if (MediaQuery.sizeOf(context).height > MediaQuery.sizeOf(context).width) {
      scale = (MediaQuery.sizeOf(context).width / widget.template.width).abs();
    } else {
      scale =
          (MediaQuery.sizeOf(context).height / widget.template.height).abs();
    }

    return Provider<_EditorType>.value(
      value: widget._type,
      child: Provider<Template>.value(
        value: widget.template,
        child: GestureDetector(
          onTap: () => setState(() => selectedLayer = null),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                if (widget._type == _EditorType.template)
                  ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Column(
                      children: [
                        const Divider(height: 10),
                        _ColorPicker(
                          caption: 'Цвет фона',
                          currentColor: widget.template.backgroundColor,
                          onChanged: (color) {
                            widget.onTemplateChanged(
                              widget.template.copyWith(backgroundColor: color),
                            );
                          },
                        ),
                        _ColorPicker(
                          caption: 'Цвет текста',
                          currentColor: widget.template.foregroundColor,
                          onChanged: (color) {
                            widget.onTemplateChanged(
                              widget.template.copyWith(foregroundColor: color),
                            );
                          },
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                Expanded(
                    child: Screenshot(
                  controller: screenshotController,
                  child: Transform.scale(
                    scale: scale,
                    child: Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: widget.template.foregroundColor,
                          fontSize: 24,
                        ),
                        child: Container(
                          color: widget.template.backgroundColor,
                          width: widget.template.width,
                          height: widget.template.height,
                          child: Stack(
                            children: [
                              for (final layer in widget.template.layers)
                                _Layer(
                                  layer,
                                  key: ValueKey(layer.id),
                                  isSelected: selectedLayer == layer,
                                  onSelected: () {
                                    setState(() => selectedLayer = layer);
                                  },
                                  onDeleted: () {
                                    widget.template.layers.remove(layer);
                                    widget.onTemplateChanged(widget.template);
                                    setState(() => selectedLayer = null);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
                SizedBox(
                  width: double.infinity,
                  child: ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: SafeArea(
                      top: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          if (selectedLayer == null)
                            const Text(
                              'Нажмите на картинку\nили текст для того, чтобы изменить его',
                              textAlign: TextAlign.center,
                            ),
                          if (selectedLayer != null)
                            Column(
                              children: [
                                if (selectedLayer is ImageLayer)
                                  Row(
                                    children: [
                                      const SizedBox(width: 16),
                                      const Text('Изображение:'),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              addOrReplaceImageLayer(
                                                  selectedLayer!.id),
                                          child: const Text('Заменить'),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                  ),
                                if (selectedLayer is TextLayer)
                                  Row(
                                    children: [
                                      const SizedBox(width: 16),
                                      const Text('Текст:'),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextField(
                                          controller: TextEditingController(
                                              text: (selectedLayer as TextLayer)
                                                  .text),
                                          onChanged: (value) {
                                            (selectedLayer as TextLayer).text =
                                                value;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                  ),
                                if (widget._type == _EditorType.template)
                                  Row(
                                    children: [
                                      const SizedBox(width: 16),
                                      const Text('Размер:'),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Slider(
                                          value: selectedLayer!.scale,
                                          min: 0.1,
                                          max: 2,
                                          onChanged: (value) {
                                            setState(() =>
                                                selectedLayer!.scale = value);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                  ),
                              ],
                            ),
                          const SizedBox(height: 16),
                          if (widget._type == _EditorType.template)
                            Row(
                              children: [
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => addLayer(context),
                                    child: const Text(
                                        'Добавить картинку или текст'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                FilledButton(
                                  onPressed: onSaved,
                                  child: const Icon(Icons.save),
                                ),
                                const SizedBox(width: 16),
                              ],
                            ),
                          if (widget._type == _EditorType.meme)
                            Center(
                              child: FilledButton(
                                onPressed: onSaved,
                                child: const Text('Сохранить мем'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addLayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Добавить картинку'),
                onTap: () {
                  Navigator.of(context).pop();
                  addOrReplaceImageLayer(null);
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Добавить текст'),
                onTap: () {
                  Navigator.of(context).pop();
                  addTextLayer();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> addOrReplaceImageLayer(String? id) async {
    final (image, width, height) = await pickImage();
    if (image == null) return;

    if (id == null) {
      widget.template.layers.add(
        ImageLayer(
          id: Utils.generateId(),
          x: 0.5,
          y: 0.5,
          scale: 1,
          data: image,
          width: width!.toDouble(),
          height: height!.toDouble(),
        ),
      );
    } else {
      final index =
          widget.template.layers.indexWhere((element) => element.id == id);
      widget.template.layers[index] = ImageLayer(
        id: id,
        x: widget.template.layers[index].x,
        y: widget.template.layers[index].y,
        scale: widget.template.layers[index].scale,
        data: image,
        width: width!.toDouble(),
        height: height!.toDouble(),
      );
    }

    widget.onTemplateChanged(widget.template);
    setState(() => selectedLayer = widget.template.layers.last);
  }

  void addTextLayer() {
    widget.template.layers.add(
      TextLayer(
        id: Utils.generateId(),
        x: 0.5,
        y: 0.5,
        scale: 1,
        text: 'Текст',
        align: TextAlign.center,
      ),
    );

    widget.onTemplateChanged(widget.template);
  }

  Future<void> onSaved() async {
    setState(() => selectedLayer = null);
    final image = await screenshotController.capture();
    widget.onSaved?.call(image!);
  }

  Future<(Uint8List? data, int? width, int? height)> pickImage() async {
    final file = await showModalBottomSheet<XFile?>(
      context: context,
      useSafeArea: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image_search),
                title: const Text('Загрузить из интернета'),
                onTap: () async {
                  Navigator.of(context).pop(await pickImageFromInternet());
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Выбрать в галерее'),
                onTap: () async {
                  Navigator.of(context).pop(await pickImageFromGallery());
                },
              ),
            ],
          ),
        );
      },
    );

    if (file == null) return (null, null, null);

    var image = img.decodeImage(await file.readAsBytes())!;
    //уменьшить картинку

    image = img.copyResize(image, width: 300);

    final encodedImage = img.encodePng(image);

    return (encodedImage, image.width, image.height);
  }

  Future<XFile?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    return pickedFile;
  }

  Future<XFile?> pickImageFromInternet() async {
    return await showModalBottomSheet<XFile?>(
      context: context,
      useSafeArea: true,
      builder: (_) {
        return _ImageFromInternetPicker(
          onSelected: (file) => Navigator.of(context).pop(file),
        );
      },
    );
  }
}

class _ImageFromInternetPicker extends StatefulWidget {
  const _ImageFromInternetPicker({Key? key, required this.onSelected})
      : super(key: key);

  final ValueChanged<XFile> onSelected;

  @override
  State<_ImageFromInternetPicker> createState() =>
      _ImageFromInternetPickerState();
}

class _ImageFromInternetPickerState extends State<_ImageFromInternetPicker> {
  final textController = TextEditingController();
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isLoading,
      child: Opacity(
        opacity: isLoading ? 0.5 : 1,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0).copyWith(bottom: 0),
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: 'Ссылка на изображение',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: downloadImage,
                    child: const Text('Готово'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> downloadImage() async {
    try {
      final url = textController.text;
      if (url.isEmpty) return;

      setState(() => isLoading = true);

      final response = Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final data = await response;
      setState(() => isLoading = false);

      widget.onSelected(XFile.fromData(Uint8List.fromList(data.data!)));
    } catch (e) {
      setState(() => isLoading = false);
      rethrow;
    }
  }
}

class _Layer extends StatefulWidget {
  const _Layer(
    this.layer, {
    Key? key,
    required this.isSelected,
    required this.onSelected,
    required this.onDeleted,
  }) : super(key: key);

  final Layer layer;
  final bool isSelected;
  final VoidCallback onDeleted;
  final VoidCallback onSelected;

  @override
  State<_Layer> createState() => _LayerState();
}

class _LayerState extends State<_Layer> {
  @override
  Widget build(BuildContext context) {
    late final Widget child;

    if (widget.layer is TextLayer) {
      child = _TextLayer(widget.layer as TextLayer);
    } else if (widget.layer is ImageLayer) {
      child = _ImageLayer(widget.layer as ImageLayer);
    } else {
      throw ArgumentError('Invalid layer type: ${widget.layer.runtimeType}');
    }

    final type = context.read<_EditorType>();

    final childWithEditedFrame = widget.isSelected
        ? Stack(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                ),
                child: child,
              ),
              if (type == _EditorType.template)
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: widget.onDeleted,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          )
        : child;

    final widgetWidth = context.findRenderObject()?.paintBounds.size.width ?? 1;
    final widgetHeight =
        context.findRenderObject()?.paintBounds.size.height ?? 1;

    return Align(
      alignment: Alignment(widget.layer.x, widget.layer.y),
      child: Transform.scale(
        scale: widget.layer.scale,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: childWithEditedFrame,
            onTapDown: (_) => widget.onSelected(),
            onPanUpdate: (details) {
              if (widget.isSelected && type == _EditorType.template) {
                setState(() {
                  widget.layer.x =
                      (widget.layer.x + details.delta.dx / widgetWidth * 2);
                  widget.layer.y =
                      (widget.layer.y + details.delta.dy / widgetHeight * 2);
                });
              }
            },
          ),
        ),
      ),
    );
  }
}

class _TextLayer extends StatelessWidget {
  const _TextLayer(this.layer);

  final TextLayer layer;

  @override
  Widget build(BuildContext context) {
    return Text(
      layer.text,
      textAlign: layer.align,
    );
  }
}

class _ImageLayer extends StatelessWidget {
  const _ImageLayer(this.layer);

  final ImageLayer layer;

  @override
  Widget build(BuildContext context) {
    return Image.memory(layer.data);
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.caption,
    required this.currentColor,
    required this.onChanged,
  });

  final String caption;
  final Color currentColor;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => showPicker(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text.rich(
              TextSpan(
                text: '$caption: ',
                children: [
                  TextSpan(
                    text: currentColor.toHex(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 24,
              height: 24,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: currentColor,
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showPicker(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Выберите цвет'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: onChanged,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Готово'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
