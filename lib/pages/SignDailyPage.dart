//import 'package:flutter/material.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart' show CalendarCarousel;
//import 'package:flutter_calendar_carousel/classes/event.dart';
//import 'package:intl/intl.dart' show DateFormat;
//
//import 'package:OpenJMU/utils/ThemeUtils.dart';
//
//class SignDailyPage extends StatefulWidget {
//  @override
//  State<StatefulWidget> createState() => _SignDailyPageState();
//}
//
//class _SignDailyPageState extends State<SignDailyPage> {
//  DateTime _currentDate = DateTime.now();
//  String _currentMonth = '';
//
//  CalendarCarousel _calendarCarouselNoHeader;
//
//  @override
//  void initState() {
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    _calendarCarouselNoHeader = CalendarCarousel<Event>(
//      todayBorderColor: ThemeUtils.currentColorTheme,
//      onDayPressed: (DateTime date, List<Event> events) {
//        this.setState(() => _currentDate = date);
//        events.forEach((event) => print(event.title));
//      },
//      weekendTextStyle: TextStyle(
//        color: Colors.grey,
//      ),
//      thisMonthDayBorderColor: Colors.grey,
//      weekFormat: false,
//      height: 420.0,
//      selectedDateTime: _currentDate,
//      customGridViewPhysics: NeverScrollableScrollPhysics(),
//      markedDateShowIcon: true,
//      markedDateIconMaxShown: 2,
//      markedDateMoreShowTotal:
//      false, // null for not showing hidden events indicator
//      showHeader: false,
//      markedDateIconBuilder: (event) {
//        return event.icon;
//      },
//      todayTextStyle: TextStyle(
//        color: Colors.blue,
//      ),
//      todayButtonColor: Colors.white,
//      selectedDayTextStyle: TextStyle(
//        color: Colors.white,
//      ),
//      minSelectedDate: _currentDate,
//      maxSelectedDate: _currentDate.add(Duration(days: 60)),
//      inactiveDaysTextStyle: TextStyle(
//        color: Theme.of(context).textTheme.caption.color
//      ),
//      onCalendarChanged: (DateTime date) {
//        this.setState(() => _currentMonth = DateFormat.yMMM().format(date));
//      },
//    );
//
//    return new Scaffold(
//        appBar: new AppBar(
//          title: new Text("Calendar"),
//        ),
//        body: SingleChildScrollView(
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            mainAxisAlignment: MainAxisAlignment.start,
//            children: <Widget>[
//              Container(
//                margin: EdgeInsets.only(
//                  top: 30.0,
//                  bottom: 16.0,
//                  left: 16.0,
//                  right: 16.0,
//                ),
//                child: new Row(
//                  children: <Widget>[
//                    Expanded(
//                        child: Text(
//                          _currentMonth,
//                          style: TextStyle(
//                            fontWeight: FontWeight.bold,
//                            fontSize: 24.0,
//                          ),
//                        )),
//                  ],
//                ),
//              ),
//              Container(
//                margin: EdgeInsets.symmetric(horizontal: 16.0),
//                child: _calendarCarouselNoHeader,
//              ), //
//            ],
//          ),
//        ));
//  }
//}