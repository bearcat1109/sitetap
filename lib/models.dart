import 'package:flutter/material.dart';
import 'dart:math';


// Leader class for character images
class Avatar {
  final int id;
  final String name;
  final String imagePath;

  const Avatar({
    required this.id,
    required this.name,
    required this.imagePath,
  });

  static Avatar? findById(int id) {
    return avatars.firstWhere((leader) => leader.id == id, orElse: () => avatars[0]);
  }
}

// Damage tracker for handling accumulated damage
class DamageAccumulator {
  int _accumulatedDamage = 0;
  DateTime _lastDamageTime = DateTime.now();

  int addDamage(int damage) {
    final currentTime = DateTime.now();
    if (currentTime.difference(_lastDamageTime).inMilliseconds > 1000) {
      // Reset if more than 1 second has passed
      _accumulatedDamage = damage;
    } else {
      _accumulatedDamage += damage;
    }
    _lastDamageTime = currentTime;
    return _accumulatedDamage;
  }
}

// Random death message generator
String getRandomDeathMessage() {
  final deathMessages = [
    "Defeated.",
    "K.O.'d!",
    "Game Over",
    "Oof.",
    "RIP.",
    ":("
  ];
  return deathMessages[Random().nextInt(deathMessages.length)];
}

final avatars = [
    const Avatar(id: 1, name: "Spellslinger", imagePath: "assets/images/avatars/spellslinger.webp"),
    const Avatar(id: 2, name: "Sorcerer", imagePath: "assets/images/avatars/sorcerer.webp")
];