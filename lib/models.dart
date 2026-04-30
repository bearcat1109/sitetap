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
    const Avatar(id: 1, name: "Witch", imagePath: "assets/images/avatars/witch.webp"),
    const Avatar(id: 2, name: "Waveshaper", imagePath: "assets/images/avatars/waveshaper.webp"),
    const Avatar(id: 3, name: "Templar", imagePath: "assets/images/avatars/templar.webp"),
    const Avatar(id: 4, name: "Spellslinger", imagePath: "assets/images/avatars/spellslinger.webp"),
    const Avatar(id: 5, name: "Sparkmage", imagePath: "assets/images/avatars/sparkmage.webp"),
    const Avatar(id: 6, name: "Sorcerer", imagePath: "assets/images/avatars/sorcerer.webp"),
    const Avatar(id: 7, name: "Seer", imagePath: "assets/images/avatars/seer.webp"),
    const Avatar(id: 8, name: "Savior", imagePath: "assets/images/avatars/savior.webp"),
    const Avatar(id: 9, name: "Realm-Eater", imagePath: "assets/images/avatars/realm-eater.webp"),
    const Avatar(id: 10, name: "Persecutor", imagePath: "assets/images/avatars/Persecutor.webp"),
    const Avatar(id: 11, name: "Pathfinder", imagePath: "assets/images/avatars/Pathfinder.webp"),
    const Avatar(id: 12, name: "Necromancer", imagePath: "assets/images/avatars/Necromancer.webp"),
    const Avatar(id: 13, name: "Magician", imagePath: "assets/images/avatars/magician.webp"),
    const Avatar(id: 14, name: "Ironclad", imagePath: "assets/images/avatars/ironclad.webp"),
    const Avatar(id: 15, name: "Interrogator", imagePath: "assets/images/avatars/interrogator.webp"),
    const Avatar(id: 16, name: "Imposter", imagePath: "assets/images/avatars/imposter.webp"),
    const Avatar(id: 17, name: "Harbinger", imagePath: "assets/images/avatars/harbinger.webp"),
    const Avatar(id: 18, name: "Geomancer", imagePath: "assets/images/avatars/geomancer.webp"),
    const Avatar(id: 19, name: "Flamecaller", imagePath: "assets/images/avatars/flamecaller.webp"),
    const Avatar(id: 20, name: "Enchantress", imagePath: "assets/images/avatars/enchantress.webp"),
    const Avatar(id: 21, name: "Elementalist", imagePath: "assets/images/avatars/elementalist.webp"),
    const Avatar(id: 22, name: "Duplicator", imagePath: "assets/images/avatars/duplicator.webp"),
    const Avatar(id: 23, name: "Druid", imagePath: "assets/images/avatars/druid.webp"),
    const Avatar(id: 24, name: "Dragonlord", imagePath: "assets/images/avatars/dragonlord.webp"),
    const Avatar(id: 25, name: "Deathspeaker", imagePath: "assets/images/avatars/deathspeaker.webp"),
    const Avatar(id: 26, name: "Corruptor", imagePath: "assets/images/avatars/corruptor.webp"),
    const Avatar(id: 27, name: "Bladedancer", imagePath: "assets/images/avatars/bladedancer.webp"),
    const Avatar(id: 28, name: "Battlemage", imagePath: "assets/images/avatars/battlemage.webp"),
    const Avatar(id: 29, name: "Avatar of Water", imagePath: "assets/images/avatars/avatar-of-water.webp"),
    const Avatar(id: 30, name: "Avatar of Fire", imagePath: "assets/images/avatars/avatar-of-fire.webp"),
    const Avatar(id: 31, name: "Avatar of Earth", imagePath: "assets/images/avatars/avatar-of-earth.webp"),
    const Avatar(id: 32, name: "Avatar of Air", imagePath: "assets/images/avatars/avatar-of-air.webp"),
    const Avatar(id: 33, name: "Archimago", imagePath: "assets/images/avatars/archimago.webp"),
    const Avatar(id: 34, name: "Animist", imagePath: "assets/images/avatars/animist.webp"),
    const Avatar(id:35 , name: "Who up pondering they orb?", imagePath: "assets/orb.gif"),
];