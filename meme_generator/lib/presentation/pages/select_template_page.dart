import 'package:flutter/material.dart';
import 'package:meme_generator/domain/entities/template.dart';
import 'package:meme_generator/infrastructure/services/template_storage_service.dart';
import 'package:meme_generator/presentation/routes.dart';
import 'package:provider/provider.dart';

class SelectTemplatePage extends StatefulWidget {
  const SelectTemplatePage({Key? key}) : super(key: key);

  @override
  State<SelectTemplatePage> createState() => _SelectTemplatePageState();
}

class _SelectTemplatePageState extends State<SelectTemplatePage> {
  List<Template>? templates;
  var selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadTemplates());
  }

  Future<void> loadTemplates() async {
    final templateStorageService = context.read<TemplateStorageService>();
    final templatesFromStorage = await templateStorageService.getTemplates();

    if (!context.mounted) return;
    setState(() => templates = templatesFromStorage);
  }

  @override
  Widget build(BuildContext context) {
    final useSelectedTemplateIfPossible =
        selectedIndex == -1 ? null : () => useSelectedTemplate(context);

    final templateItemsOrStatus = templates == null
        ? const Center(child: CircularProgressIndicator())
        : templates!.isEmpty
            ? const Center(child: Text('Нет шаблонов. Создайте, нажав на "+"'))
            : ListView.builder(
                itemCount: templates!.length,
                itemBuilder: (context, index) {
                  final template = templates![index];
                  final isSelected = index == selectedIndex;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = isSelected ? -1 : index;
                      });
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            !isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.transparent)
                                : const Icon(Icons.check),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                template.name,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => editTemplate(template),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteTemplate(template),
                            ),
                          ],
                        ),
                        Image.memory(
                          template.preview,
                          height: 300,
                        ),
                        const Divider(),
                      ],
                    ),
                  );
                },
              );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите шаблон'),
        actions: [
          IconButton(
            onPressed: createNewTemplate,
            tooltip: 'Создать новый шаблон',
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(child: templateItemsOrStatus),
            SizedBox(
              width: double.infinity,
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: useSelectedTemplateIfPossible,
                        child: const Text('Использовать выбранный шаблон'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createNewTemplate() async {
    await Navigator.of(context).pushNamed(Routes.createNewTemplate);
    await loadTemplates();
  }

  void useSelectedTemplate(BuildContext context) {
    if (selectedIndex == -1) return;

    final selectedTemplate = templates![selectedIndex];
    Navigator.of(context).pushNamed(
      Routes.createMeme,
      arguments: selectedTemplate,
    );
  }

  Future<void> editTemplate(Template template) async {
    await Navigator.of(context)
        .pushNamed(Routes.editTemplate, arguments: template);
    await loadTemplates();
  }

  Future<void> deleteTemplate(Template template) async {
    final templateStorageService = context.read<TemplateStorageService>();
    await templateStorageService.deleteTemplate(template.id);
    await loadTemplates();
  }
}
