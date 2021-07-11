import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotFoundCenter extends StatelessWidget {
  final String text;

  final bool happy;

  const NotFoundCenter({
    Key? key,
    required this.text,
    this.happy = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            happy ? "assets/images/party.png" : "assets/images/not-found.png",
            width: 200,
            color: Colors.blue,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
