import 'package:rehabnow_app/models/error.model.dart';

class UserFormError {
  List<FormError>? first_name;
  List<FormError>? last_name;
  List<FormError>? dob;
  List<FormError>? gender;
  List<FormError>? ic_passport;
  List<FormError>? nationality;
  List<FormError>? country;
  List<FormError>? phone_num;
  List<FormError>? city;
  List<FormError>? state;
  List<FormError>? postcode;
  List<FormError>? address;
  List<FormError>? current_password;
  List<FormError>? new_password;

  UserFormError.blank();

  UserFormError(
    this.first_name,
    this.last_name,
    this.dob,
    this.gender,
    this.ic_passport,
    this.nationality,
    this.country,
    this.phone_num,
    this.city,
    this.state,
    this.postcode,
    this.address,
    this.current_password,
    this.new_password,
  );

  UserFormError.fromJson(dynamic data)
      : this(
          data["first_name"]
              ?.map<FormError>((error) => FormError.fromJson(error))
              .toList(),
          data["last_name"]
              ?.map<FormError>((error) => FormError.fromJson(error))
              .toList(),
          data["dob"]
              ?.map<FormError>((error) => FormError.fromJson(error))
              .toList(),
          data["gender"]
              ?.map<FormError>((error) => FormError.fromJson(error))
              .toList(),
          data["ic_passport"]
              ?.map<FormError>((error) => FormError.fromJson(error))
              .toList(),
          data["nationality"]
              ?.map<FormError>((error) => FormError.fromJson(error))
              .toList(),
          data["country"]
              ?.map<FormError>((error) => FormError.fromJson(error))
              .toList(),
          data["phone_num"]
              ?.map<FormError>((error) => FormError.fromJson(error))
              .toList(),
          data["city"]
              ?.map<FormError>((error) => FormError.fromJson(error))
              .toList(),
          data["state"]
              ?.map<FormError>((error) => FormError.fromJson(error))
              .toList(),
          data["postcode"]
              ?.map<FormError>((error) => FormError.fromJson(error))
              .toList(),
          data["address"]
              ?.map<FormError>((error) => FormError.fromJson(error))
              .toList(),
          data["current_password"]
              ?.map<FormError>((error) => FormError.fromJson(error))
              .toList(),
          data["new_password"]
              ?.map<FormError>((error) => FormError.fromJson(error))
              .toList(),
        );
}
