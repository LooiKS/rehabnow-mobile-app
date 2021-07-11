import 'package:shared_preferences/shared_preferences.dart';

class RehabnowSharedPreferences {
  static SharedPreferences? sharedPreferences;
  RehabnowSharedPreferences();

  bool? get reminder => sharedPreferences!.getBool("reminder");
  set reminder(value) => sharedPreferences!.setBool("reminder", value);

  String? get reminderTime => sharedPreferences!.getString("reminderTime");
  set reminderTime(value) =>
      sharedPreferences!.setString("reminderTime", value);

  String? get leftArmDevice => sharedPreferences!.getString("leftArmDevice");
  set leftArmDevice(value) =>
      sharedPreferences!.setString("leftArmDevice", value);

  String? get rightArmDevice => sharedPreferences!.getString("rightArmDevice");
  set rightArmDevice(value) =>
      sharedPreferences!.setString("rightArmDevice", value);

  String? get leftLegDevice => sharedPreferences!.getString("leftLegDevice");
  set leftLegDevice(value) =>
      sharedPreferences!.setString("leftLegDevice", value);

  String? get rightLegDevice => sharedPreferences!.getString("rightLegDevice");
  set rightLegDevice(value) =>
      sharedPreferences!.setString("rightLegDevice", value);
}
