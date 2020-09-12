import 'dart:async';

import 'package:calenyou/utils/CalendarUtils.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';

class CalendarComponent extends StatefulWidget {
  @override
  CalendarComponentState createState() => CalendarComponentState();
}

class CalendarComponentState extends State<CalendarComponent> {
  StreamController eventController;
  EventProvider<BasicEvent> eventProvider;
  TimetableController<BasicEvent> _timetableController;

  @override
  void initState() {
    super.initState();
    eventController = StreamController<List<BasicEvent>>()..add([]);
    eventProvider = EventProvider.simpleStream(eventController.stream);
    _timetableController = TimetableController(
        eventProvider: eventProvider,
        // Optional parameters with their default values:
        initialTimeRange: InitialTimeRange.range(
          startTime: LocalTime(8, 0, 0),
          endTime: LocalTime(20, 0, 0),
        ),
        initialDate: LocalDate.today(),
        visibleRange: VisibleRange.week(),
        firstDayOfWeek: DayOfWeek.monday);
  }

  @override
  void dispose() {
    super.dispose();
    eventController.close();
    _timetableController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Timetable<BasicEvent>(
      controller: _timetableController,
      eventBuilder: (event) => BasicEventWidget(event),
      allDayEventBuilder: (context, event, info) =>
          BasicAllDayEventWidget(event, info: info),
    );
  }

  Future<List<BasicEvent>> fetchBasicEvents() async {
    List<BasicEvent> basicEvents = await CalendarUtils.retrieveBasicEvents();
    // eventController.add(basicEvents);
    return basicEvents;
  }
}
