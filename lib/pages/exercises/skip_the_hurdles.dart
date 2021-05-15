import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  @override
  _SkipTheHurdlesGameState createState() => _SkipTheHurdlesGameState();
}

class _SkipTheHurdlesGameState extends State<SkipTheHurdlesGame> {
  double lowerMountainX = 50.0,
      lowerMountainY = 0.0,
      lowerMountainHeight = 250,
      lowerOpacity = 1.0;
  double upperMountainX = 550.0,
      upperMountainY = 0.0,
      upperMountainHeight = 350,
      upperOpacity = 1.0;

  double birdX = 45, birdY = 0.0;

  // screen
  double height = 0, width = 0;
  Timer timer;
  String state = "";
  int collide = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      VirtualRect bottomMountain = VirtualRect(
          lowerMountainX + MOUNTAIN_WIDTH / 4,
          lowerMountainY,
          MOUNTAIN_WIDTH / 2,
          lowerMountainHeight);
      VirtualRect topMountain = VirtualRect(upperMountainX + MOUNTAIN_WIDTH / 4,
          upperMountainY, MOUNTAIN_WIDTH / 2, upperMountainHeight);
      VirtualRect bird = VirtualRect(birdX, birdY, 50, 50);

      print(
          "${bird.right} >= ${bottomMountain.left} && ${bird.right} <= ${bottomMountain.right} && ${bird.bottom} >= ${bottomMountain.top} && ${bird.bottom} <= ${bottomMountain.bottom}");

      if (bird.isCollide(bottomMountain) && lowerOpacity == 1.0) {
        collide++;
        print("Crash bottom mountain");
        lowerOpacity -= 0.1;
      }

      if (bird.isCollide(topMountain) && upperOpacity == 1.0) {
        collide++;
        print("Crash mountain");
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
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height - 80;
    width = MediaQuery.of(context).size.width;

    lowerMountainHeight = height * 0.8;
    upperMountainHeight = height * 0.8;
    lowerMountainY = height - lowerMountainHeight;

    // print(AppBarTheme.of(context));

    return Scaffold(
      appBar: AppBar(
        title: Text("Collision: $collide"),
        actions: [ElevatedButton(onPressed: () => {}, child: Text("Stop"))],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                child: Text("UP ${birdY}"),
                onPressed: () {
                  print(
                      "Bird: Left: 25, Top: ${birdY + 20}, Right: ${25 + 50}, Bottom: ${birdY + 20 + 50}");
                  double y = 0;
                  // if (mx > -(mountainWidth / 2 - 45)) {
                  //   y = (mountainHeight / (mountainWidth / 2)) * (45) +
                  //       (mountainHeight /
                  //           (mountainWidth / 2) *
                  //           -(mx)); // y2 = 1.25 * -mx
                  //   state = birdY > y ? "safe" : "crash";
                  // } else {
                  //   y = (mountainHeight / -(mountainWidth / 2)) * (45) +
                  //       (mountainHeight /
                  //           -(mountainWidth / 2) *
                  //           -(mx +
                  //               (mountainWidth / 2) +
                  //               45)); // y2 = 1.25 * -mx
                  // }
                  setState(() {
                    birdY = birdY - 1 < -500 ? birdY : birdY - 10;
                    state = birdY > y ? "safe" : "crash";
                    print(state);
                  });
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                child: Text("DOWN $height"),
                onPressed: () {
                  double y = 0;
                  setState(() {
                    birdY = birdY > height ? birdY : birdY + 10;
                    state = birdY > y ? "safe" : "crash";
                    print(state);
                  });
                }),
          ),
        ],
      ),
      body: Container(
        child: Stack(
          children: [
            Positioned(
              top: birdY,
              left: 25,
              child: Container(
                width: 50,
                height: 50,
                color: Colors.amber,
              ),
            ),
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
              // bottom: my,
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
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // print(size.width);
    Paint paint = Paint()..color = Colors.green;

    double w = size.width * 0.5;
    double h = w * 0.8;

    Path path = Path()
      ..addRect(Rect.fromLTWH((size.width - w) / 2, h, w, size.height - h))
      ..addRRect(RRect.fromLTRBR(0, 0, size.width, h, Radius.circular(5)));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
