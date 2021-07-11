import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/utils/dialog.dart';

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
  _CatchTheBugState createState() => _CatchTheBugState();
}

class _CatchTheBugState extends State<CatchTheBug> {
  late Timer timer;
  bool isPaused = false;
  BugState bugState = BugState.UPWARDS;
  double height = 0, width = 0, trashY = 50;
  StreamSubscription<double>? orientationStream;
  int posX = 200, posY = 0, score = 0, escaped = 0, oscillation = 0;

  @override
  void initState() {
    super.initState();
    isPaused = widget.pause;

    orientationStream = widget.stream?.listen((event) {
      if (!widget.pause) {
        setState(() {
          trashY = event * (height - 50);
        });
      }
    });
    timer = Timer.periodic(Duration(milliseconds: 25), _timerCallback);
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    orientationStream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    double iconSize = 30;
    height = screen.height - 80;
    width = screen.width - iconSize;

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: _buildActions(context),
        title: _buildScoreInfo(),
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
                  clipper: posX % 100 < 50 ? CatcherClipper() : null,
                  child: Container(
                    width: 50,
                    height: 50,
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

  void _timerCallback(x) {
    if (!widget.pause && !isPaused) {
      if (widget.target - widget.oscillation == 0) {
        isPaused = true;
        widget.onPaused();

        showAlertDialog(
            context: context,
            title: "Exercise Done",
            content:
                "Congratulations! You completed an exercise. Do you still want to continue?",
            confirmCallback: () {
              Navigator.of(context).pop();
              widget.onResume();
            },
            cancelCallback: () {
              Navigator.of(context).pop();
              widget.onSaved();
            });
      } else
        setState(() {
          posX -= 10;
          if (posX < 30) {
            posX = width.toInt();

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
            } else if (posY < 0) {
              posY = 0;
              bugState = BugState.DOWNWARDS;
            }
          }
        });
    }
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            widget.onPaused();
            showAlertDialog(
              context: context,
              title: "Confirmation",
              content: "Confirm to quit the exercise?",
              confirmCallback: () {
                widget.onSaved();
              },
              cancelText: "Cancel",
              cancelCallback: () {
                widget.onResume();
              },
            );
          },
          child: Text("STOP"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red)),
        ),
      ),
    ];
  }

  Row _buildScoreInfo() {
    return Row(
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
                Icon(Icons.rotate_left_outlined),
                Text("x ${widget.target}")
              ],
            ),
          ],
        ),
        Column(
          children: [
            Text(
              "Oscillations",
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
    );
  }
}

class CatcherClipper extends CustomClipper<Path> {
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
