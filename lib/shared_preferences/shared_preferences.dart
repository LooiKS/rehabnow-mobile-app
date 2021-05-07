import 'package:shared_preferences/shared_preferences.dart';

class RehabnowSharedPreferences {
  static SharedPreferences sharedPreferences;
  RehabnowSharedPreferences() {
    print("init");
    print(sharedPreferences);
  }

  bool get reminder => sharedPreferences.getBool("reminder");
  set reminder(value) => sharedPreferences.setBool("reminder", value);
  String get reminderTime => sharedPreferences.getString("reminderTime");
  set reminderTime(value) => sharedPreferences.setString("reminderTime", value);
  // set sharedPreferences(SharedPreferences sharedPreferences) {
  //   _sharedPreferences = sharedPreferences;
  // }

  // SharedPreferences get sharedPreferences => _sharedPreferences;
}
