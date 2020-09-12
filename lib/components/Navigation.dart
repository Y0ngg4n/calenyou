import 'package:calenyou/components/Calendar.dart';
import 'package:calenyou/utils/CalendarUtils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Navigation extends StatefulWidget {
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  @override
  initState() {
    super.initState();
  }

  final String title = "calenyou";
  int navigationIndex = 0;
  SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: CalendarComponent(),
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
                itemCount: CalendarUtils.calendarsMap.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      new ListTile(
                          title: new Text(
                              CalendarUtils.calendarsMap.keys.toList()[index])),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount:
                          CalendarUtils.calendarsMap.values.toList()[index]
                              .length,
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          itemBuilder:
                              (BuildContext context, int calendarIndex) {
                            return Container(
                                child: Column(children: <Widget>[
                                  Row(children: <Widget>[
                                    Checkbox(
                                      key: Key(CalendarUtils.calendarsMap.values
                                          .toList()[index][calendarIndex]
                                          .toString()),
                                      value: CalendarUtils.enabledCalendars
                                          .values
                                          .toList()[index][calendarIndex],
                                  onChanged: (bool newValue) {
                                    print(CalendarUtils.enabledCalendars);
                                    print(newValue);
                                    setState(() {
                                      CalendarUtils
                                          .enabledCalendars[CalendarUtils
                                          .calendarsMap.keys
                                          .toList()[index]][calendarIndex] =
                                          newValue;
                                      print(CalendarUtils.enabledCalendars);
                                    });
                                  },
                                ),
                                    Text(CalendarUtils.calendarsMap.values
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

}
