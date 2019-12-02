// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'drawn_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(milliseconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

//  Color getColor(int millis) {
//    if (millis > 900)
//      return Colors.red[900];
//    else if (millis > 800)
//      return Colors.red[800];
//    else if (millis > 700)
//      return Colors.red[700];
//    else if (millis > 600)
//      return Colors.red[600];
//    else if (millis > 500)
//      return Colors.red[500];
//    else if (millis > 400)
//      return Colors.red[400];
//    else if (millis > 300)
//      return Colors.red[300];
//    else if (millis > 200)
//      return Colors.red[200];
//    else if (millis > 100)
//      return Colors.red[100];
//    else if (millis > 50)
//      return Colors.red[50];
//    else
//      return Colors.white;
//  }

  String getNumberInString(int number) {
    if (number < 10)
      return "0$number";
    else
      return "$number";
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFF4285F4),
            // Minute hand.
            highlightColor: Color(0xFF8AB4F8),
            // Second hand.
            accentColor: Color(0xFF669DF6),
            backgroundColor: Color(0xFFD2E3FC),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Color(0xFF4285F4),
            accentColor: Color(0xFF8AB4F8),
            backgroundColor: Color(0xFF3C4043),
          );

    final time = DateFormat.Hms().format(DateTime.now());
    final weatherInfo = DefaultTextStyle(
      style: TextStyle(color: customTheme.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_temperature),
          Text(_temperatureRange),
          Text(_condition),
          Text(_location),
        ],
      ),
    );

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
//        color: Colors.white,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                Theme.of(context).brightness == Brightness.light
                    ? "assets/bg1.jpg"
                    : "assets/nightbg.jpg",
              ),
              fit: BoxFit.cover),
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          return Stack(
            children: [
              // Example of a hand drawn with [CustomPainter].
//            DrawnHand(
//              color: Colors.red,
//              thickness: 2,
//              size: 1,
//              angleRadians: _now.millisecond * radiansPerTick,
//            ),
              Center(
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Container(
//                    duration: Duration(milliseconds: 1),
                    height: constraints.maxHeight * 0.75,
                    width: constraints.maxHeight * 0.75,
                    decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.white24
                            : Colors.white24,
                        borderRadius: BorderRadius.all(Radius.circular(150))),
                  ),
                ),
              ),
              Center(
                child: UnicornOutlineButton(
                  strokeWidth: 12,
                  radius: 150,

                  gradient: LinearGradient(
                      end: Alignment.bottomCenter,
                      begin: Alignment.topCenter,
                      colors: Theme.of(context).brightness == Brightness.light
                          ? [Colors.green.shade200, Colors.brown]
                          : [Colors.purpleAccent, Colors.purple.shade900]),
                  child: SizedBox(
                    height: constraints.maxHeight * 0.75,
                    width: constraints.maxHeight * 0.75,
                  ),
                  onPressed: () {},

                  //                height: constraints.maxHeight * 0.75,
                  //                width: constraints.maxHeight * 0.75,
                  //                decoration: BoxDecoration(
                  //                    border: Border.all(color: Colors.blue, width: 8),
                  //                    borderRadius: BorderRadius.all(Radius.circular(150))),
                ),
              ),
              DrawnHand(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.green.shade900
                    : Colors.blue.shade900,
                thickness: 12,
                size: 0.5,
                angleRadians: _now.minute * radiansPerTick,
              ),

              DrawnHand(
                color: customTheme.accentColor,
                thickness: 12,
                size: 0.4,
                angleRadians: _now.hour * radiansPerHour,
              ),

              AnimatedContainer(
                duration: Duration(milliseconds: 1),
                child: DrawnHand(
                  color: Colors.red.shade900,
                  thickness: 3,
                  size: 0.6,
                  angleRadians: _now.second * radiansPerTick,
                ),
              ),
//            getMillisList(customTheme),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    "${getNumberInString(_now.hour)}:${getNumberInString(_now.minute)}",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white),
                  ),
                ),
              ),

              Positioned(
                left: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: weatherInfo,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget getMillisList(customTheme) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Opacity(
              opacity: .2,
              child: Text(
                "${_now.millisecond - 3}",
                style:
                    TextStyle(fontSize: 20, color: customTheme.highlightColor),
              ),
            ),
            Opacity(
              opacity: .4,
              child: Text(
                "${_now.millisecond - 2}",
                style:
                    TextStyle(fontSize: 20, color: customTheme.highlightColor),
              ),
            ),
            Opacity(
              opacity: .6,
              child: Text(
                "${_now.millisecond - 1}",
                style:
                    TextStyle(fontSize: 20, color: customTheme.highlightColor),
              ),
            ),
            Opacity(
              opacity: 1,
              child: Text(
                "${_now.millisecond}",
                style:
                    TextStyle(fontSize: 32, color: customTheme.highlightColor),
              ),
            ),
            Opacity(
              opacity: 0.6,
              child: Text(
                "${_now.millisecond + 1}",
                style:
                    TextStyle(fontSize: 20, color: customTheme.highlightColor),
              ),
            ),
            Opacity(
              opacity: 0.4,
              child: Text(
                "${_now.millisecond + 2}",
                style:
                    TextStyle(fontSize: 20, color: customTheme.highlightColor),
              ),
            ),
            Opacity(
              opacity: 0.2,
              child: Text(
                "${_now.millisecond + 3}",
                style:
                    TextStyle(fontSize: 20, color: customTheme.highlightColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UnicornOutlineButton extends StatelessWidget {
  final _GradientPainter _painter;
  final Widget _child;
  final VoidCallback _callback;
  final double _radius;

  UnicornOutlineButton({
    @required double strokeWidth,
    @required double radius,
    @required Gradient gradient,
    @required Widget child,
    @required VoidCallback onPressed,
  })  : this._painter = _GradientPainter(
            strokeWidth: strokeWidth, radius: radius, gradient: gradient),
        this._child = child,
        this._callback = onPressed,
        this._radius = radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _painter,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _callback,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: _callback,
          child: Container(
            constraints: BoxConstraints(minWidth: 88, minHeight: 48),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientPainter extends CustomPainter {
  final Paint _paint = Paint();
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  _GradientPainter(
      {@required double strokeWidth,
      @required double radius,
      @required Gradient gradient})
      : this.strokeWidth = strokeWidth,
        this.radius = radius,
        this.gradient = gradient;

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size

    Rect outerRect = Offset.zero & size;
    var outerRRect =
        RRect.fromRectAndRadius(outerRect, Radius.circular(radius));

    // create inner rectangle smaller by strokeWidth
    Rect innerRect = Rect.fromLTWH(strokeWidth, strokeWidth,
        size.width - strokeWidth * 2, size.height - strokeWidth * 2);
    var innerRRect = RRect.fromRectAndRadius(
        innerRect, Radius.circular(radius - strokeWidth));

    // apply gradient shader
    _paint.shader = gradient.createShader(outerRect);

    // create difference between outer and inner paths and draw it
    Path path1 = Path()..addRRect(outerRRect);
    Path path2 = Path()..addRRect(innerRRect);
    var path = Path.combine(PathOperation.difference, path1, path2);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
