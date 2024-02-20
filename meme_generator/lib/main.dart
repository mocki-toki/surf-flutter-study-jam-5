import 'package:flutter/material.dart';
import 'package:meme_generator/domain/entities/template.dart';
import 'package:meme_generator/infrastructure/services/template_storage_service.dart';
import 'package:meme_generator/presentation/app.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final templateStorageService = await _initTemplateStorage();

  runApp(
    Provider.value(
      value: templateStorageService,
      child: const MyApp(),
    ),
  );
}

Future<TemplateStorageService> _initTemplateStorage() async {
  final templateStorageService = await TemplateStorageService.init();
  final templates = await templateStorageService.getTemplates();

  if (templates.isEmpty) {
    await templateStorageService.addAllTemplates(_defaultTemplates);
  }

  return templateStorageService;
}

const _defaultTemplates = <Template>[];
