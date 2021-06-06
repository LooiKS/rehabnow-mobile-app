import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/components/skeleton.dart';
import 'package:rehabnow_app/models/exercise.model.dart';
import 'package:rehabnow_app/services/exercise.http.service.dart';
import 'package:rehabnow_app/utils/time.constant.dart';

class ViewExercises extends StatefulWidget {
  final int partId;

  const ViewExercises({Key? key, required this.partId}) : super(key: key);

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
      body: FutureBuilder<List<Exercise>>(
          future: getExercisesByPartId(widget.partId),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? snapshot.data?.isEmpty ?? false
                    ? Card(
                        child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            "No exercise found.",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ))
                    : ListView.separated(
                        itemBuilder: (context, index) => ListTile(
                              leading: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "${index + 1}",
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              minLeadingWidth: 20,
                              title: Text(DATETIME_FORMAT.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      snapshot.data?[index].createdDt ?? 0))),
                              subtitle: Text(
                                  "${snapshot.data?[index].oscillationNum} oscillations | ${snapshot.data?[index].timeTaken} seconds used"),
                              trailing: Icon(
                                snapshot.data?[index].done ?? false
                                    ? Icons.check
                                    : Icons.close,
                                color: snapshot.data?[index].done ?? false
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                        separatorBuilder: (context, index) => Divider(
                              height: 0,
                            ),
                        itemCount: snapshot.data?.length ?? 0)
                : Skeleton(
                    child: Container(),
                    isLoading: true,
                    lines: 5,
                  );
          }),
    );
  }
}
