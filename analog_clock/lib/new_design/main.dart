import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(ClockApp());
}

class ClockApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Clock(),
    );
  }
}

class Clock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[ClockBody()],
      ),
    );
  }
}

class ClockBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black26,
                boxShadow: [BoxShadow(offset: Offset(0, 5), blurRadius: 5)]),
            child: CustomPaint(
              painter: BellsAndLegsPainter(),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                boxShadow: [BoxShadow(offset: Offset(0, 5), blurRadius: 5)]),
            child: ClockFace(),
          )
        ],
      ),
    );
  }
}

class BellsAndLegsPainter extends CustomPainter {
  Paint bellPaint;
  Paint legPaint;

  BellsAndLegsPainter()
      : bellPaint = new Paint(),
        legPaint = new Paint() {
    bellPaint.color = const Color(0xFF000000);
    bellPaint.style = PaintingStyle.fill;

    legPaint.color = const Color(0xFF000000);
    legPaint.style = PaintingStyle.stroke;
    legPaint.strokeWidth = 10.0;
    legPaint.strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    canvas.save();

    canvas.translate(radius, radius);

    //draw the handle
    Path path = new Path();
    path.moveTo(-60.0, -radius - 10);
    path.lineTo(-50.0, -radius - 50);
    path.lineTo(50.0, -radius - 50);
    path.lineTo(60.0, -radius - 10);

    canvas.drawPath(path, legPaint);

    //draw right bell and left leg
    canvas.rotate(2 * math.pi / 12);
    drawBellAndLeg(radius, canvas);

    //draw left bell and right leg
    canvas.rotate(-4 * math.pi / 12);
    drawBellAndLeg(radius, canvas);

    canvas.restore();
  }

//helps draw the leg and bell
  void drawBellAndLeg(radius, canvas) {
    //bell
    Path path1 = new Path();
    path1.moveTo(-55.0, -radius - 5);
    path1.lineTo(55.0, -radius - 5);
    path1.quadraticBezierTo(0.0, -radius - 75, -55.0, -radius - 10);

    //leg
    Path path2 = new Path();
    path2.addOval(new Rect.fromCircle(
        center: new Offset(0.0, -radius - 50), radius: 3.0));
    path2.moveTo(0.0, -radius - 50);
    path2.lineTo(0.0, radius + 20);

    //draw the bell on top on the leg
    canvas.drawPath(path2, legPaint);
    canvas.drawPath(path1, bellPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class ClockFace extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          width: double.infinity,
          decoration:
              BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Stack(
            children: <Widget>[
              //dial and numbers go here
              new Container(
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.all(10),
                child: CustomPaint(
                  painter: ClockDialPainter(),
                ),
              ),
              ClockHands(),
              //centerpoint
              Center(
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.black),
                ),
              ),
              //clock hands go here
            ],
          ),
        ),
      ),
    );
  }
}

class ClockDialPainter extends CustomPainter {
  final clockText;
  final hourTickMarkLength = 10;
  final minuteTickMarkLength = 5;

  final double hourTickMarkWidth = 3;
  final double minuteTickMarkWidth = 1.5;
  final Paint tickPaint;
  final TextPainter textPainter;
  final TextStyle textStyle;

  final romanNumeralList = [
    'XII',
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
    'VII',
    'VIII',
    'IX',
    'X',
    'XI'
  ];

  ClockDialPainter({this.clockText = ClockText.roman})
      : tickPaint = Paint(),
        textPainter = TextPainter(
            textAlign: TextAlign.center, textDirection: TextDirection.rtl),
        textStyle = const TextStyle(
            color: Colors.black,
            fontFamily: 'Times New '
                'Roman',
            fontSize: 15) {
    tickPaint.color = Colors.blueGrey;
  }

