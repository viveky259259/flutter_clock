import 'dart:math';

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
    canvas.rotate(2 * pi / 12);
    drawBellAndLeg(radius, canvas);

    //draw left bell and right leg
    canvas.rotate(-4 * pi / 12);
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
    // TODO: implement shouldRepaint
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

  final hourTickMarkWidth = 3;
  final minuteTickMarkWidth = 1.5;
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
  void paint(Canvas canvas, Size size) {var tickMarkLength}

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return null;
  }
}

enum ClockText { roman, arabic }
