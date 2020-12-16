import 'package:flutter/material.dart';
import '../Constant/assets.dart';

class ScoreBoard extends StatelessWidget {
  final int score;

  const ScoreBoard({this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          child: Image.asset(Assets.zombieHead),
          width: 50.0,
          height: 50.0,
        ),
        SizedBox(width: 3.0),
        Text(
          "X",
        ),
        SizedBox(width: 5.0),
        Text(
          score?.toString() ?? "0",
        ),
      ],
    );
  }
}
