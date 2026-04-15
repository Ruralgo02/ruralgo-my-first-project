import 'package:flutter/material.dart';

class Store {
  final String name;
  final String imageUrl;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;

  Store({
    required this.name,
    required this.imageUrl,
    required this.openTime,
    required this.closeTime,
  });

  bool get isOpen {
    final now = TimeOfDay.now();
    return _toMinutes(now) >= _toMinutes(openTime) &&
        _toMinutes(now) <= _toMinutes(closeTime);
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
}