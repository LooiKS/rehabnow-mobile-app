import 'package:flutter/cupertino.dart';

class DotLoadingIndicator extends StatefulWidget {
  final Color color;

  const DotLoadingIndicator({Key? key, required this.color}) : super(key: key);
  @override
  _DotLoadingIndicatorState createState() => _DotLoadingIndicatorState();
}

class _DotLoadingIndicatorState extends State<DotLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();
    _controller1 =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..repeat(reverse: true);
    _controller2 =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..forward(from: 0.3)
          ..repeat(reverse: true);
    _controller3 =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..forward(from: 0.5)
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        Container(
          width: 50,
          height: 50,
        ),
        Dot(
          controller: _controller3,
          left: 0,
          color: widget.color,
        ),
        Dot(
          controller: _controller2,
          left: 20,
          color: widget.color,
        ),
        Dot(
          controller: _controller1,
          left: 40,
          color: widget.color,
        ),
      ],
    );
  }
}

class Dot extends StatelessWidget {
  final double left;
  final Color color;
  const Dot({
    Key? key,
    required AnimationController controller,
    required this.left,
    required this.color,
  })   : _controller = controller,
        super(key: key);

  final AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: 10,
      height: 50,
      left: left,
      top: 0,
      child: AnimatedBuilder(
          animation: _controller,
          child: Container(
            width: 10,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          builder: (context, child) => FractionallySizedBox(
                child: child,
                widthFactor: 1,
                heightFactor: 0.5,
                alignment: AlignmentGeometryTween(
                        begin: Alignment(0, -1.5), end: Alignment(0, 0))
                    .chain(CurveTween(curve: Curves.easeOutCirc))
                    .evaluate(_controller)!,
              )),
    );
  }
}
