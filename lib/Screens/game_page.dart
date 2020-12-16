import 'dart:async';
import 'package:esense/Screens/game_over.dart';
import 'package:esense_flutter/esense.dart';
import 'package:flutter/material.dart';
import '../Constant/assets.dart';
import '../Models/bullet.dart';
import '../Models/main_handler.dart';
import '../Models/plant.dart';
import '../Models/zombie.dart';
import '../Utils/audio_player.dart';
import '../Utils/math_util.dart';
import '../Widgets/bullet.dart';
import '../Widgets/plant.dart';
import '../Widgets/score_board.dart';
import '../Widgets/zombie.dart';
import '../routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GamePage extends StatefulWidget {
  final bool useEsense;
  const GamePage(this.useEsense);
  @override
  _GamePageState createState() => _GamePageState(useEsense);
}

class _GamePageState extends State<GamePage> {

  _GamePageState(this.useEsense);
  // ESense attr
  String _deviceName = 'Unknown';
  double _voltage = -1;
  String _deviceStatus = '';
  bool sampling = false;
  String _event = '';
  String _button = 'not pressed';
  String eSenseName = 'eSense-0500';
  StreamSubscription subscription;
  // Game attr
  PlantHandler _plant = PlantHandler(0.2, 0.9);
  Bullethandler _bullet = Bullethandler(5, 5);
  List<ZombieHandler> _zombies = [ZombieHandler(5,5)];
  Timer _bulletTimer;
  int score = 0;
  bool useEsense;
  bool ready = false;

