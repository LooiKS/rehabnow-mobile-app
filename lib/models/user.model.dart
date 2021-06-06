import 'package:intl/intl.dart' show DateFormat;

class User {
  String? id;
  String? lastLogin;
  String? email;
  String? createdDt;
  int? dob;
  String? firstName;
  String? gender;
  String? icPassport;
  String? lastName;
  String? nationality;
  String? phoneNum;
  String? status;
  String? photo;
  bool? isAdmin;
  String? city;
  String? country;
  int? state;
  String? postcode;
  String? address;
  String? fullState;
  String? fullCountry;
  String? fullNationality;

  User(
    this.id,
    this.lastLogin,
    this.email,
    this.createdDt,
    this.dob,
    this.firstName,
    this.gender,
    this.icPassport,
    this.lastName,
    this.nationality,
    this.phoneNum,
    this.status,
    this.photo,
    this.isAdmin,
    this.city,
    this.country,
    this.state,
    this.postcode,
    this.address,
  );

  User.fromJson(Map<String, dynamic>? json)
      : id = json!["id"],
        lastLogin = json["last_login"],
        email = json["email"],
        createdDt = json["created_dt"],
        dob = json["dob"],
        firstName = json["first_name"],
        gender = json["gender"],
        icPassport = json["ic_passport"],
        lastName = json["last_name"],
        nationality = json["nationality"],
        phoneNum = json["phone_num"],
        status = json["status"],
        photo = json["photo"],
        isAdmin = json["is_admin"],
        city = json["city"],
        country = json["country"],
        state = json["state"],
        postcode = json["postcode"],
        address = json["address"],
        fullState = json["full_state"],
        fullCountry = json["full_country"],
        fullNationality = json["full_nationality"];

  Map<String, String> toJson() => {
        'first_name': firstName!,
        'last_name': lastName!,
        'dob': DateFormat("yyyy-MM-dd")
            .format(DateTime.fromMillisecondsSinceEpoch(dob!)),
        'gender': gender!,
        'ic_passport': icPassport!,
        'nationality': nationality!,
        'country': country!,
        'phone_num': phoneNum!,
        'city': city!,
        'state': state.toString(),
        'postcode': postcode!,
        'address': address!
      };

  @override
  bool operator ==(covariant User other) {
    return id == other.id &&
        lastLogin == other.lastLogin &&
        email == other.email &&
        createdDt == other.createdDt &&
        dob == other.dob &&
        firstName == other.firstName &&
        gender == other.gender &&
        icPassport == other.icPassport &&
        lastName == other.lastName &&
        nationality == other.nationality &&
        phoneNum == other.phoneNum &&
        status == other.status &&
        (photo == null || photo == other.photo) &&
        isAdmin == other.isAdmin &&
        city == other.city &&
        country == other.country &&
        state == other.state &&
        postcode == other.postcode &&
        address == other.address;
  }

  @override
  int get hashCode => super.hashCode;
}