  //https://medium.com/@NPKompleet/creating-an-analog-clock-in-flutter-iii-86abadb7e5e1
  @override
  void paint(Canvas canvas, Size size) {
    var tickMarkLength;
    final angle = 2 * math.pi / 60;
    final radius = size.width / 2;
    canvas.save();

    // drawing
    canvas.translate(radius, radius);
    for (var i = 0; i < 60; i++) {
      //make the length and stroke of the tick marker longer and thicker depending
      tickMarkLength = i % 5 == 0 ? hourTickMarkLength : minuteTickMarkLength;
      tickPaint.strokeWidth =
          i % 5 == 0 ? hourTickMarkWidth : minuteTickMarkWidth;
      canvas.drawLine(new Offset(0.0, -radius),
          new Offset(0.0, -radius + tickMarkLength), tickPaint);

      //draw the text
      if (i % 5 == 0) {
        canvas.save();
        canvas.translate(0.0, -radius + 20.0);

        textPainter.text = new TextSpan(
          text: this.clockText == ClockText.roman
              ? '${romanNumeralList[i ~/ 5]}'
              : '${i == 0 ? 12 : i ~/ 5}',
          style: textStyle,
        );

        //helps make the text painted vertically
        canvas.rotate(-angle * i);

        textPainter.layout();

        textPainter.paint(canvas,
            new Offset(-(textPainter.width / 2), -(textPainter.height / 2)));

        canvas.restore();
      }

      canvas.rotate(angle);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

class HourHandPainter extends CustomPainter {
  final Paint hourHandPaint;
  int hours;
  int minutes;

  HourHandPainter({this.hours, this.minutes}) : hourHandPaint = new Paint() {
    hourHandPaint.color = Colors.black87;
    hourHandPaint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    // To draw hour hand
    canvas.save();

    canvas.translate(radius, radius);
    //check if hour is greater than 12 before calculating rotation
    canvas.rotate(this.hours > 12
        ? 2 * math.pi * ((this.hours - 12) / 12 + (this.minutes / 720))
        : 2 * math.pi * ((this.hours / 12) + (this.minutes / 720)));
    Path path = Path();
    //heart shape head for hour hand
    path.moveTo(0, -radius + 15);
    path.quadraticBezierTo(-3.5, -radius + 25, -15.0, -radius + radius / 4);
    path.quadraticBezierTo(
        -20, -radius + radius / 3, -7.5, -radius + radius / 3);
    path.lineTo(0, -radius + radius / 4);
    path.lineTo(7.5, -radius + radius / 3);
    path.quadraticBezierTo(20, -radius + radius / 3, 15, -radius + radius / 4);
    path.quadraticBezierTo(3.5, -radius + 25, 0, -radius + 15);

    //hour hand stem
    path.moveTo(-1, -radius + radius / 4);
    path.lineTo(-5, -radius + radius / 2);
    path.lineTo(-2, 0);
    path.lineTo(2, 0);
    path.lineTo(5, -radius + radius / 2);
    path.lineTo(1, -radius + radius / 4);
    path.close();
    canvas.drawPath(path, hourHandPaint);
    canvas.drawShadow(path, Colors.black, 2.0, false);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ClockHands extends StatefulWidget {
  @override
  _ClockHandState createState() => new _ClockHandState();
}

class _ClockHandState extends State<ClockHands> {
  Timer _timer;
  DateTime dateTime;

  @override
  void initState() {
    super.initState();
    dateTime = new DateTime.now();
    _timer = new Timer.periodic(const Duration(seconds: 1), setTime);
  }

  void setTime(Timer timer) {
    setState(() {
      dateTime = new DateTime.now();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
        aspectRatio: 1.0,
        child: new Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            child: new Stack(fit: StackFit.expand, children: <Widget>[
              new CustomPaint(
                painter: new HourHandPainter(
                    hours: dateTime.hour, minutes: dateTime.minute),
              ),
              CustomPaint(
                painter: MinuteHandPainter(
                    minutes: dateTime.minute, seconds: dateTime.second),
              ),
              CustomPaint(
                painter: SecondHandPainter(seconds: dateTime.second),
              )
            ])));
  }
}

class MinuteHandPainter extends CustomPainter {
  int minutes;
  int seconds;
  final Paint minuteHandPaint;

  MinuteHandPainter({this.minutes, this.seconds}) : minuteHandPaint = Paint() {
    minuteHandPaint.color = const Color(0xff333333);
    minuteHandPaint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    canvas.save();
    canvas.translate(radius, radius);
    canvas.rotate(2 * math.pi * ((this.minutes + (this.seconds / 60)) / 60));
    Path path = Path();
    path.moveTo(-1.5, -radius - 10.0);
    path.lineTo(-5.0, -radius / 1.8);
    path.lineTo(-2.0, 10.0);
    path.lineTo(2.0, 10.0);
    path.lineTo(5.0, -radius / 1.8);
    path.lineTo(0, -radius - 10.0);
    path.lineTo(10, -radius / 10);
    path.close();
    canvas.drawPath(path, minuteHandPaint);
    canvas.drawShadow(path, Colors.black, 4.0, false);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class SecondHandPainter extends CustomPainter {
  final Paint secondHandPaint;
  final Paint secondHandPointsPainter;
  int seconds;

  SecondHandPainter({this.seconds})
      : secondHandPaint = Paint(),
        secondHandPointsPainter = Paint() {
    secondHandPaint.color = Colors.red;
    secondHandPaint.style = PaintingStyle.stroke;
    secondHandPaint.strokeWidth = 2;

    secondHandPointsPainter.color = Colors.red;
    secondHandPointsPainter.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    canvas.save();
    canvas.translate(radius, radius);
    canvas.rotate(2 * math.pi * this.seconds / 60);
    Path path1 = Path();
    Path path2 = Path();
    path1.moveTo(0, -radius);
    path1.lineTo(0, radius / 4);
    path2.addOval(Rect.fromCircle(radius: 7, center: Offset(0, -radius)));
    path2.addOval(Rect.fromCircle(radius: 5, center: Offset(0, 0)));

    canvas.drawPath(path1, secondHandPaint);
    canvas.drawPath(path2, secondHandPointsPainter);
    canvas.restore();
  }

  @override
  bool shouldRepaint(SecondHandPainter oldDelegate) =>
      this.seconds != oldDelegate.seconds;
}

enum ClockText { roman, arabic }
