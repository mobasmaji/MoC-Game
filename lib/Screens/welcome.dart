import 'package:esense/Screens/game_page.dart';
import 'package:flutter/material.dart';
import '../Constant/assets.dart';
import '../Utils/audio_player.dart';
import '../routes.dart';

class Welcome extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
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
                "Plant Survival",
                style: TextStyle(fontSize: 20),

              ),
              Text(
                "Defend against zombies",

              ),
              SizedBox(height: 200),
              Text(
                "Connect your eSense Earables for better game experience ",

              ),
              SizedBox(height: 25.0),
              FlatButton(

                  color: Colors.green[200],
                  child: Text(
                    "Connect & play",
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(new MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                          return new GamePage(true);

                        }));
                  },
                ),
              FlatButton(
                  color: Colors.red,
                  child: Text(
                    "Play without earables",
                  ),
                  onPressed: () {
                    Navigator.of(context).push(new MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                          return new GamePage(false);

                        }));
                  },
              ),
            ],
          ),
          color: Colors.black.withOpacity(0.6),
        ),
      ),
    );
  }
}
