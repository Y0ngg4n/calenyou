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
  Map<String, List<Calendar>> _calendarsMap = new Map<String, List<Calendar>>();
  Map<String, List<bool>> _enabledCalendars = new Map<String, List<bool>>();

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
                itemCount: _calendarsMap.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      new ListTile(
                          title: new Text(_calendarsMap.keys.toList()[index])),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount:
                              _calendarsMap.values.toList()[index].length,
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          itemBuilder:
                              (BuildContext context, int calendarIndex) {
                            return Container(
                                child: Column(children: <Widget>[
                              Row(children: <Widget>[
                                Checkbox(
                                  key: Key(_calendarsMap.values
                                      .toList()[index][calendarIndex]
                                      .toString()),
                                  value: _enabledCalendars.values
                                      .toList()[index][calendarIndex],
                                  onChanged: (bool newValue) {
                                    print(_enabledCalendars);
                                    print(newValue);
                                    setState(() {
                                      _enabledCalendars[_calendarsMap.keys
                                              .toList()[index]][calendarIndex] =
                                          newValue;
                                      print(_enabledCalendars);
                                    });
                                  },
                                ),
                                Text(_calendarsMap.values
                                    .toList()[index][calendarIndex]
                                    .name)
                              ])
                            ]));
                          })
                    ],
                  );
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
          return null;
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
            _enabledCalendars.putIfAbsent(calendar.accountName, () => [true]);
          } else {
            calendars.update(calendar.accountName, (value) => calendars[calendar.accountName].add(calendar));
            _enabledCalendars.update(calendar.accountName, (value) => _enabledCalendars[calendar.accountName].add(true));
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
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }
}
