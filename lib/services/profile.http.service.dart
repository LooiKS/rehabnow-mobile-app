import 'dart:convert';

import 'package:http/http.dart';
import 'package:rehabnow_app/models/city.model.dart';
import 'package:rehabnow_app/models/country.model.dart';
import 'package:rehabnow_app/models/error.model.dart';
import 'package:rehabnow_app/models/response.model.dart';
import 'package:rehabnow_app/models/state.model.dart';
import 'package:rehabnow_app/models/user.model.dart';
import 'package:rehabnow_app/models/user_form.error.model.dart';
import 'package:rehabnow_app/services/generic_http.dart';

const String PROFILE = "get-profile";
const String GET_COUNTRIES = "get-countries";
const String GET_STATES = "get-states";
const String GET_CITIES = "get-cities";
const String SAVE_PROFILE = "save-profile";

Future<User> getProfile() async {
  Response response = await httpGet(PROFILE);
  Map<String, dynamic> jsonDecoded = json.decode(response.body);
  // print(response.body);
  User responseModel = User.fromJson(jsonDecoded);
  return responseModel;
}

Future<ResponseModel<UserFormError>> saveProfile(
    User user, String? currentPassword, String? newPassword) async {
  Map<String, String> body = user.toJson();
  body.putIfAbsent("current_password", () => currentPassword ?? "");
  body.putIfAbsent("new_password", () => newPassword ?? "");
  Map<String, String>? files =
      user.photo == null ? null : {"photo": user.photo!};
  StreamedResponse sr = await httpPostMultipart(SAVE_PROFILE, body, files);
  Map<String, dynamic> jsonDecoded =
      json.decode(await sr.stream.bytesToString());
  ResponseModel<UserFormError> responseModel = ResponseModel(
      UserFormError.fromJson(jsonDecoded["data"]["errors"]),
      jsonDecoded["status"],
      jsonDecoded["errorMessage"]);
  return responseModel;
}

Future<List<Country>> getCountries() async {
  Response response = await httpGet(GET_COUNTRIES);
  List<dynamic> jsonDecoded = json.decode(response.body);
  return jsonDecoded
      .map<Country>((country) => Country.fromJson(country))
      .toList();
}

Future<List<ResidentialState>> getStatesByIso2(String iso2) async {
  Response response = await httpGet("$GET_STATES/$iso2");
  List<dynamic> jsonDecoded = json.decode(response.body);
  return jsonDecoded.map((state) => ResidentialState.fromJson(state)).toList();
}

Future<List<City>> getCitiesByStateId(int stateId) async {
  Response response = await httpGet("$GET_CITIES/$stateId");
  List<dynamic> jsonDecoded = json.decode(response.body);
  return jsonDecoded.map((city) => City.fromJson(city)).toList();
}
