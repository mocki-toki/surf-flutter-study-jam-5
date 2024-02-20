import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:meme_generator/domain/entities/template.dart';
import 'package:meme_generator/presentation/routes.dart';
import 'package:meme_generator/presentation/widgets/editor.dart';

class MemeFormPage extends StatefulWidget {
  const MemeFormPage({Key? key}) : super(key: key);

  @override
  State<MemeFormPage> createState() => _MemeFormPageState();
}

class _MemeFormPageState extends State<MemeFormPage> {
  Template? currentTemplate;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ModalRoute.of(context)!.settings;
      final editedTemplate = settings.arguments as Template;

      setState(() {
        currentTemplate = editedTemplate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentTemplate == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        title: const Text(
          'Создание мема',
        ),
      ),
      body: Editor.meme(
        currentTemplate!,
        onTemplateChanged: (value) => setState(() => currentTemplate = value),
        onSaved: (capture) => saveMeme(context, capture),
      ),
    );
  }

  void saveMeme(BuildContext context, Uint8List capture) {
    Navigator.of(context).pushNamed(
      Routes.memeCreated,
      arguments: capture,
    );
  }
}
