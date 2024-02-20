import 'package:flutter/widgets.dart';
import 'package:meme_generator/presentation/pages/meme_created_page.dart';
import 'package:meme_generator/presentation/pages/meme_form_page.dart';
import 'package:meme_generator/presentation/pages/onboarding_page.dart';
import 'package:meme_generator/presentation/pages/select_template_page.dart';
import 'package:meme_generator/presentation/pages/template_form_page.dart';

abstract class Routes {
  static const onboarding = '/';
  static const selectTemplate = '/create/select-template';
  static const createNewTemplate = '/create/template';
  static const editTemplate = '/edit/template';
  static const createMeme = '/create/meme';
  static const memeCreated = '/meme/created';
}

Map<String, Widget Function(BuildContext)> appRoutes = {
  Routes.onboarding: (context) => const OnboardingPage(),
  Routes.selectTemplate: (context) => const SelectTemplatePage(),
  Routes.createNewTemplate: (context) => const TemplateFormPage(),
  Routes.editTemplate: (context) => const TemplateFormPage(),
  Routes.createMeme: (context) => const MemeFormPage(),
  Routes.memeCreated: (context) => const MemeCreatedPage(),
};
