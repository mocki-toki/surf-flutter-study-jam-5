import 'package:flutter/material.dart';
import 'package:meme_generator/presentation/routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meme Generator',
      routes: appRoutes,
      initialRoute: '/',
    );
  }
}
