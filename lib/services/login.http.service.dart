import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:rehabnow_app/models/login.model.dart';
import 'package:rehabnow_app/models/response.model.dart';
import 'package:rehabnow_app/services/generic_http.dart' as httpService;
import 'package:rehabnow_app/utils/flutter_secure_storage.dart';

const String LOGIN = "login";
const String LOGOUT = "logout";
const String RESET_PASSWORD = "reset-password";

Future<ResponseModel<LoginData>> login(String email, String password) async {
  HashMap<String, String> body = HashMap<String, String>();
  body["email"] = email.trim();
  body["password"] = password.trim();
  Response response = await httpService.httpPost(LOGIN, body);
  Map<String, dynamic> jsonDecoded = json.decode(response.body);
  ResponseModel<LoginData> responseModel = ResponseModel(
      LoginData.fromJson(jsonDecoded["data"] ?? Map()),
      jsonDecoded["status"],
      jsonDecoded["errorMessage"]);
  return Future.value(responseModel);
}

Future<void> logout() async {
  httpService.httpPost(LOGOUT, null);
  return await RehabnowFlutterSecureStorage.storage.delete(key: "token");
}

Future<ResponseModel<Null>> resetPassword(String email) async {
  Response response =
      await httpService.httpPost(RESET_PASSWORD, {"email": email});
  Map<String, dynamic> jsonDecoded = json.decode(response.body);
  ResponseModel<Null> responseModel =
      ResponseModel(null, jsonDecoded["status"], jsonDecoded["errorMessage"]);
  return responseModel;
}
