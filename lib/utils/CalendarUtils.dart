import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';

class CalendarUtils {
  static Future<UnmodifiableListView<Calendar>> retrieveCalendars(
      DeviceCalendarPlugin deviceCalendarPlugin) async {
    try {
      UnmodifiableListView<Calendar> unmodifiableListView;
      await deviceCalendarPlugin
          .retrieveCalendars()
          .then((value) => unmodifiableListView = value?.data);
      return unmodifiableListView;
    } on PlatformException catch (e) {
      print(e);
      return null;
    }
  }
}
