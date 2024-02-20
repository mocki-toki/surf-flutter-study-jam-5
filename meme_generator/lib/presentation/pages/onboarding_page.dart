import 'package:flutter/material.dart';
import 'package:meme_generator/presentation/routes.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Хочешь создать мем?',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(
                  onPressed: () => openSelectTemplatePage(context),
                  child: const Text('Да'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: openRickRoll,
                  child: const Text('Нет'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void openSelectTemplatePage(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.selectTemplate);
  }

  void openRickRoll() {
    launchUrl(Uri.parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ'));
  }
}
