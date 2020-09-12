import 'dart:async';
import 'dart:collection';

import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:flutter/services.dart';
import 'package:timetable/timetable.dart' as tt;

import 'Permissions.dart';

class CalendarUtils {
  static dc.DeviceCalendarPlugin _deviceCalendarPlugin;
  static List<dc.Calendar> _calendars = new List<dc.Calendar>();
  static Map<String, List<dc.Calendar>> _calendarsMap =
      new Map<String, List<dc.Calendar>>();
  static Map<String, List<bool>> _enabledCalendars =
      new Map<String, List<bool>>();

  static dc.DeviceCalendarPlugin get deviceCalendarPlugin =>
      _deviceCalendarPlugin;

  // static Future<UnmodifiableListView<Calendar>> retrieveCalendars(
  //     DeviceCalendarPlugin deviceCalendarPlugin) async {
  //   try {
  //     UnmodifiableListView<Calendar> unmodifiableListView;
  //     await deviceCalendarPlugin
  //         .retrieveCalendars()
  //         .then((value) => unmodifiableListView = value?.data);
  //     return unmodifiableListView;
  //   } on PlatformException catch (e) {
  //     print(e);
  //     return null;
  //   }
  // }

  static void retrieveCalendars() async {
    dc.DeviceCalendarPlugin _deviceCalendarPlugin = dc.DeviceCalendarPlugin();
    Permissions.checkCalendarPermissions(_deviceCalendarPlugin);
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          return null;
        }
      }
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      _calendars = calendarsResult?.data;
      Map calendars = new Map<String, List<dc.Calendar>>();
      for (dc.Calendar calendar in _calendars) {
        print(calendar.accountName);
        if (!calendars.containsKey(calendar.accountName)) {
          calendars.putIfAbsent(calendar.accountName, () => [calendar]);
          _enabledCalendars.putIfAbsent(calendar.accountName, () => [true]);
        } else {
          List<dc.Calendar> tmpCalendars = calendars[calendar.accountName];
          tmpCalendars.add(calendar);
          calendars.update(calendar.accountName, (value) => tmpCalendars);
          List<bool> tmpEnabled = _enabledCalendars[calendar.accountName];
          tmpEnabled.add(true);
          _enabledCalendars.update(calendar.accountName, (value) => tmpEnabled);
        }
        // TODO: Make it more elegant with calendars.update function
//          calendars.update(
//            calendar.accountName,
//            (existingValue) => calendars[calendar.accountName],
//            ifAbsent: () => calendar,
//          );
      }
      print(calendars);
      _calendarsMap = calendars;
    } on PlatformException catch (e) {
      print(e);
    }
  }

  static Future<Map<DateTime, List<String>>> retrieveDateTimeEvents() async {
    Map<DateTime, List<String>> dateTimeEvents =
        new Map<DateTime, List<String>>();
    for (dc.Calendar calendar in CalendarUtils.calendars) {
      dc.DeviceCalendarPlugin _deviceCalendarPlugin = dc.DeviceCalendarPlugin();
      dc.Result<UnmodifiableListView<dc.Event>> eventsResult =
          await _deviceCalendarPlugin.retrieveEvents(
              calendar.id, dc.RetrieveEventsParams());
      UnmodifiableListView<dc.Event> events = eventsResult.data;
      for (dc.Event event in events) {}
    }
  }

  static Future<List<tt.BasicEvent>> retrieveBasicEvents() async {
    List<tt.BasicEvent> basicEvents = new List<tt.BasicEvent>();
    dc.DeviceCalendarPlugin _deviceCalendarPlugin = dc.DeviceCalendarPlugin();
    for (MapEntry account in _calendarsMap.entries) {
      if (!_enabledCalendars.containsKey(account.key)) continue;
      for (int i = 0; i < account.value.length; i++) {
        if (!_enabledCalendars[account.key][i]) continue;
        print(account.value[i].name);
        dc.Result<UnmodifiableListView<dc.Event>> eventsResult =
            await _deviceCalendarPlugin.retrieveEvents(
                account.value[i].id, dc.RetrieveEventsParams());
      }
    }
  }

  static List<dc.Calendar> get calendars => _calendars;

  static Map<String, List<dc.Calendar>> get calendarsMap => _calendarsMap;

  static Map<String, List<bool>> get enabledCalendars => _enabledCalendars;
}
