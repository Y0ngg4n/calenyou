import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';

class Permissions {
  static checkCalendarPermissions(
    DeviceCalendarPlugin deviceCalendarPlugin) async {
    var permissionsGranted = await deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !permissionsGranted.data) {
      permissionsGranted = await deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
        return null;
      }
    }
  }


}
