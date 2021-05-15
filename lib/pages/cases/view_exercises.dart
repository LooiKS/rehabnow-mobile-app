import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewExercises extends StatefulWidget {
  @override
  _ViewExercisesState createState() => _ViewExercisesState();
}

class _ViewExercisesState extends State<ViewExercises> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exercises Records"),
        centerTitle: true,
      ),
      body: ListView.separated(
          itemBuilder: (context, index) => ListTile(
                leading: Text("${index + 1}"),
                minLeadingWidth: 20,
                subtitle: Text("[oscillation] | [time used]"),
                title: Text("[date time ${index + 1}]"),
                trailing: Icon(Icons.check),
              ),
          separatorBuilder: (context, index) => Divider(
                height: 0,
              ),
          itemCount: 20),
    );
  }
}
