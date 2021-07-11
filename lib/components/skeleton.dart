import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Skeleton extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final int lines;

  const Skeleton(
      {Key? key, required this.child, required this.isLoading, this.lines = 14})
      : super(key: key);
  @override
  _SkeletonState createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLoading
        ? Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                  width: MediaQuery.of(context).size.width,
                ),
                for (var i = 0; i < widget.lines; i++) ...[
                  SkeletonPart(
                      controller: _controller,
                      width: Random()
                          .nextInt(MediaQuery.of(context).size.width.toInt())
                          .toDouble()),
                  SizedBox(height: 20),
                ],
              ],
            ),
          )
        : widget.child;
  }
}

class SkeletonPart extends StatelessWidget {
  final double? width;

  const SkeletonPart({
    Key? key,
    required AnimationController controller,
    this.width,
  })  : _controller = controller,
        super(key: key);

  final AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 15,
          width: width,
          decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
        Positioned.fill(
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Color.fromARGB(0, 0, 0, 0),
                  Color.fromARGB(25, 0, 0, 0),
                  Color.fromARGB(0, 0, 0, 0),
                ])),
              ),
              builder: (context, child) => FractionallySizedBox(
                child: child,
                widthFactor: .3,
                heightFactor: 0.8,
                alignment: AlignmentGeometryTween(
                        begin: Alignment(-2.3, 0), end: Alignment(2.3, 0))
                    .chain(CurveTween(curve: Curves.ease))
                    .evaluate(_controller)!,
              ),
            ),
          ),
        )
      ],
    );
  }
}
