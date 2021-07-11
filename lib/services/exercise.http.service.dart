import 'dart:convert';

import 'package:http/http.dart';
import 'package:rehabnow_app/models/exercise.model.dart';
import 'package:rehabnow_app/models/response.model.dart';
import 'package:rehabnow_app/services/generic_http.dart';

const GET_EXERCISE = "get-exercises";
const UPLOAD_EXERCISE = "upload-exercise";
const GET_EXERCISES_RECORDS = "get-exercises-records";

Future<List<Exercise>> getExercisesByPartId(int partId) async {
  try {
    Response response = await httpGet("$GET_EXERCISE/$partId");
    List<dynamic> jsonDecoded = jsonDecode(response.body);
    return jsonDecoded.map((exercise) => Exercise.fromJson(exercise)).toList();
  } catch (e) {
    throw e;
  }
}

Future<List<ExerciseRecords>> getExercisesRecords() async {
  Response response = await httpGet(GET_EXERCISES_RECORDS);
  List<dynamic> jsonDecoded = jsonDecode(response.body);
  return jsonDecoded
      .map((exercise) => ExerciseRecords.fromJson(exercise))
      .toList();
}

Future<ResponseModel<dynamic>> uploadExercise(
    int partId, double timeTaken, int oscillationNum) async {
  Map<String, String> body = {
    "partId": partId.toString(),
    "timeTaken": timeTaken.toString(),
    "oscillationNum": oscillationNum.toString(),
  };
  Response response = await httpPost(UPLOAD_EXERCISE, body);
  Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
  return ResponseModel(
      jsonDecoded["data"], jsonDecoded["status"], jsonDecoded["errorMessage"]);
}
