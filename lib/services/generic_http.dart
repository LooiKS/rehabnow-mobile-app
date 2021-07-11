import 'package:http/http.dart' as http;
import 'package:rehabnow_app/utils/flutter_secure_storage.dart';

// const String BASE = "http://10.0.2.2:8000";
// const String BASE = "http://127.0.0.1:8000";
const String BASE = "https://rehabnow.herokuapp.com";
const String MEDIA_URL = "$BASE/media/";
const String BASE_URL = "$BASE/api/";

Future<http.Response> httpGet(String url) async {
  String? token = await RehabnowFlutterSecureStorage.storage.read(key: "token");
  http.Response response = await http.get(
    Uri.parse(BASE_URL + url),
    headers: {"Authorization": token == null ? "" : "Token $token"},
  ).catchError((e) {
    print(e);
  });
  print(response);
  return response;
}

Future<http.Response> httpPost(String url, Map<String, Object>? body) async {
  String? token = await RehabnowFlutterSecureStorage.storage.read(key: "token");
  http.Response response = await http.post(
    Uri.parse(BASE_URL + url),
    body: body,
    headers: {"Authorization": token == null ? "" : "Token $token"},
  );
  print(response.body);
  return response;
}

Future<http.StreamedResponse> httpPostMultipart(
    String url, Map<String, String>? body, Map<String, String>? files) async {
  body = body?.map((key, value) {
    return MapEntry(key, value.trim());
  });

  http.MultipartRequest multipartRequest =
      http.MultipartRequest("POST", Uri.parse(BASE_URL + url));
  String? token = await RehabnowFlutterSecureStorage.storage.read(key: "token");

  multipartRequest.headers
      .putIfAbsent("Authorization", () => token == null ? "" : "Token $token");

  multipartRequest.fields.addAll(body ?? Map());

  files?.forEach((key, value) async {
    multipartRequest.files.add(await http.MultipartFile.fromPath(key, value));
  });

  return multipartRequest.send();
}
