import 'package:flutter/material.dart';
import '../Constant/assets.dart';
import '../Utils/audio_player.dart';
import '../routes.dart';

class GameOver extends StatelessWidget {
  final int score;
  GameOver(this.score);
  _playSound() async {
    await AudioPlayer.playSound(Assets.game_over);
  }

  @override
  Widget build(BuildContext context) {
    _playSound();

    return Material(
      child: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Game Over",

              ),
              SizedBox(height: 25.0),
              Text(
                "Score: ${score ?? 0}",

              ),
              SizedBox(height: 25.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: FlatButton(
                  color: Colors.green[300],
                  child: Text(
                    "Play Again",

                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: FlatButton(
                  color: Colors.red,
                  child: Text(
                    "Return to main",

                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          color: Colors.black.withOpacity(0.6),
        ),
      ),
    );
  }
}
