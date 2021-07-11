import 'package:intl/intl.dart' show DateFormat;

DateFormat DATE_FORMAT = DateFormat("dd-MM-yyyy");
DateFormat DATETIME_FORMAT = DateFormat("dd-MM-yyyy HH:mm:ss");

Map<int, String> TARGET_FREQUENCIES = {
  1: "Once per day",
  2: "Twice per day",
  3: "Thrice per day",
  4: "Once every two days",
  5: "Once every three days",
};
