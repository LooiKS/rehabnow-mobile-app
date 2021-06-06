import 'package:rehabnow_app/models/user.model.dart';

class LoginData {
  User? user;
  String? token;

  LoginData(this.user, this.token);

  LoginData.fromJson(dynamic json)
      : this(User.fromJson(json["user"] == null ? Map() : json["user"]),
            json["token"]);
}
