import 'package:flutter/material.dart';

IconData iconFromName(String name) {
  final lowerName = name.toLowerCase();

  // Science and Physics related
  if (lowerName.contains('physics') ||
      lowerName.contains('science') ||
      lowerName.contains('scientific')) {
    return Icons.book;
  }

  // Mathematics related
  if (lowerName.contains('math') ||
      lowerName.contains('mathematics') ||
      lowerName.contains('algebra') ||
      lowerName.contains('calculus') ||
      lowerName.contains('geometry')) {
    return Icons.calculate;
  }

  // Language and Literature related
  if (lowerName.contains('language') ||
      lowerName.contains('english') ||
      lowerName.contains('literature') ||
      lowerName.contains('grammar') ||
      lowerName.contains('writing')) {
    return Icons.language;
  }

  if (lowerName.contains('civics')) {
    return Icons.balance;
  }

  // Biology and Life Sciences
  if (lowerName.contains('biology') ||
      lowerName.contains('bio') ||
      lowerName.contains('life science') ||
      lowerName.contains('anatomy')) {
    return Icons.nature;
  }

  // Chemistry related
  if (lowerName.contains('chemistry') ||
      lowerName.contains('chemical') ||
      lowerName.contains('molecule')) {
    return Icons.science;
  }

  // Computer Science and Technology
  if (lowerName.contains('computer') ||
      lowerName.contains('programming') ||
      lowerName.contains('coding') ||
      lowerName.contains('technology') ||
      lowerName.contains('digital')) {
    return Icons.computer;
  }

  // History and Social Studies
  if (lowerName.contains('history') || lowerName.contains('global')) {
    return Icons.public;
  }

  if (lowerName.contains('anthropology')) {
    return Icons.groups_3;
  }

  if (lowerName.contains('geography')) {
    return Icons.map;
  }

  if (lowerName.contains('logic')) {
    return Icons.psychology_alt;
  }

  // Economics and Business
  if (lowerName.contains('economics') ||
      lowerName.contains('business') ||
      lowerName.contains('commerce') ||
      lowerName.contains('finance')) {
    return Icons.monetization_on;
  }

  // Psychology and Sociology
  if (lowerName.contains('psychology') ||
      lowerName.contains('sociology') ||
      lowerName.contains('behavior') ||
      lowerName.contains('mental')) {
    return Icons.psychology;
  }

  // Arts and Design
  if (lowerName.contains('art') ||
      lowerName.contains('design') ||
      lowerName.contains('drawing') ||
      lowerName.contains('painting') ||
      lowerName.contains('creative')) {
    return Icons.brush;
  }

  // Environmental Science
  if (lowerName.contains('environment') ||
      lowerName.contains('ecology') ||
      lowerName.contains('sustainability')) {
    return Icons.eco;
  }

  // Health and Physical Education
  if (lowerName.contains('health') ||
      lowerName.contains('physical') ||
      lowerName.contains('sports') ||
      lowerName.contains('fitness')) {
    return Icons.fitness_center;
  }

  // Music and Performing Arts
  if (lowerName.contains('music') ||
      lowerName.contains('dance') ||
      lowerName.contains('theater') ||
      lowerName.contains('performing')) {
    return Icons.music_note;
  }

  if (lowerName.contains('inclusiveness')) {
    return Icons.group;
  }

  // Religious Studies
  if (lowerName.contains('religion') || lowerName.contains('theology')) {
    return Icons.church;
  }

  // Default case
  return Icons.help_outline;
}
