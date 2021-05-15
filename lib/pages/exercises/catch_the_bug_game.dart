import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum BugState { UPWARDS, DOWNWARDS }

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  int posX = 200, posY = 0, score = 0, escaped = 0, oscillation = 10;
  Timer timer;
  double height = 0, width = 0, trashY = 50;
  BugState bugState = BugState.UPWARDS;
  bool isPaused = false;
  BuildContext _context;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 25), (x) {
      if (!isPaused) {
        if (oscillation == 0) {
          isPaused = true;
          // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          showDialog(
              context: _context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                    title: Text("Exercise Done"),
                    content:
                        Text("Congratulations! You completed an exercise."),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: Text("OK"))
                    ],
                  ));
          // });
        } else
          setState(() {
            posX -= 10;
            if (posX < 30) {
              posX = width.toInt();
              print(trashY);
              print(posY);
              if ((trashY - posY).abs() <= 20)
                score++;
              else
                escaped++;
              switch (bugState) {
                case BugState.UPWARDS:
                  posY = posY - Random().nextInt(200) * 5;
                  break;
                case BugState.DOWNWARDS:
                  posY = posY + Random().nextInt(200) * 5;
                  break;
              }

              if (posY > height) {
                posY = height.toInt();
                bugState = BugState.UPWARDS;
                oscillation--;
              } else if (posY < 0) {
                posY = 0;
                bugState = BugState.DOWNWARDS;
              }
            }
          });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    Size screen = MediaQuery.of(context).size;
    double iconSize = 30; //IconTheme.of(context).size;
    height = screen.height - 56 - iconSize * 2;
    width = screen.width - iconSize;
    int layers = height ~/ iconSize;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isPaused = true;
                });
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                          title: Text("Confirmation"),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          content: Text("Confirm to quit the exercise?"),
                          actions: [
                            FlatButton(
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  isPaused = false;
                                });
                              },
                              color: Colors.yellow,
                            ),
                            ElevatedButton(
                              child: Text("Yes"),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ));
                // Navigator.of(context).pop();
              },
              child: Text("STOP"),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red)),
            ),
          ),
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  "Excaped ",
                  style: TextStyle(fontSize: 13),
                ),
                Row(
                  children: [Icon(Icons.bug_report), Text("x $escaped")],
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  "Caught ",
                  style: TextStyle(fontSize: 13),
                ),
                Row(
                  children: [Icon(Icons.bug_report), Text("x $score")],
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  "Remaining Oscillations",
                  style: TextStyle(fontSize: 13),
                ),
                Row(
                  children: [
                    Icon(Icons.rotate_left_outlined),
                    Text("x $oscillation")
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                child: Text("U P"),
                onPressed: () {
                  setState(() => trashY = trashY - 5 > 0 ? trashY - 5 : trashY);
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                child: Text("D O W N ${posX}"),
                onPressed: () {
                  setState(() =>
                      trashY = trashY + 20 < height ? trashY + 10 : trashY);
                }),
          ),
        ],
      ),
      body: Container(
        child: Stack(
          children: [
            Positioned(
                child: Transform.rotate(
                  angle: pi / 2 * 3,
                  child: Icon(
                    posX % 100 > 49
                        ? Icons.bug_report_outlined
                        : Icons.bug_report,
                    size: 30,
                  ),
                ),
                left: posX.toDouble(),
                top: posY.toDouble()),
            Positioned(
                left: 20,
                top: trashY,
                child: ClipPath(
                  clipper: posX % 100 < 50 ? MyClipper() : null,
                  child: Container(
                    width: 50,
                    height: 50,
                    // color: Colors.amber,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber,
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width / 2 + 5, size.height / 2);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    Path circle = Path();
    circle.addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2));
    return Path.combine(PathOperation.difference, circle, path);
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return false;
  }
}
/*
  height / iconSize => layers number
  width / iconSize => movement layers (not neccessary)

 */
