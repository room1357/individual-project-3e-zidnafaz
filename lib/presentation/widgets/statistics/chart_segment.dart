import 'package:flutter/material.dart';

class ChartSegment {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  
  ChartSegment({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
}