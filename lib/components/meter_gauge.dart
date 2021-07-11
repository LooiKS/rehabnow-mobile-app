import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MeterGauge extends StatelessWidget {
  final double percent;

  final Color? backgroundColor;

  final Color? color;
  const MeterGauge({
    Key? key,
    this.percent = 0,
    this.backgroundColor = Colors.black12,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CircularProgressIndicatorClipper(),
      child: Transform.rotate(
        angle: -pi * 3 / 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: CircularProgressIndicator(
            strokeWidth: 10,
            valueColor: AlwaysStoppedAnimation<Color>(color!),
            backgroundColor: backgroundColor,
            value: percent * 6 / 8,
          ),
        ),
      ),
    );
  }
}

class CircularProgressIndicatorClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..moveTo(size.width / 2, size.height / 2)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    Path circle = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ));
    return Path.combine(PathOperation.difference, circle, path);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
