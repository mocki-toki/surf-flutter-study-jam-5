import 'dart:convert';
import 'dart:core';

import 'package:meme_generator/domain/entities/template.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class TemplateStorageService {
  final SharedPreferences _sharedPreferences;

  TemplateStorageService._(this._sharedPreferences);

  static Future<TemplateStorageService> init() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return TemplateStorageService._(sharedPreferences);
  }

  Future<List<Template>> getTemplates() async {
    final templates = (jsonDecode(
      _sharedPreferences.getString('templates') ?? '[]',
    ) as List)
        .map((e) => Template.fromJson(e))
        .toList();

    return templates;
  }

  Future<Template?> getTemplate(String id) async {
    final templates = await getTemplates();

    return templates.firstWhereOrNull((template) => template.id == id);
  }

  Future<void> addTemplate(Template template) async {
    final templates = await getTemplates();
    final updatedTemplates = [...templates, template];

    await _sharedPreferences.setString(
      'templates',
      jsonEncode(updatedTemplates.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> updateTemplate(Template template) async {
    final templates = await getTemplates();
    final updatedTemplates = templates.map((e) {
      if (e.id == template.id) {
        return template;
      }
      return e;
    }).toList();

    await _sharedPreferences.setString(
      'templates',
      jsonEncode(updatedTemplates.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> deleteTemplate(String id) async {
    final templates = await getTemplates();
    final updatedTemplates = templates.where((e) => e.id != id).toList();

    await _sharedPreferences.setString(
      'templates',
      jsonEncode(updatedTemplates.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addAllTemplates(List<Template> templates) async {
    await _sharedPreferences.setString(
      'templates',
      jsonEncode(templates.map((e) => e.toJson()).toList()),
    );
  }
}
