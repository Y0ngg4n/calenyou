import 'dart:collection';

import 'package:calenyou/utils/CalendarUtils.dart';
import 'package:calenyou/utils/Permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'NewAccount.dart';
import 'package:device_calendar/device_calendar.dart';

class Navigation extends StatefulWidget {
  DeviceCalendarPlugin _deviceCalendarPlugin;

  Navigation(DeviceCalendarPlugin deviceCalendarPlugin) {
    this._deviceCalendarPlugin = deviceCalendarPlugin;
  }

  @override
  _NavigationState createState() => _NavigationState(_deviceCalendarPlugin);
}

class _NavigationState extends State<Navigation> {
  DeviceCalendarPlugin _deviceCalendarPlugin;
  List<Calendar> _calendars = new List<Calendar>();

  _NavigationState(DeviceCalendarPlugin deviceCalendarPlugin) {
    this._deviceCalendarPlugin = deviceCalendarPlugin;
  }

  @override
  initState() {
    super.initState();
    Permissions.checkCalendarPermissions(_deviceCalendarPlugin);
    _retrieveCalendars();
  }

  final String title = "calenyou";
  int navigationIndex = 0;
  SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('My Page!')),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListView.builder(
                shrinkWrap: true, // 1st add
                physics: ClampingScrollPhysics(), // 2nd add
                itemCount: _calendars.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListView();
                })
          ],
        ),
      ),
    );
  }

  void _retrieveCalendars() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          return;
        }
      }
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      setState(() {
        _calendars = calendarsResult?.data;
        Map calendars = new Map<String, List<Calendar>>();
        for (Calendar calendar in _calendars) {
          print(calendar.accountName);
          if (!calendars.containsKey(calendar.accountName)) {
            calendars.putIfAbsent(calendar.accountName, () => [calendar]);
          } else {
            List<Calendar> tempCals = calendars[calendar.accountName];
            tempCals.add(calendar);
            calendars.update(calendar.accountName, (value) => tempCals);
          }
//          calendars.update(
//            calendar.accountName,
//            (existingValue) => [calendars[calendar.accountName], calendar],
//            ifAbsent: () => calendar,
//          );
        }
        print(calendars);
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }
}
