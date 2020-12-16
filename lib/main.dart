import 'package:esense/Screens/game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Screens/welcome.dart';

import 'routes.dart';

void main() {
  runApp(MyApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIOverlays([]);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plants vs Zombie',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Welcome(),
      routes: Routes.routes,
    );
  }
}
