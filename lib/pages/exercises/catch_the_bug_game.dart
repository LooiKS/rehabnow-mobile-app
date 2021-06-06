import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rehabnow_app/main.dart';
import 'package:rehabnow_app/utils/loading.dart';

enum BugState { UPWARDS, DOWNWARDS }

class CatchTheBug extends StatefulWidget {
  final Stream<double>? stream;
  final Null Function() onSaved;
  final bool pause;
  final Null Function() onPaused;
  final Null Function() onResume;
  final int oscillation;
  final int target;

  const CatchTheBug({
    Key? key,
    this.stream,
    required this.onSaved,
    required this.pause,
    required this.onPaused,
    required this.onResume,
    required this.oscillation,
    required this.target,
  }) : super(key: key);
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<CatchTheBug> {
  int posX = 200, posY = 0, score = 0, escaped = 0, oscillation = 0;
  late Timer timer;
  double height = 0, width = 0, trashY = 50;
  BugState bugState = BugState.UPWARDS;
  bool isPaused = false;
  late BuildContext _context;

  bool reachTop = false;
  Stream<double> streamOrientation() async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: 500));
      yield Random().nextInt(180) - 90;
    }
  }

  StreamSubscription<double>? ss;

  @override
  void initState() {
    super.initState();
    isPaused = widget.pause;
    // ss?.cancel();
    ss = widget.stream?.listen((event) {
      // print(event);
      if (!widget.pause) {
        setState(() {
          trashY = (event + 90) / 180 * (height - 50);
        });
      }
    });
    timer = Timer.periodic(Duration(milliseconds: 25), (x) {
      print(widget.pause);
      if (!widget.pause && !isPaused) {
        if (widget.target - widget.oscillation == 0) {
          isPaused = true;
          widget.onPaused();
          // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          print("trigger dialog");
          showAlertDialog(
              context: _context,
              title: "Exercise Done",
              content:
                  "Congratulations! You completed an exercise. Do you still want to continue?",
              // barrierDismissible: false,
              confirmCallback: () {
                Navigator.of(context).pop();
                widget.onResume();
              },
              cancelCallback: () {
                Navigator.of(context).pop();
                widget.onSaved();
              });
          // });
        } else
          setState(() {
            posX -= 10;
            if (posX < 30) {
              posX = width.toInt();
              // print(trashY);
              // print(posY);
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

              if (posY > height - 30) {
                posY = height.toInt();
                bugState = BugState.UPWARDS;
                // oscillation--;
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
    ss?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    Size screen = MediaQuery.of(context).size;
    double iconSize = 30; //IconTheme.of(context).size;
    height = screen.height - 80;
    width = screen.width - iconSize;
    int layers = height ~/ iconSize;

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                widget.onPaused();
                // setState(() {
                //   isPaused = true;
                // });
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
                                widget.onResume();

                                // setState(() {
                                //   isPaused = false;
                                // });
                              },
                              color: Colors.yellow,
                            ),
                            ElevatedButton(
                              child: Text("Yes"),
                              onPressed: () {
                                Navigator.pop(context);
                                // Navigator.pop(context);
                                widget.onSaved();
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
                  "Target ",
                  style: TextStyle(fontSize: 13),
                ),
                Row(
                  children: [
                    Icon(Icons.bug_report),
                    Text("x ${widget.target}")
                  ],
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
                    Text("x ${widget.oscillation}")
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: ElevatedButton(
      //           child: Text("U P"),
      //           onPressed: () {
      //             // ss?.cancel();

      //             setState(() => trashY = trashY - 5 > 0 ? trashY - 5 : trashY);
      //           }),
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: ElevatedButton(
      //           child: Text("D O W N ${posX}"),
      //           onPressed: () {
      //             setState(() =>
      //                 trashY = trashY + 20 < height ? trashY + 10 : trashY);
      //           }),
      //     ),
      //   ],
      // ),
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
                      color: Colors.lime,
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
