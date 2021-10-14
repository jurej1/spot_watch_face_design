import 'dart:math';
import 'dart:developer' as dev;
import 'dart:ui' as ui;
import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';

class ClockPainter extends CustomPainter {
  final DateTime now;
  final int? steps;
  final int? stepsGoal;
  final int? heartRate;
  final int? heartRateMax;

  ClockPainter({
    required this.now,
    this.steps,
    this.stepsGoal,
    this.heartRateMax,
    this.heartRate,
  });

  final double borderWidth = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double clockRadius = min(size.width, size.height) * 0.4;

    canvas.drawCircle(center, clockRadius, Paint()..color = Colors.blueGrey);

    double availableRadius = clockRadius - borderWidth;

    _drawDateOuput(canvas, center, availableRadius);
    _drawStepsAndHeart(canvas, center, availableRadius);
    _drawMinLines(canvas, availableRadius, center);
    _drawPointers(canvas, availableRadius, center);
    _drawClockBorder(canvas, clockRadius, center);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  Path _buildCenterCircle(Offset center, double circleRadius) {
    final double borderWidth = 5;
    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: circleRadius))
      ..addOval(Rect.fromCircle(center: center, radius: circleRadius - borderWidth))
      ..fillType = PathFillType.evenOdd;
  }

  void _drawClockBorder(Canvas canvas, double clockRadius, Offset center) {
    Path path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: clockRadius))
      ..addOval(Rect.fromCircle(center: center, radius: clockRadius - borderWidth))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = Colors.grey);
  }

  void _drawSecPointer({
    required Canvas canvas,
    required double availableRadius,
    required double circleRadius,
    required Offset center,
    required Paint paint,
    required double smallPointerLength,
    required double pointerLength,
  }) {
    final double angle = (now.second * (360 / 60)) * -(pi / 180) + pi;

    canvas.drawLine(
      center.translate(
        sin(angle) * circleRadius,
        cos(angle) * circleRadius,
      ),
      center.translate(
        sin(angle) * pointerLength,
        cos(angle) * pointerLength,
      ),
      paint,
    );

    canvas.drawLine(
      center.translate(
        -sin(angle) * circleRadius,
        -cos(angle) * circleRadius,
      ),
      center.translate(
        -sin(angle) * smallPointerLength,
        -cos(angle) * smallPointerLength,
      ),
      paint,
    );
  }

  void _drawMinPointer({
    required Canvas canvas,
    required double length,
    required Offset center,
    required Paint paint,
    required double smallCircleRadius,
  }) {
    final double angle = (now.minute * (360 / 60)) * -(pi / 180) + pi;

    canvas.drawLine(
      center.translate(
        sin(angle) * smallCircleRadius,
        cos(angle) * smallCircleRadius,
      ),
      center.translate(
        sin(angle) * length,
        cos(angle) * length,
      ),
      paint,
    );
  }

  void _drawHourPointer({
    required Canvas canvas,
    required double length,
    required Offset center,
    required Paint paint,
    required double smallCircleRadius,
  }) {
    final double angle = (now.hour * (360 / 12)) * -(pi / 180) - pi;

    canvas.drawLine(
      center.translate(
        sin(angle) * smallCircleRadius,
        cos(angle) * smallCircleRadius,
      ),
      center.translate(
        sin(angle) * length,
        cos(angle) * length,
      ),
      paint,
    );
  }

  void _drawPointers(Canvas canvas, double availableRadius, Offset center) {
    double smallCircleRadius = 13;

    final Paint _minPointerPaint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      _buildCenterCircle(center, smallCircleRadius),
      Paint()..color = _minPointerPaint.color,
    );

    _drawMinPointer(
      canvas: canvas,
      length: availableRadius * 0.75,
      center: center,
      paint: _minPointerPaint,
      smallCircleRadius: smallCircleRadius,
    );

    _drawHourPointer(
      canvas: canvas,
      length: availableRadius * 0.6,
      center: center,
      paint: _minPointerPaint,
      smallCircleRadius: smallCircleRadius,
    );

    final Paint _secPointerPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    smallCircleRadius = 10;

    canvas.drawPath(
      _buildCenterCircle(center, smallCircleRadius),
      Paint()..color = _secPointerPaint.color,
    );

    _drawSecPointer(
      canvas: canvas,
      availableRadius: availableRadius,
      circleRadius: smallCircleRadius,
      center: center,
      paint: _secPointerPaint,
      pointerLength: availableRadius * 0.8,
      smallPointerLength: availableRadius * 0.18,
    );
  }

  void _drawMinLines(Canvas canvas, double availableRadius, Offset center) {
    final double outerRadius = availableRadius - 9;
    final double innerRadius = outerRadius - 7;

    Paint normalPaint = Paint()
      ..color = Colors.grey
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    for (double i = 0; i < 360; i += (360 / 60)) {
      final bool isFiveMin = i % (5 * (360 / 60)) == 0;
      final double angle = i * (pi / 180) - pi / 2;

      if (isFiveMin) {
        _drawLetter(
          canvas,
          i: i,
          center: center,
          radius: ((innerRadius + outerRadius) / 2),
        );
      } else {
        canvas.drawLine(
          center.translate(
            cos(angle) * innerRadius,
            sin(angle) * innerRadius,
          ),
          center.translate(
            cos(angle) * outerRadius,
            sin(angle) * outerRadius,
          ),
          normalPaint,
        );
      }
    }
  }

  void _drawLetter(
    Canvas canvas, {
    required double i,
    required Offset center,
    required double radius,
  }) {
    final double angle = i * (pi / 180) - pi / 2;
    final int number = ((i / (360 / 60)) / 5).round();
    final _textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    _textPainter.text = TextSpan(
      text: number == 0 ? '12' : number.toStringAsFixed(0),
      style: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
    final double textWidth = 20;
    _textPainter.layout(minWidth: textWidth, maxWidth: textWidth);

    _textPainter.paint(
      canvas,
      center.translate(
        (cos(angle) * radius) - (textWidth * 0.5),
        (sin(angle) * radius) - (textWidth * 0.5),
      ),
    );
  }

  void _drawDateOuput(Canvas canvas, Offset center, double availableRadius) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        children: [
          TextSpan(text: now.month.toString() + ' ', style: TextStyle(color: Colors.red)),
          TextSpan(text: intl.DateFormat('MMM').format(now).toUpperCase()),
        ],
      ),
    );
    textPainter.layout();
    final textWidth = textPainter.width;

    textPainter.paint(
      canvas,
      center.translate(-(textWidth * 0.5), -(availableRadius * 0.5)),
    );
  }

  void _drawStepsAndHeart(Canvas canvas, Offset center, double availableRadius) {
    final double outerRadius = availableRadius * 0.7;
    final double innerRadius = outerRadius - 10;

    if (this.steps != null && this.stepsGoal != null) {
      _drawStepLines(
        canvas: canvas,
        center: center,
        innerRadius: innerRadius,
        outerRadius: outerRadius,
        maxValue: stepsGoal!,
        value: steps!,
      );
      _drawStepsText(canvas, center, innerRadius);
    }

    if (this.heartRate != null && this.heartRateMax != null) {
      _drawHeartLines(
        canvas: canvas,
        center: center,
        innerRadius: -innerRadius,
        outerRadius: -outerRadius,
        maxValue: heartRateMax!,
        value: heartRate!,
      );
      _drawHeartText(canvas, center, innerRadius);
    }
  }

  void _drawInfoLine({
    required Canvas canvas,
    required int i,
    required int divider,
    required double lineValue,
    required int value,
    required double innerRadius,
    required double outerRadius,
    required Offset center,
    required double angle,
  }) {
    final int loopCounter = (i / divider).round();
    final int upperValue = ((loopCounter + 1) * lineValue).round();

    final bool isTileCompleted = value > upperValue;

    final Paint linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center.translate(
        sin(angle) * innerRadius,
        cos(angle) * innerRadius,
      ),
      center.translate(
        sin(angle) * outerRadius,
        cos(angle) * outerRadius,
      ),
      linePaint..color = isTileCompleted ? Colors.red : Colors.grey,
    );
  }

  void _drawStepLines({
    required Canvas canvas,
    required Offset center,
    required double innerRadius,
    required double outerRadius,
    required int value,
    required int maxValue,
  }) {
    final int maxAngle = 60;
    final int divider = 4;
    final int amountOfLines = (maxAngle / divider).round();
    final double lineValue = maxValue / amountOfLines;

    for (int i = 0; i < maxAngle; i += divider) {
      final double angle = i * (pi / 180) - pi / 2;
      _drawInfoLine(
        canvas: canvas,
        i: i,
        divider: divider,
        lineValue: lineValue,
        value: value,
        innerRadius: innerRadius,
        outerRadius: outerRadius,
        center: center,
        angle: angle,
      );
    }
  }

  void _drawHeartLines({
    required Canvas canvas,
    required Offset center,
    required double innerRadius,
    required double outerRadius,
    required int value,
    required int maxValue,
  }) {
    final int maxAngle = 60;
    final int divider = 4;
    final int amountOfLines = (maxAngle / divider).round();
    final double lineValue = maxValue / amountOfLines;

    for (int i = 0; i < maxAngle; i += divider) {
      final double angle = i * -(pi / 180) - pi / 2;
      _drawInfoLine(
        canvas: canvas,
        i: i,
        divider: divider,
        lineValue: lineValue,
        value: value,
        innerRadius: innerRadius,
        outerRadius: outerRadius,
        center: center,
        angle: angle,
      );
    }
  }

  void _drawStepsText(Canvas canvas, Offset center, double innerRadius) {
    final _countTextPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    _countTextPainter.text = TextSpan(
      text: steps.toString(),
    );

    _countTextPainter.layout(
      minWidth: 0,
      maxWidth: double.maxFinite,
    );

    final _wordTextPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    _wordTextPainter.text = TextSpan(
      text: ('Steps').toUpperCase(),
      style: TextStyle(
        letterSpacing: 1.5,
        color: Colors.grey,
        fontSize: 12,
      ),
    );

    _wordTextPainter.layout(
      minWidth: 0,
      maxWidth: double.maxFinite,
    );

    final double spacing = 15;
    final double topyY = _countTextPainter.height * 0.5;

    _countTextPainter.paint(
      canvas,
      center.translate(
        -innerRadius + ((_wordTextPainter.width - _countTextPainter.width) / 2) + spacing,
        topyY,
      ),
    );
    _wordTextPainter.paint(
      canvas,
      center.translate(
        -innerRadius + spacing,
        topyY + _countTextPainter.height - 1,
      ),
    );
  }

  void _drawHeartText(Canvas canvas, Offset center, double innerRadius) {
    final _countTextPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    _countTextPainter.text = TextSpan(
      text: heartRate.toString(),
    );

    _countTextPainter.layout(
      minWidth: 0,
      maxWidth: double.maxFinite,
    );

    final _wordTextPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    _wordTextPainter.text = TextSpan(
      text: ('Heart').toUpperCase(),
      style: TextStyle(
        letterSpacing: 1.5,
        color: Colors.grey,
        fontSize: 12,
      ),
    );

    _wordTextPainter.layout(
      minWidth: 0,
      maxWidth: double.maxFinite,
    );

    final double spacing = 15;
    final double topyY = _countTextPainter.height * 0.5;
    final double centerXOffset = ((_wordTextPainter.width - _countTextPainter.width) / 2);

    _countTextPainter.paint(
      canvas,
      center.translate(
        (-innerRadius + centerXOffset + spacing + _countTextPainter.width) * -1,
        topyY,
      ),
    );
    _wordTextPainter.paint(
      canvas,
      center.translate(
        (innerRadius - spacing - _wordTextPainter.width),
        topyY + _countTextPainter.height - 1,
      ),
    );
  }
}
