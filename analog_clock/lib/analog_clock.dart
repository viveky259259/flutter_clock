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

  Color getColor(int millis) {
    if (millis > 900)
      return Colors.red[900];
    else if (millis > 800)
      return Colors.red[800];
    else if (millis > 700)
      return Colors.red[700];
    else if (millis > 600)
      return Colors.red[600];
    else if (millis > 500)
      return Colors.red[500];
    else if (millis > 400)
      return Colors.red[400];
    else if (millis > 300)
      return Colors.red[300];
    else if (millis > 200)
      return Colors.red[200];
    else if (millis > 100)
      return Colors.red[100];
    else if (millis > 50)
      return Colors.red[50];
    else
      return Colors.white;
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
            highlightColor: Colors.black,
            // Second hand.
            accentColor: Color(0xFF669DF6),
            backgroundColor: Color(0xFFD2E3FC),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Colors.white,
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
        color: customTheme.backgroundColor,
        child: Stack(
          children: [
            // Example of a hand drawn with [CustomPainter].
//            DrawnHand(
//              color: Colors.red,
//              thickness: 2,
//              size: 1,
//              angleRadians: _now.millisecond * radiansPerTick,
//            ),

            DrawnHand(
              color: customTheme.highlightColor,
              thickness: 3,
              size: 1,
              angleRadians: _now.minute * radiansPerTick,
            ),

            DrawnHand(
              color: customTheme.highlightColor,
              thickness: 3,
              size: 0.6,
              angleRadians: _now.hour * radiansPerTick,
            ),

            AnimatedContainer(
              duration: Duration(milliseconds: 1),
              child: DrawnHand(
                color: getColor(_now.millisecond),
                thickness: 2,
                size: 1,
                angleRadians: _now.second * radiansPerTick,
              ),
            ),
            // Example of a hand drawn with [Container].
//            ContainerHand(
//              color: Colors.transparent,
//              size: 0.5,
//              angleRadians: _now.hour * radiansPerHour +
//                  (_now.minute / 60) * radiansPerHour,
//              child: Transform.translate(
//                offset: Offset(0.0, -60.0),
//                child: Container(
//                  width: 32,
//                  height: 150,
//                  decoration: BoxDecoration(
//                    color: customTheme.primaryColor,
//                  ),
//                ),
//              ),
//            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "${_now.hour}:${_now.minute}",
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            Align(
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
                        style: TextStyle(
                            fontSize: 20, color: customTheme.highlightColor),
                      ),
                    ),
                    Opacity(
                      opacity: .4,
                      child: Text(
                        "${_now.millisecond - 2}",
                        style: TextStyle(
                            fontSize: 20, color: customTheme.highlightColor),
                      ),
                    ),
                    Opacity(
                      opacity: .6,
                      child: Text(
                        "${_now.millisecond - 1}",
                        style: TextStyle(
                            fontSize: 20, color: customTheme.highlightColor),
                      ),
                    ),
                    Opacity(
                      opacity: 1,
                      child: Text(
                        "${_now.millisecond}",
                        style: TextStyle(
                            fontSize: 32, color: customTheme.highlightColor),
                      ),
                    ),
                    Opacity(
                      opacity: 0.6,
                      child: Text(
                        "${_now.millisecond + 1}",
                        style: TextStyle(
                            fontSize: 20, color: customTheme.highlightColor),
                      ),
                    ),
                    Opacity(
                      opacity: 0.4,
                      child: Text(
                        "${_now.millisecond + 2}",
                        style: TextStyle(
                            fontSize: 20, color: customTheme.highlightColor),
                      ),
                    ),
                    Opacity(
                      opacity: 0.2,
                      child: Text(
                        "${_now.millisecond + 3}",
                        style: TextStyle(
                            fontSize: 20, color: customTheme.highlightColor),
                      ),
                    ),
                  ],
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
        ),
      ),
    );
  }
}
