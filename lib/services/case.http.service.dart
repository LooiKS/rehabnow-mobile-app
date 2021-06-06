import 'dart:convert';

import 'package:http/http.dart';
import 'package:rehabnow_app/models/case.model.dart';
import 'package:rehabnow_app/models/part.model.dart';
import 'package:rehabnow_app/services/generic_http.dart';

const String CASES = "get-cases";
const String PARTS = "get-parts";

Future<List<Case>> getAllCases({String? status}) async {
  Response response =
      await httpGet("$CASES${status == null ? '' : '?status=$status'}");
  List<dynamic> jsonDecoded = json.decode(response.body);
  return jsonDecoded.map((data) => Case.fromJson(data)).toList();
}

Future<List<Part>> getAllParts(int caseId) async {
  Response response = await httpGet("$PARTS/$caseId");
  List<dynamic> jsonDecoded = json.decode(response.body);
  return jsonDecoded.map((data) => Part.fromJson(data)).toList();
}