  Future<void> _connectToESense() async {
    bool con = false;

    // if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    ESenseManager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');

      // when we're connected to the eSense device, we can start listening to events from it
      if (event.type == ConnectionType.connected) _listenToESenseEvents();

      setState(() {
        switch (event.type) {
          case ConnectionType.connected:
            _deviceStatus = 'connected';
            break;
          case ConnectionType.unknown:
            _deviceStatus = 'unknown';
            break;
          case ConnectionType.disconnected:
            _deviceStatus = 'disconnected';
            break;
          case ConnectionType.device_found:
            _deviceStatus = 'device_found';
            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'device_not_found';
            break;
        }
      });
    });

    con = await ESenseManager.connect(eSenseName);

    setState(() {
      _deviceStatus = con ? 'connecting' : 'connection failed';
    });
  }
  void _listenToESenseEvents() async {
    ESenseManager.eSenseEvents.listen((event) {
      print('ESENSE event: $event');

      setState(() {
        switch (event.runtimeType) {
          case DeviceNameRead:
            _deviceName = (event as DeviceNameRead).deviceName;
            break;
          case BatteryRead:
            _voltage = (event as BatteryRead).voltage;
            break;
          case ButtonEventChanged:
            _button = (event as ButtonEventChanged).pressed ? 'pressed' : 'not pressed';
            if((event as ButtonEventChanged).pressed) {
              _shootBullet();
            }
            break;
          case AccelerometerOffsetRead:
          // Not implemented in the flutter plugin
            break;
          case AdvertisementAndConnectionIntervalRead:
          // Not implemented in the flutter plugin
            break;
          case SensorConfigRead:
          // TNot implemented in the flutter plugin
            break;
        }
      });
    });
    _getESenseProperties();
    _onLoading();

    Timer(Duration(seconds: 3), ()  =>  _startListenToSensorEvents());
  }

  void _getESenseProperties() async {
    // get the battery level every 10 secs
    Timer.periodic(Duration(seconds: 5), (timer) async => await ESenseManager.getBatteryVoltage());

    // wait 2, 3, 4, 5, ... secs before getting the name, offset, etc.
    // it seems like the eSense BTLE interface does NOT like to get called
    // several times in a row -- hence, delays are added in the following calls
    Timer(Duration(seconds: 2), () async => await ESenseManager.getDeviceName());
    Timer(Duration(seconds: 3), () async => await ESenseManager.getAccelerometerOffset());
    Timer(Duration(seconds: 4), () async => await ESenseManager.getAdvertisementAndConnectionInterval());
    Timer(Duration(seconds: 5), () async => await ESenseManager.getSensorConfig());
  }

  void _startListenToSensorEvents() async {
    List<double> arr= [];
    subscription = ESenseManager.sensorEvents.listen((event) {

        double value = convertGyroToDPS(event.gyro[0].toDouble());
        _movingAvg(value);
        if(movingAvg >  0) {
          _plant.moveRight(movingAvg/90);
          print("Right");

        } else if (movingAvg <  0) {
          print("Left");
          _plant.moveLeft(-movingAvg/90);
        }


    });
    setState(() {
      sampling = true;
    });
  }

  void _pauseListenToSensorEvents() async {
    subscription.cancel();
    setState(() {
      sampling = false;
    });
  }

  void dispose() {
    _pauseListenToSensorEvents();
    ESenseManager.disconnect();
    super.dispose();
  }

  /// GAME DYNAMICS
  /// move the plant up Y↑
  _moveLeft(MainHandler mock) {
        setState(() {
          mock.moveLeft(0.1);
        });
  }

  /// move the plant Down Y↓
  _moveRight(MainHandler mock) {
      setState(() {
        mock.moveRight(0.1);
      });
  }

  /// shooting the bullets
  _shootBullet() async {
    if (_bullet.x == 5) {
      await AudioPlayer.playSound(Assets.shootSoundEffet);
      setState(() {
        _bullet.initCords(_plant.x, _plant.y);
      });
      _bulletTimer = Timer.periodic(Duration(milliseconds: 15), (timer) {
        setState(() {
          _bullet.moveUp(0.05);
        });
        for(var zombie in _zombies) {
          if ((_bullet.y - zombie.y).abs() < 0.05 &&
              (_bullet.x - zombie.x).abs() < 0.2) {
            timer.cancel();
            if (zombie.zombieTimer != null) {
              zombie.zombieTimer.cancel();
            }
            _bullet.initCords(5, 5);
            _calculateScore();
            _moveZombie(zombie);
          }
        }
        if (_bullet.y< -0.9) {
          timer.cancel();
          _bullet.initCords(5, 5);
        }
      });
    }
  }

  /// moving the zombie
  _moveZombie(ZombieHandler zombie)  {
    setState(() {
      zombie.initCords(nexRandom(-0.9, 1.8),-1);
    });
      if (zombie.y == -1) {
       zombie.zombieTimer =
            Timer.periodic(Duration(milliseconds: 150), (timer) async {
              setState(() {
                zombie.moveDown(0.02);
              });
              if ((_plant.y - zombie.y).abs() < 0.05) {
                timer.cancel();
                if (_bulletTimer != null) {
                  _bulletTimer.cancel();
                }
                print("Game Over");
                for(var zombie in _zombies) {
                  zombie.zombieTimer.cancel();
                }
                await Navigator.of(context).push(new MaterialPageRoute<Null>(
                    builder: (BuildContext context) {
                      return new GameOver(score);
                    }));

                _zombies.clear();
                ZombieHandler zombie = ZombieHandler(5,5);
                _zombies.add(zombie);
                _moveZombie(zombie);
              }
            });
      }
  }

  _calculateScore() {
    setState(() {
      score++;
      if(score % 10 == 0) {
        ZombieHandler zombie = ZombieHandler(5,5);
        _zombies.add(zombie);
        _moveZombie(zombie);
      }
    });
  }

  @override
  initState()  {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(this.useEsense) {
        _connectToESense();
      } else {
        for(var zombie in _zombies) {
          _moveZombie(zombie);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
          child: Column(
            children: [
              _esenseStatus(),
              _garden(),
              _gameControllers(),
            ]

          ),
        ),

    );
  }

  /// Game controllers arrows & shoot button
  Widget _gameControllers() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.brown[600],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left),
                  onPressed: () {
                    _moveLeft(_plant);
                    },
                ),
                SizedBox(width: 15.0),
                IconButton(
                  icon: Icon(Icons.arrow_right),
                  onPressed: () {
                    _moveRight(_plant);
                  },
                ),
              ],
            ),
            ScoreBoard(
              score: score,
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.meteor),
              onPressed: () {
                _shootBullet();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// the main garden
  _garden() {
    return Expanded(
      flex: 5,
      child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.garden),
              fit: BoxFit.cover,
            ),
          ),
          child: _players()),
    );
  }
  _esenseStatus() {
    int battery = ((_voltage * 100) ~/ 5).toInt();
    return Container(
          child : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text((ESenseManager.connected && this._deviceName != 'Unknown')? 'Connected: \t$_deviceName' : 'Not connected',
                    style: TextStyle(color: ((ESenseManager.connected  && this._deviceName != 'Unknown')? Colors.green[300] :  Colors.red[300] ))),
                ),
              Align(
                alignment: Alignment.center,
                child: Text(_voltage>0?'Battery: \t$battery %': "Battery: None"),
              ),
            ],
          ),
    );
  }

  /// Plants , Zombies & bullet will be displayed
  Widget _players() {
    return Stack(
      children: _createAnimatedChildren()
    );
  }
  double convertAccelToMS2(double value) {
    // Default scale factor for +-4G is 8192.
    return (value / 8192) * 9.80665;
  }
  double convertGyroToDPS(double value) {
    // Default scale factor for +-500Degree is 65.5.
    return (value / 65.5);
  }

  List<Widget> _createAnimatedChildren() {

    var list = new List<Widget>.generate(_zombies.length, (int index) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 150),
        alignment: Alignment(_zombies[index].x, _zombies[index].y),
        child: Zombie(),
        curve: Curves.fastOutSlowIn,
      );
    });
    var plantAnimation =AnimatedContainer(
      duration: Duration(milliseconds: 200),
      alignment: Alignment(_plant.x, _plant.y),
      curve: Curves.linear,
      child: Plant(),

    );

    var bulletAnimation = AnimatedContainer(
      duration: Duration(milliseconds: 10),
      alignment: Alignment(_bullet.x, _bullet.y),
      child: Bullet(),
      curve: Curves.linear,

    );
    // add to list
    list.add(plantAnimation);
    list.add(bulletAnimation);
    return list;
  }

  void _onLoading() {
    showGeneralDialog(
      barrierLabel: "Label",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 300,
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircularProgressIndicator(),
                  FlatButton(
                    child: Text(_deviceStatus),
                    onPressed:() {

                    }
                  ),
                ]
              ),
            ),
            margin: EdgeInsets.only(bottom: 50, left: 12, right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
    );
    new Future.delayed(new Duration(seconds: 5), () {
      Navigator.pop(context); //pop dialog

      for(var zombie in _zombies) {
        _moveZombie(zombie);
      }
    });
  }

  int counter = 0;
  double movingAvg = 0;
  _movingAvg(double nextValue) {
    if(counter == 10) {
      counter = 1;
      movingAvg = 0;
    }
    counter++;
    movingAvg = movingAvg + (nextValue- movingAvg)/ counter;
  }
}
