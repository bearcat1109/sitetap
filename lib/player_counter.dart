import 'package:flutter/material.dart';
import 'dart:math';
import 'models.dart';
import 'dialogs.dart';

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

class _PlayerCounterState extends State<PlayerCounter> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  bool showDamageIndicator = false;
  int currentChange = 0;
  final damageAccumulator = DamageAccumulator();

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // Logic for Sorcery: Death occurs at -1
  void _handleLifeChange(int change) {
    if (widget.life < 0) return; // Already dead

    final newLife = widget.life + change;
    final accumulatedChange = damageAccumulator.addDamage(change);

    setState(() {
      currentChange = accumulatedChange;
      showDamageIndicator = true;
    });

    widget.onLifeChange(newLife);

    if (change < 0) {
      _shakeController.forward(from: 0.0);
    }

    // Trigger defeat only when life goes BELOW zero
    if (newLife < 0 && widget.life >= 0) {
      widget.onPlayerDefeated?.call(widget.playerId);
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => showDamageIndicator = false);
    });
  }

  // The missing method that was causing your error
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

    return RotatedBox(
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
            // 1. Life Display Layer (Middle)
            IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isAtDeathsDoor)
                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 30),
                    Text(
                      isDefeated ? "DEAD" : "${widget.life}",
                      style: TextStyle(
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
                        style: TextStyle(
                          color: Colors.red, 
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 1.2,
                          fontSize: 16
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 2. Interaction Layer (This must be above the life text to catch taps)
            Positioned.fill(
              child: Row(
                children: [
                  // Minus Side (Left)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleLifeChange(-1),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: Icon(
                          Icons.remove_circle_outline,
                          color: Colors.white.withOpacity(0.2),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  // Plus Side (Right)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleLifeChange(1),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.add_circle_outline,
                          color: Colors.white.withOpacity(0.2),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Status Overlays (Top)
            if (isDefeated) Container(color: Colors.black.withOpacity(0.7)),
            
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
                      style: TextStyle(
                        color: currentChange > 0 ? Colors.green : Colors.red,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        shadows: const [Shadow(color: Colors.black, blurRadius: 10.0)],
                      ),
                    ),
                  ),
                ),
              ),
          ],
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
                color: widget.initiativePlayer == widget.playerId
                    ? Colors.amber.withOpacity(0.8)
                    : Colors.black.withOpacity(0.3),
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
              child: Center(
                child: Text(
                  widget.playerName,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}