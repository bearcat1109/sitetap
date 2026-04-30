import 'package:flutter/material.dart';
import 'dart:math';
import 'models.dart';
import 'dialogs.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerCounter extends StatefulWidget {
  final bool isTopPlayer;
  final int life;
  final String playerName;
  final Function(String) onNameChange;
  final Function(int) onLifeChange;
  final int? initiativePlayer;
  final Function(int)? onInitiativeClaimed;
  final int playerId;
  final int avatarId;
  final Function(int) onAvatarChange;
  final Function(int)? onPlayerDefeated;

  const PlayerCounter({
    super.key,
    required this.isTopPlayer,
    required this.life,
    required this.playerName,
    required this.onNameChange,
    required this.onLifeChange,
    required this.initiativePlayer,
    required this.onInitiativeClaimed,
    required this.playerId,
    required this.avatarId,
    required this.onAvatarChange,
    this.onPlayerDefeated,
  });

  @override
  State<PlayerCounter> createState() => _PlayerCounterState();
}

class _PlayerCounterState extends State<PlayerCounter> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _particleController;
  
  bool showDamageIndicator = false;
  int currentChange = 0;
  final damageAccumulator = DamageAccumulator();

  // For affinity trackers
  List<int> affinities = [0, 0, 0, 0]; // Earth, Fire, Water, Air
  void _updateAffinity(int index, int delta) {
    setState(() {
      affinities[index] = (affinities[index] + delta).clamp(0, 9);
    });
  }
  
  // Particle system state
  List<HealingParticle> particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Impact/Shake Animation
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // Particle Animation Controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        setState(() {
          for (var p in particles) {
            p.update();
          }
          // Cleanup invisible particles to save memory
          particles.removeWhere((p) => p.opacity <= 0);
        });
      });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _triggerHealingParticles() {
    // Generate a burst of green particles
    final newParticles = List.generate(15, (index) {
      return HealingParticle(
        x: MediaQuery.of(context).size.width / 4, // Center of player half
        y: MediaQuery.of(context).size.height / 4,
        size: _random.nextDouble() * 5 + 2,
        opacity: 1.0,
        velocityX: (_random.nextDouble() - 0.5) * 6,
        velocityY: (_random.nextDouble() - 0.5) * 6 - 2, // Slight upward drift
      );
    });

    setState(() {
      particles.addAll(newParticles);
    });
    _particleController.forward(from: 0.0);
  }

  void _handleLifeChange(int change) {
    if (widget.life < 0) return; // Already defeated

    final newLife = widget.life + change;
    final accumulatedChange = damageAccumulator.addDamage(change);

    setState(() {
      currentChange = accumulatedChange;
      showDamageIndicator = true;
    });

    // Effects logic
    if (change < 0) {
      _shakeController.forward(from: 0.0); // Shake on damage
    } else if (change > 0) {
      _triggerHealingParticles(); // Particles on heal
    }

    widget.onLifeChange(newLife);

    // Sorcery Defeat: Check if life dropped BELOW zero
    if (newLife < 0 && widget.life >= 0) {
      widget.onPlayerDefeated?.call(widget.playerId);
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showDamageIndicator = false;
        });
      }
    });
  }

  void _showPlayerNameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PlayerNameDialog(
        initialName: widget.playerName,
        leaderId: widget.avatarId,
        onDismissRequest: () => Navigator.of(context).pop(),
        onConfirm: (name, avatarId) {
          widget.onNameChange(name);
          widget.onAvatarChange(avatarId);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = Avatar.findById(widget.avatarId);
    final isAtDeathsDoor = widget.life == 0;
    final isDefeated = widget.life < 0;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        // Calculate shake offset based on sine wave
        double offsetX = 0.0;
        if (_shakeController.isAnimating) {
          offsetX = sin(_shakeController.value * 10 * pi) * 8.0;
        }
        return Transform.translate(
          offset: Offset(offsetX, 0.0),
          child: child,
        );
      },
      child: RotatedBox(
        quarterTurns: widget.isTopPlayer ? 2 : 0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            image: avatar?.imagePath != null
                ? DecorationImage(
                    image: AssetImage(avatar!.imagePath),
                    fit: BoxFit.cover,
                    opacity: isDefeated ? 0.2 : (isAtDeathsDoor ? 0.4 : 0.6),
                  )
                : null,
          ),
          child: Stack(
            children: [
              // 1. Particle Layer (Background)
              if (particles.isNotEmpty)
                IgnorePointer(
                  child: CustomPaint(
                    painter: ParticlePainter(particles),
                    size: Size.infinite,
                  ),
                ),

              // 2. Life Display
              IgnorePointer(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isAtDeathsDoor)
                        const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 30),
                      Text(
                        isDefeated ? "DEAD" : "${widget.life}",
                        style: GoogleFonts.cinzelDecorative(
                          color: isAtDeathsDoor || isDefeated ? Colors.red : Colors.white,
                          fontSize: isDefeated ? 60 : 100,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: isAtDeathsDoor ? Colors.red.withOpacity(0.5) : Colors.black,
                              blurRadius: isAtDeathsDoor ? 20.0 : 12.0,
                            )
                          ],
                        ),
                      ),
                      if (isAtDeathsDoor)
                        const Text(
                          "DEATH'S DOOR",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                    ],
                  ),
                ),
              ),

              // 3. Interaction Layer (Plus/Minus buttons)
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _handleLifeChange(-1),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: Icon(Icons.remove_circle_outline, color: Colors.white.withOpacity(0.15), size: 40),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _handleLifeChange(1),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: Icon(Icons.add_circle_outline, color: Colors.white.withOpacity(0.15), size: 40),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Overlays
              if (isDefeated) Container(color: Colors.black.withOpacity(0.75)),

              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: _buildHeader(),
              ),

              if (showDamageIndicator)
                IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Text(
                        currentChange > 0 ? "+$currentChange" : "$currentChange",
                        style: GoogleFonts.cinzelDecorative(
                          color: currentChange > 0 ? Colors.greenAccent : Colors.redAccent,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          shadows: const [Shadow(color: Colors.black, blurRadius: 10.0)],
                        ),
                      ),
                    ),
                  ),
                ),

              // Inside the Stack in player_counter.dart
              Positioned(
                bottom: 35,
                left: 0,
                right: 0,
                child: Container(
                  height: 50,
                  color: Colors.black45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) => _buildAffinityItem(index)),
                  ),
                ),
              ),  

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (widget.onInitiativeClaimed != null)
          GestureDetector(
            onTap: () => widget.onInitiativeClaimed!(widget.playerId),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: widget.initiativePlayer == widget.playerId ? Colors.amber.withOpacity(0.8) : Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 24),
            ),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => _showPlayerNameDialog(context),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Center(child: Text(widget.playerName, style: const TextStyle(color: Colors.white))),
            ),
          ),
        ),
      ],
    );
  }

  // For affinity counters
      Widget _buildAffinityItem(int index) {
      final List<Color> elementColors = [
        const Color(0xFF795548), // Earth
        const Color(0xFFFF5722), // Fire
        const Color(0xFF2196F3), // Water
        const Color(0xFFE0E0E0)  // Air
      ];

      return Expanded(
        child: GestureDetector(
          onTap: () => _updateAffinity(index, 1),
          onLongPress: () => _updateAffinity(index, -1),
          behavior: HitTestBehavior.opaque,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                // Top border for element color
                top: BorderSide(color: elementColors[index], width: 3),
                // Left border for the divider (only if it's not the first item)
                left: index > 0 
                    ? const BorderSide(color: Colors.white10, width: 0.5) 
                    : BorderSide.none,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${affinities[index]}',
                  style: GoogleFonts.cinzelDecorative(
                    color: elementColors[index],
                    fontWeight: FontWeight.bold,
                    fontSize: 16, 
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
   
}

// For healing animation
class HealingParticle {
  double x, y, size, opacity;
  final double velocityX, velocityY;

  HealingParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.velocityX,
    required this.velocityY,
  });

  void update() {
    x += velocityX;
    y += velocityY;
    opacity = (opacity - 0.02).clamp(0.0, 1.0);
  }
}

class ParticlePainter extends CustomPainter {
  final List<HealingParticle> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (var p in particles) {
      paint.color = Colors.greenAccent.withOpacity(p.opacity);
      
      // Create a diamond path
      final path = Path();
      // Start at the top point
      path.moveTo(p.x, p.y - p.size); 
      // Right point
      path.lineTo(p.x + p.size, p.y); 
      // Bottom point
      path.lineTo(p.x, p.y + p.size); 
      // Left point
      path.lineTo(p.x - p.size, p.y); 
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


