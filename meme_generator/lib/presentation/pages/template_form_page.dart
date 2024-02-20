import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:meme_generator/domain/entities/template.dart';
import 'package:meme_generator/domain/entities/text_layer.dart';
import 'package:meme_generator/infrastructure/services/template_storage_service.dart';
import 'package:meme_generator/infrastructure/utils.dart';
import 'package:meme_generator/presentation/widgets/editor.dart';
import 'package:provider/provider.dart';

class TemplateFormPage extends StatefulWidget {
  const TemplateFormPage({Key? key}) : super(key: key);

  @override
  State<TemplateFormPage> createState() => _TemplateFormPageState();
}

class _TemplateFormPageState extends State<TemplateFormPage> {
  Template? currentTemplate;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ModalRoute.of(context)!.settings;
      final editedTemplate = settings.arguments as Template?;

      if (editedTemplate != null) {
        setState(() {
          currentTemplate = editedTemplate;
          isEditing = true;
        });
      } else {
        initTemplate();
      }
    });
  }

  void initTemplate() {
    final size = min(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height,
    );

    final newTemplate = Template(
      id: Utils.generateId(),
      name: 'Безымянный шаблон',
      width: size,
      height: size,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      preview: Uint8List(0),
      layers: [
        TextLayer(
          id: Utils.generateId(),
          x: 0,
          y: -0.1,
          scale: 1,
          text: 'Текст',
          align: TextAlign.center,
        ),
        TextLayer(
          id: Utils.generateId(),
          x: 0,
          y: 0.1,
          scale: 0.7,
          text: 'Описание',
          align: TextAlign.center,
        ),
      ],
    );

    setState(() => currentTemplate = newTemplate);
  }

  @override
  Widget build(BuildContext context) {
    if (currentTemplate == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Редактор шаблона',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              currentTemplate!.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: renameTemplate,
            tooltip: 'Переименовать шаблон',
            icon: const Icon(Icons.edit_note),
          ),
        ],
      ),
      body: Editor.template(
        currentTemplate!,
        onTemplateChanged: (value) => setState(() => currentTemplate = value),
        onSaved: (capture) => saveTemplate(context, capture),
      ),
    );
  }

  void renameTemplate() {
    showDialog(
      context: context,
      builder: (_) {
        final controller = TextEditingController(text: currentTemplate!.name);
        return AlertDialog(
          title: const Text('Переименовать шаблон'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Название шаблона',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentTemplate = currentTemplate!.copyWith(
                    name: controller.text,
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text('Готово'),
            ),
          ],
        );
      },
    );
  }

  void saveTemplate(BuildContext context, Uint8List capture) {
    final storage = context.read<TemplateStorageService>();
    if (isEditing) {
      storage.updateTemplate(
        currentTemplate!.copyWith(preview: capture),
      );
    } else {
      storage.addTemplate(
        currentTemplate!.copyWith(preview: capture),
      );
    }

    Navigator.of(context).pop();
  }
}
