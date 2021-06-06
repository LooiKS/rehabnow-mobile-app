import 'package:rehabnow_app/models/target.model.dart';

class Exercise {
  int createdDt;
  int oscillationNum;
  double timeTaken;
  int partId;
  bool done;

  Exercise(this.createdDt, this.done, this.oscillationNum, this.partId,
      this.timeTaken);

  Exercise.fromJson(dynamic data)
      : this(
          data["created_dt"],
          data["done"],
          data["oscillation_num"],
          data["part_id"],
          data["time_taken"],
        );
}

class ExerciseRecords {
  String partName;
  String caseName;
  List<ExerciseData> exercises;
  List<Target> targets;

  ExerciseRecords(this.partName, this.caseName, this.exercises, this.targets);

  ExerciseRecords.fromJson(dynamic data)
      : this(
          data["part_name"],
          data["case_name"],
          (data["exercises"] as List)
              .map((exercise) => ExerciseData.fromJson(exercise))
              .toList(),
          (data["targets"] as List)
              .map((target) => Target.fromJson(target))
              .toList(),
        );
}

class ExerciseData {
  int dateTime;
  int oscillation;
  ExerciseData(this.dateTime, this.oscillation);
  ExerciseData.fromJson(dynamic data)
      : this(data["date_time"], data["oscillation_num"]);
}
