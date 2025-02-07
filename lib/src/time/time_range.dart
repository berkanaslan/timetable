import 'package:flutter/foundation.dart';

import '../utils.dart';
import 'controller.dart';

/// The value held by [TimeController].
@immutable
class TimeRange {
  TimeRange(this.startTime, this.endTime)
      : assert(startTime.debugCheckIsValidTimetableTimeOfDay()),
        assert(endTime.debugCheckIsValidTimetableTimeOfDay()),
        assert(startTime <= endTime);
  factory TimeRange.fromStartAndDuration(
    Duration startTime,
    Duration duration,
  ) =>
      TimeRange(startTime, startTime + duration);

  factory TimeRange.centeredAround(
    Duration center,
    Duration duration, {
    bool canShiftIfDoesntFit = true,
  }) {
    assert(duration <= 1.days);

    final TimeRange newRange;
    final halfDuration = duration * (1 / 2);
    if (center - halfDuration < 0.days) {
      assert(canShiftIfDoesntFit);
      newRange = TimeRange(0.days, duration);
    } else if (center + halfDuration > 1.days) {
      assert(canShiftIfDoesntFit);
      newRange = TimeRange(1.days - duration, 1.days);
    } else {
      newRange = TimeRange(
        // Ensure that the resulting duration is exactly [duration], even if
        // [halfDuration] was rounded.
        center - duration + halfDuration,
        center + halfDuration,
      );
    }
    assert(newRange.duration == duration);
    return newRange;
  }

  static final fullDay = TimeRange(0.days, 1.days);

  final Duration startTime;
  Duration get centerTime => startTime + duration * (1 / 2);
  final Duration endTime;
  Duration get duration => endTime - startTime;

  bool contains(TimeRange other) =>
      startTime <= other.startTime && other.endTime <= endTime;

  // ignore: prefer_constructors_over_static_methods
  static TimeRange lerp(TimeRange a, TimeRange b, double t) {
    return TimeRange(
      lerpDuration(a.startTime, b.startTime, t),
      lerpDuration(a.endTime, b.endTime, t),
    );
  }

  @override
  int get hashCode => Object.hash(startTime, endTime);
  @override
  bool operator ==(Object other) {
    return other is TimeRange &&
        startTime == other.startTime &&
        endTime == other.endTime;
  }

  @override
  String toString() => 'TimeRange($startTime – $endTime)';
}
