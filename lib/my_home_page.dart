// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:dino_runner/banner_ad_widget.dart';
import 'package:dino_runner/ptera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cactus.dart';
import 'cloud.dart';
import 'dino.dart';
import 'game-object.dart';
import 'ground.dart';
import 'constants.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Dino dino = Dino();
  double runVelocity = initialVelocity;
  double runDistance = 0;
  int highScore = 0;
  TextEditingController gravityController =
      TextEditingController(text: gravity.toString());
  TextEditingController accelerationController =
      TextEditingController(text: acceleration.toString());
  TextEditingController jumpVelocityController =
      TextEditingController(text: jumpVelocity.toString());
  TextEditingController runVelocityController =
      TextEditingController(text: initialVelocity.toString());
  TextEditingController dayNightOffestController =
      TextEditingController(text: dayNightOffest.toString());

  late AnimationController worldController;
  Duration lastUpdateCall = const Duration();

  int numberOfCacti = kCacti.length;
  List<Cactus> cacti = kCacti;
  List<Ground> ground = kGround;
  List<Cloud> clouds = kClouds;
  Ptera? ptera;

  Orientation orientation = Orientation.portrait;
  bool addBirds = false;

  @override
  void initState() {
    super.initState();
    worldController =
        AnimationController(vsync: this, duration: const Duration(days: 99));
    worldController.addListener(_update);
    _die(initial: true);
    initStorage();
  }

  initStorage() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      highScore = pref.getInt('highScore') ?? 0;
      addBirds = pref.getBool('addBirds') ?? false;
      highScore = max(highScore, (runDistance ~/ 2));
    });
    pref.setInt("highScore", highScore);
  }

  void _die({bool initial = false}) async {
    setState(() {
      highScore = max(highScore, (runDistance ~/ 2));
      worldController.stop();
      dino.die();
    });
    final pref = await SharedPreferences.getInstance();
    pref.setInt("highScore", highScore);
    if (!initial) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: const Text(
              "Game Over",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.red.shade400,
          ),
        );
    }
  }

  void _newGame() {
    setState(() {
      ptera = null;
      numberOfCacti = 1;
      cacti = [Cactus(worldLocation: const Offset(200, 0))];
      ground = [
        Ground(worldLocation: const Offset(0, 0)),
        Ground(worldLocation: Offset(groundSprite.imageWidth / 10, 0))
      ];
      clouds = [
        Cloud(worldLocation: const Offset(75, -20)),
        Cloud(worldLocation: const Offset(200, 0)),
        Cloud(worldLocation: const Offset(300, -40)),
      ];
      highScore = max(highScore, (runDistance ~/ 2));
      runDistance = 0;
      runVelocity = initialVelocity;
      dino.state = DinoState.running;
      worldController.reset();
      worldController.forward();
    });
  }

  _update() {
    double elapsedTimeSeconds;
    dino.update(lastUpdateCall,
        worldController.lastElapsedDuration ?? const Duration());
    if (ptera != null) {
      ptera!.update(lastUpdateCall,
          worldController.lastElapsedDuration ?? const Duration());
    }
    try {
      elapsedTimeSeconds =
          (worldController.lastElapsedDuration! - lastUpdateCall)
                  .inMilliseconds /
              1000;
    } catch (_) {
      elapsedTimeSeconds = 0;
    }

    runDistance += runVelocity * elapsedTimeSeconds;
    runVelocity += acceleration * elapsedTimeSeconds;

    Size screenSize = MediaQuery.of(context).size;

    Rect dinoRect = dino.getRect(screenSize, runDistance);
    for (Cactus cactus in cacti) {
      Rect obstacleRect = cactus.getRect(screenSize, runDistance);
      if (dinoRect.overlaps(obstacleRect.deflate(20))) {
        _die();
      }

      if (obstacleRect.right < 0) {
        setState(() {
          cacti.remove(cactus);
          cacti.add(Cactus(
              worldLocation: Offset(
                  runDistance +
                      Random().nextInt(
                          (orientation == Orientation.portrait ? 100 : 120)) +
                      75,
                  0)));
          numberOfCacti += 1;
        });
      }
    }
    if (addBirds) {
      if ((runDistance ~/ 2) > 750) {
        if (ptera != null) {
          Rect obstacleRect = ptera!.getRect(screenSize, runDistance);
          if (dinoRect.overlaps(obstacleRect.deflate(20))) {
            _die();
          }
          if (obstacleRect.right < 0) {
            setState(() {
              ptera = null;
            });
          }
        } else {
          if ((numberOfCacti ~/ (Random().nextInt(8) + 4)) == 0) {
            setState(() {
              ptera = Ptera(
                  worldLocation: Offset(
                      cacti.last.worldLocation.dx + Random().nextInt(45) + 25,
                      Random().nextInt(8) + 2));
            });
          }
        }
      }
    }

    for (Ground groundlet in ground) {
      if (groundlet.getRect(screenSize, runDistance).right < 0) {
        setState(() {
          ground.remove(groundlet);
          ground.add(Ground(
              worldLocation: Offset(
                  ground.last.worldLocation.dx + groundSprite.imageWidth / 10,
                  0)));
        });
      }
    }

    for (Cloud cloud in clouds) {
      if (cloud.getRect(screenSize, runDistance).right < 0) {
        setState(() {
          clouds.remove(cloud);
          clouds.add(Cloud(
              worldLocation: Offset(
                  clouds.last.worldLocation.dx +
                      Random().nextInt(
                          (orientation == Orientation.portrait ? 100 : 250)) +
                      125,
                  Random().nextInt(50) - 50)));
        });
      }
    }

    lastUpdateCall = worldController.lastElapsedDuration ?? const Duration();
  }

  @override
  void dispose() {
    gravityController.dispose();
    accelerationController.dispose();
    jumpVelocityController.dispose();
    runVelocityController.dispose();
    dayNightOffestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    List<Widget> children = [];

    for (GameObject object in [
      ...clouds,
      ...ground,
      ...cacti,
      if (ptera != null) ptera!,
      dino
    ]) {
      children.add(
        AnimatedBuilder(
          animation: worldController,
          builder: (context, _) {
            Rect objectRect = object.getRect(screenSize, runDistance);
            return Positioned(
              left: objectRect.left,
              top: objectRect.top,
              width: objectRect.width,
              height: objectRect.height,
              child: object.render(),
            );
          },
        ),
      );
    }

    return Scaffold(
      body: OrientationBuilder(builder: ((context, orientation) {
        orientation = orientation;
        return AnimatedContainer(
          duration: const Duration(seconds: 1),
          color: ((runDistance / 2) ~/ dayNightOffest) % 2 == 0
              ? Colors.white
              : Colors.black,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            // onTap: () => dino.state == DinoState.dead ? _newGame() : dino.jump(),
            onTap: () => dino.state == DinoState.dead ? null : dino.jump(),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ...children,
                      AnimatedBuilder(
                        animation: worldController,
                        builder: (context, _) {
                          return Positioned(
                            top: MediaQuery.of(context).size.height * 0.05,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    'Score: ' + (runDistance ~/ 2).toString(),
                                    style: TextStyle(
                                      color: ((runDistance / 2) ~/
                                                      dayNightOffest) %
                                                  2 ==
                                              0
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'High Score: ' + highScore.toString(),
                                    style: TextStyle(
                                      color: ((runDistance / 2) ~/
                                                      dayNightOffest) %
                                                  2 ==
                                              0
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // _settings(),
                      if (dino.state == DinoState.dead) ...[
                        Positioned(
                          bottom: MediaQuery.of(context).size.height * 0.20,
                          child: const Text(
                            "Tap to Start",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => dino.state == DinoState.dead
                              ? _newGame()
                              : dino.jump(),
                          child: Container(
                            width: double.maxFinite,
                            height: double.maxFinite,
                            color: Colors.black26,
                            child: Align(
                              alignment: Alignment.center,
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.grey.shade200,
                                child: const Icon(Icons.play_arrow_outlined,
                                    size: 50),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Row(
                            children: [
                              const Text(
                                "Add birds",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Switch(
                                value: addBirds,
                                onChanged: (value) async {
                                  setState(() {
                                    addBirds = value;
                                  });
                                  final pref =
                                      await SharedPreferences.getInstance();
                                  pref.setBool("addBirds", value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Positioned(
                        bottom: 10,
                        child: Text("Dino Runner"),
                      ),
                    ],
                  ),
                ),
                const Align(
                    alignment: Alignment.bottomCenter,
                    child: AdmobBannerAdWidget()),
              ],
            ),
          ),
        );
      })),
    );
  }

  Widget _settings() {
    return Positioned(
      right: 20,
      top: 20,
      child: IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          _die();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Change Physics"),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 25,
                      width: 280,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Gravity:"),
                          SizedBox(
                            child: TextField(
                              controller: gravityController,
                              key: UniqueKey(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            height: 25,
                            width: 75,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 25,
                      width: 280,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Acceleration:"),
                          SizedBox(
                            child: TextField(
                              controller: accelerationController,
                              key: UniqueKey(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            height: 25,
                            width: 75,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 25,
                      width: 280,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Initial Velocity:"),
                          SizedBox(
                            child: TextField(
                              controller: runVelocityController,
                              key: UniqueKey(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            height: 25,
                            width: 75,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 25,
                      width: 280,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Jump Velocity:"),
                          SizedBox(
                            child: TextField(
                              controller: jumpVelocityController,
                              key: UniqueKey(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            height: 25,
                            width: 75,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 25,
                      width: 280,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Day-Night Offset:"),
                          SizedBox(
                            child: TextField(
                              controller: dayNightOffestController,
                              key: UniqueKey(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            height: 25,
                            width: 75,
                          ),
                        ],
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      gravity = int.parse(gravityController.text);
                      acceleration = double.parse(accelerationController.text);
                      initialVelocity =
                          double.parse(runVelocityController.text);
                      jumpVelocity = double.parse(jumpVelocityController.text);
                      dayNightOffest = int.parse(dayNightOffestController.text);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Done"),
                    textColor: Colors.grey,
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
