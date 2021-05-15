import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/pages/exercises/catch_the_bug_game.dart';
import 'package:rehabnow_app/pages/exercises/skip_the_hurdles.dart';

class Exercises extends StatefulWidget {
  @override
  _ExercisesState createState() => _ExercisesState();
}

class _ExercisesState extends State<Exercises> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exercises"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Container(
          child: Column(
            children: [
              _ChoiceChipWithIcon(
                selected: selected,
                index: 0,
                onSelected: (i) => setState(() => selected = 0),
              ),
              ChoiceChip(
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Case #2"),
                    selected == 1 ? Icon(Icons.check_rounded) : Container(),
                  ],
                ),
                selected: selected == 1,
                onSelected: (i) => setState(() => selected = 1),
              ),
              ChoiceChip(
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Case #3"),
                    selected == 2 ? Icon(Icons.check_rounded) : Container(),
                  ],
                ),
                selected: selected == 2,
                onSelected: (i) => setState(() => selected = 2),
              ),
              ElevatedButton(
                child: Text("Start"),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SkipTheHurdlesGame()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceChipWithIcon extends StatelessWidget {
  const _ChoiceChipWithIcon({
    Key key,
    @required this.selected,
    @required this.index,
    @required this.onSelected,
  }) : super(key: key);

  final int selected;
  final int index;
  final Function(bool) onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Case #1"),
          selected == 0 ? Icon(Icons.check_rounded) : Container(),
        ],
      ),
      selected: selected == 0,
      onSelected: (i) => onSelected(i),
    );
  }
}
