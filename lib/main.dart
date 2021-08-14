import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/constants/routes.constant.dart';
import 'package:rehabnow_app/models/case.model.dart';
import 'package:rehabnow_app/models/user.model.dart';
import 'package:rehabnow_app/pages/cases/view_case.dart';
import 'package:rehabnow_app/pages/cases/view_cases.dart';
import 'package:rehabnow_app/pages/cases/view_exercises.dart';
import 'package:rehabnow_app/pages/connection/connection.dart';
import 'package:rehabnow_app/pages/exercises/exercises.dart';
import 'package:rehabnow_app/pages/exercises/game.dart';
import 'package:rehabnow_app/pages/prelogin/reset_password.dart';
import 'package:rehabnow_app/pages/prelogin/login.dart';
import 'package:rehabnow_app/pages/home/main_page.dart';
import 'package:rehabnow_app/pages/profile/edit_profile.dart';
import 'package:rehabnow_app/pages/profile/view_profile.dart';
import 'package:rehabnow_app/pages/reminder/view_reminder.dart';
import 'package:rehabnow_app/services/profile.http.service.dart';
import 'package:rehabnow_app/utils/flutter_secure_storage.dart';
import 'package:rehabnow_app/utils/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  print(await FlutterNativeTimezone.getLocalTimezone());
  tz.setLocalLocation(
      tz.getLocation(await FlutterNativeTimezone.getLocalTimezone()));

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);

  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: selectNotification,
  );
  SharedPreferences.getInstance()
      .then((value) => RehabnowSharedPreferences.sharedPreferences = value);

  runApp(RehabNowApp());
}

Future selectNotification(String? payload) async {
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
}

Future onDidReceiveLocalNotification(
    int i, String? s1, String? s2, String? s3) async {}

class RehabNowApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RehabNow',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        primaryColor: Color.fromRGBO(100, 5, 190, 1),
        primaryIconTheme: IconThemeData(color: Colors.white),
        primaryTextTheme: TextTheme(headline6: TextStyle(color: Colors.white)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.white),
            backgroundColor: MaterialStateProperty.all(
              Color.fromRGBO(100, 5, 190, 1),
            ),
          ),
        ),
        snackBarTheme:
            SnackBarThemeData(backgroundColor: Color.fromRGBO(100, 5, 190, 1)),
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
          centerTitle: true,
          backgroundColor: Color.fromRGBO(100, 5, 190, 1),
        ),
        scaffoldBackgroundColor: Color.fromRGBO(255 - 9, 255 - 9, 255 - 9, 1),
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        late Widget page;

        var args = settings.arguments as Map<String, Object>;

        switch (settings.name) {
          case RoutesConstant.VIEW_EXERCISES:
            page = ViewExercises(
              partId: args["id"] as int,
            );
            break;
          case RoutesConstant.EXERCISES:
            page = Exercises();
            break;
          case RoutesConstant.CASE:
            page = ViewCase(
              caseObj: args["caseObj"] as Case,
            );
            break;
          case RoutesConstant.GAME:
            page = Game(
              gameNum: args["gameNum"] as int,
              part: args["part"] as PartDisplay,
            );
            break;
          case RoutesConstant.CONNECTION:
            page = Connection();
            break;
          case RoutesConstant.MAIN_PAGE:
            page = MainPage();
            break;
          case RoutesConstant.RESET_PASSWORD:
            page = ResetPassword();
            break;
          case RoutesConstant.CASES:
            page = ViewCases();
            break;
          case RoutesConstant.VIEW_REMINDER:
            page = ViewReminder();
            break;
          case RoutesConstant.PROFILE:
            page = Profile();
            break;
          case RoutesConstant.HOME:
            page = RehabNowApp();
            break;
          case RoutesConstant.EDIT_PROFILE:
            page = ProfileEdit(user: args["user"] as User);
            break;
          case RoutesConstant.LOGIN:
            page = Login();
            break;
        }
        return MaterialPageRoute(builder: (context) => page);
      },
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: FutureBuilder<bool>(
              future: verifyToken(),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (snapshot.data ?? false) {
                    return MainPage();
                  } else {
                    return Login();
                  }
                }
              }),
        ),
      ),
    );
  }

  Future<bool> verifyToken() async {
    String? token =
        await RehabnowFlutterSecureStorage.storage.read(key: "token");
    if (token != null) {
      User user = await getProfile();
      return user.id != null;
    }
    return false;
  }
}
