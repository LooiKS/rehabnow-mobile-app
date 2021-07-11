import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/utils/dialog.dart';

const double MOUNTAIN_WIDTH = 125;

class VirtualRect {
  double x;
  double y;
  double w;
  double h;

  VirtualRect(this.x, this.y, this.w, this.h);

  double get left => x;
  double get right => x + w;
  double get top => y;
  double get bottom => y + h;
  bool isCollide(VirtualRect other) =>
      this.right >= other.left &&
          this.right <= other.right &&
          this.bottom >= other.top &&
          this.bottom <= other.bottom ||
      this.right >= other.left &&
          this.right <= other.right &&
          this.top >= other.top &&
          this.top <= other.bottom ||
      this.left >= other.left &&
          this.left <= other.right &&
          this.bottom >= other.top &&
          this.bottom <= other.bottom ||
      this.left >= other.left &&
          this.left <= other.right &&
          this.top >= other.top &&
          this.top <= other.bottom;
}

class SkipTheHurdlesGame extends StatefulWidget {
  final Stream<double>? stream;
  final Null Function() onSaved;
  final int oscillation;
  final int target;
  final bool pause;
  final Null Function() onPaused;
  final Null Function() onResume;

  const SkipTheHurdlesGame({
    Key? key,
    this.stream,
    required this.onSaved,
    required this.oscillation,
    required this.target,
    required this.pause,
    required this.onPaused,
    required this.onResume,
  }) : super(key: key);
  @override
  _SkipTheHurdlesGameState createState() => _SkipTheHurdlesGameState();
}

class _SkipTheHurdlesGameState extends State<SkipTheHurdlesGame> {
  late Timer timer;
  double lowerMountainX = 250.0,
      lowerMountainY = 0.0,
      lowerMountainHeight = 250,
      lowerOpacity = 1.0;
  double upperMountainX = 750.0,
      upperMountainY = 0.0,
      upperMountainHeight = 350,
      upperOpacity = 1.0;
  double birdX = 45, birdY = 0.0;
  double height = 0, width = 0;
  int collide = 0, oscillation = 0;
  StreamSubscription<double>? orientationStream;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    orientationStream = widget.stream?.listen((event) {
      if (!widget.pause) {
        setState(() {
          birdY = event * (height - 50);
        });
      }
    });

    timer = Timer.periodic(Duration(milliseconds: 100), _timerCallback);
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    orientationStream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    lowerMountainHeight = height * 0.8;
    upperMountainHeight = height * 0.8;
    lowerMountainY = height - lowerMountainHeight;

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: Text(
            "Collision: $collide  | Target: ${widget.target} | \nOscillation: ${widget.oscillation}"),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: _buildActions(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        child: Stack(
          children: [
            Positioned(
              top: lowerMountainY,
              left: lowerMountainX,
              child: Opacity(
                opacity: lowerOpacity > 0 ? lowerOpacity : 0,
                child: CustomPaint(
                  foregroundPainter: MyPainter(),
                  child: Container(
                    width: MOUNTAIN_WIDTH,
                    height: lowerMountainHeight,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: upperMountainX,
              child: Transform.rotate(
                angle: pi,
                child: Opacity(
                  opacity: upperOpacity > 0 ? upperOpacity : 0,
                  child: CustomPaint(
                    foregroundPainter: MyPainter(),
                    child: Container(
                      width: MOUNTAIN_WIDTH,
                      height: upperMountainHeight,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: birdY,
              height: 100,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(pi),
                child: Container(
                  child: Image.asset(
                    "assets/images/2d_bird.gif",
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _timerCallback(timer) {
    VirtualRect bottomMountain = VirtualRect(
        lowerMountainX + MOUNTAIN_WIDTH / 4,
        lowerMountainY,
        MOUNTAIN_WIDTH / 2,
        lowerMountainHeight);
    VirtualRect topMountain = VirtualRect(upperMountainX + MOUNTAIN_WIDTH / 4,
        upperMountainY, MOUNTAIN_WIDTH / 2, upperMountainHeight - 50);
    VirtualRect bird = VirtualRect(birdX, birdY, 50, 50);

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
              widget.onResume();
            },
            cancelCallback: () {
              Navigator.of(context).pop();
              widget.onSaved();
            });
      } else {
        if (bird.isCollide(bottomMountain) && lowerOpacity == 1.0) {
          collide++;
          lowerOpacity -= 0.1;
        }

        if (bird.isCollide(topMountain) && upperOpacity == 1.0) {
          collide++;
          upperOpacity -= 0.1;
        }

        setState(() {
          if (lowerOpacity != 1.0) {
            lowerOpacity -= 0.1;
          }
          if (upperOpacity != 1.0) {
            upperOpacity -= 0.1;
          }
          if (lowerMountainX < -(MOUNTAIN_WIDTH + 500)) {
            lowerMountainX = width;
            upperMountainX = width + 500;
            lowerOpacity = upperOpacity = 1.0;
          }

          lowerMountainX -= 10;
          upperMountainX -= 10;
        });
      }
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
                });
          },
          child: Text("STOP"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red)),
        ),
      ),
    ];
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.greenAccent;

    double w = size.width * 0.5;
    double h = w * 0.8;

    Path path = Path()
      ..addRect(Rect.fromLTWH((size.width - w) / 2, h, w, size.height - h))
      ..addRRect(RRect.fromLTRBR(0, 0, size.width, h, Radius.circular(5)));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
