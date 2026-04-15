import 'package:flutter/material.dart';

class ShopHours {
  // GLOBAL HOURS (change these)
  static const int openHour = 6;
  static const int openMinute = 0;

  static const int closeHour = 23;
  static const int closeMinute = 0;

  static bool isOpenNow([DateTime? now]) {
    now ??= DateTime.now();

    final open = DateTime(now.year, now.month, now.day, openHour, openMinute);
    final close = DateTime(now.year, now.month, now.day, closeHour, closeMinute);

    // if close is after midnight, handle it:
    if (close.isBefore(open)) {
      // open today, close tomorrow
      final closeTomorrow = close.add(const Duration(days: 1));
      return now.isAfter(open) && now.isBefore(closeTomorrow);
    }

    return now.isAfter(open) && now.isBefore(close);
  }

  static TimeOfDay nextOpenTime([DateTime? now]) {
    now ??= DateTime.now();
    return const TimeOfDay(hour: openHour, minute: openMinute);
  }
}