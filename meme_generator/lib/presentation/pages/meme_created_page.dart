import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';

class MemeCreatedPage extends StatefulWidget {
  const MemeCreatedPage({Key? key}) : super(key: key);

  @override
  State<MemeCreatedPage> createState() => _MemeCreatedPageState();
}

class _MemeCreatedPageState extends State<MemeCreatedPage> {
  Uint8List? memeImage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ModalRoute.of(context)!.settings;
      setState(() {
        memeImage = settings.arguments as Uint8List;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (memeImage == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        title: const Text(
          'Мем готов',
        ),
      ),
      body: Column(
        children: [
          Image.memory(memeImage!),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: save,
                child: const Text('Сохранить'),
              ),
              if (!kIsWeb) ...[
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: share,
                  child: const Text('Поделиться'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> save() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await ImageGallerySaver.saveImage(memeImage!);
    } else {
      if (kIsWeb) {
        await WebImageDownloader.downloadImageFromUInt8List(
          uInt8List: memeImage!,
        );
      } else {
        await FileSaver.instance.saveFile(
          name: 'meme.jpg',
          bytes: memeImage!,
          mimeType: MimeType.jpeg,
        );
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Мем сохранен')),
      );
    }
  }

  Future<void> share() {
    return Share.shareXFiles(
      [
        XFile.fromData(
          memeImage!,
          mimeType: 'image/jpeg',
          name: 'meme.jpg',
        )
      ],
    );
  }
}
