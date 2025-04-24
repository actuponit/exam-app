import 'package:flutter/material.dart';

IconData iconFromName(String name) {
  switch (name.toLowerCase()) {
    case 'book':
      return Icons.book;
    case 'calculate':
      return Icons.calculate;
    case 'language':
      return Icons.language;
    case 'science':
      return Icons.science;
    case 'psychology':
      return Icons.psychology;
    case 'eco':
      return Icons.eco;
    case 'computer':
      return Icons.computer;
    case 'history':
      return Icons.history;
    case 'art':
      return Icons.brush;
    case 'flask':
      return Icons.local_drink;
    case 'leaf':
      return Icons.nature;
    default:
      return Icons.help_outline;
  }
}
