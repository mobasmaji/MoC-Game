import 'package:flutter/material.dart';
import 'Screens/game_page.dart';
import 'Screens/game_over.dart';
import 'Screens/welcome.dart';


class Routes {
  Routes._();

  static const String game_over = '/game-over';
  static const String game = '/game';
  static const String welcome = '/welcome';




  static final routes = <String, WidgetBuilder>{
    game: (BuildContext context) => GamePage(true),
    game_over: (BuildContext context) => GameOver(0),
    welcome: (BuildContext context) => Welcome(),
  };
}
