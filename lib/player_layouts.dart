import 'dart:async';
import 'package:flutter/material.dart';
import 'player_counter.dart';
import 'statistics_manager.dart';
import 'dialogs.dart';
import 'preferences_helper.dart';

Widget buildControlButton({
  required IconData icon,
  required VoidCallback onTap,
  Color? color,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        icon,
        color: color ?? Colors.white,
        size: 24,
      ),
    ),
  );
}

class OnePlayerLayout extends StatefulWidget {
  final int? initiativePlayer;
  final Function(int) onInitiativeClaimed;
  final VoidCallback onShowPlayerCount;

  const OnePlayerLayout({
    super.key,
    required this.initiativePlayer,
    required this.onInitiativeClaimed,
    required this.onShowPlayerCount,
  });

  @override
  State<OnePlayerLayout> createState() => _OnePlayerLayoutState();
}

class _OnePlayerLayoutState extends State<OnePlayerLayout> {
  int playerLife = 20; // Default Sorcery starting life
  int playerAvatarId = 1;
  String playerName = "Player 1";

  bool _showTimer = false;
  bool _timerRunning = false;
  int _timerSeconds = 60 * 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadPlayerPreferences();
  }

  Future<void> _loadPlayerPreferences() async {
    final avatar = await PreferencesHelper.getPlayerAvatar(0); // Assuming same key
    final name = await PreferencesHelper.getPlayerName(0);
    
    setState(() {
      if (avatar != null) playerAvatarId = avatar;
      if (name != null) playerName = name;
    });
  }

  // Timer methods omitted for brevity (keep your existing ones here)

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Container(
            height: 80,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildControlButton(
                  icon: Icons.refresh,
                  onTap: () => setState(() => playerLife = 20),
                ),
                buildControlButton(
                  icon: Icons.people,
                  onTap: widget.onShowPlayerCount,
                ),
                buildControlButton(
                  icon: Icons.timer,
                  color: _showTimer ? Colors.blue : Colors.white,
                  onTap: () => setState(() => _showTimer = !_showTimer),
                ),
                buildControlButton(
                  icon: Icons.info,
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => InfoDialog(onDismissRequest: () => Navigator.pop(context)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PlayerCounter(
              isTopPlayer: false,
              avatarId: playerAvatarId,
              life: playerLife,
              playerName: playerName,
              onNameChange: (newName) {
                setState(() => playerName = newName);
                PreferencesHelper.savePlayerData(playerIndex: 0, avatarId: playerAvatarId, playerName: newName);
              },
              onAvatarChange: (avatarId) {
                setState(() => playerAvatarId = avatarId);
                PreferencesHelper.savePlayerData(playerIndex: 0, avatarId: avatarId, playerName: playerName);
              },
              onLifeChange: (value) => setState(() => playerLife = value),
              initiativePlayer: widget.initiativePlayer,
              onInitiativeClaimed: widget.onInitiativeClaimed,
              playerId: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class TwoPlayerLayout extends StatefulWidget {
  final int? initiativePlayer;
  final Function(int) onInitiativeClaimed;
  final VoidCallback onShowPlayerCount;

  const TwoPlayerLayout({
    super.key,
    required this.initiativePlayer,
    required this.onInitiativeClaimed,
    required this.onShowPlayerCount,
  });

  @override
  State<TwoPlayerLayout> createState() => _TwoPlayerLayoutState();
}

class _TwoPlayerLayoutState extends State<TwoPlayerLayout> {

  int topLife = 20;
  int bottomLife = 20;
  int topAvatarId = 1;
  int bottomAvatarId = 2;
  List<String> playerNames = ["Player 1", "Player 2"];

  @override
  void initState() {
    super.initState();
    _loadPlayerPreferences();
  }

  Future<void> _loadPlayerPreferences() async {
    final topAvatar = await PreferencesHelper.getPlayerAvatar(0);
    final topName = await PreferencesHelper.getPlayerName(0);
    final bottomAvatar = await PreferencesHelper.getPlayerAvatar(1);
    final bottomName = await PreferencesHelper.getPlayerName(1);
    
    setState(() {
      if (topAvatar != null) topAvatarId = topAvatar;
      if (topName != null) playerNames[0] = topName;
      if (bottomAvatar != null) bottomAvatarId = bottomAvatar;
      if (bottomName != null) playerNames[1] = bottomName;
    });
  }

  void _handlePlayerDefeated(int defeatedPlayerId) {
    final winnerName = playerNames[defeatedPlayerId == 0 ? 1 : 0];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VictoryDialog(
        winnerName: winnerName,
        onConfirm: () async {
          await StatisticsManager.incrementPlayerWins(winnerName);
          await StatisticsManager.incrementGamesPlayed();
          Navigator.of(context).pop();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Expanded(
            child: PlayerCounter(
              isTopPlayer: true,
              avatarId: topAvatarId,
              life: topLife,
              playerName: playerNames[0],
              onNameChange: (newName) {
                setState(() => playerNames[0] = newName);
                PreferencesHelper.savePlayerData(playerIndex: 0, avatarId: topAvatarId, playerName: newName);
              },
              onAvatarChange: (id) {
                setState(() => topAvatarId = id);
                PreferencesHelper.savePlayerData(playerIndex: 0, avatarId: id, playerName: playerNames[0]);
              },
              onLifeChange: (value) => setState(() => topLife = value),
              initiativePlayer: widget.initiativePlayer,
              onInitiativeClaimed: widget.onInitiativeClaimed,
              playerId: 0,
              onPlayerDefeated: _handlePlayerDefeated,
            ),
          ),
          Container(
            height: 60,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildControlButton(
                  icon: Icons.people,
                  onTap: widget.onShowPlayerCount,
                ),
                buildControlButton(
                  icon: Icons.refresh,
                  onTap: () => setState(() {
                    topLife = 20;
                    bottomLife = 20;
                  }),
                ),
                buildControlButton(
                  icon: Icons.info,
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => InfoDialog(onDismissRequest: () => Navigator.pop(context)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PlayerCounter(
              isTopPlayer: false,
              avatarId: bottomAvatarId,
              life: bottomLife,
              playerName: playerNames[1],
              onNameChange: (newName) {
                setState(() => playerNames[1] = newName);
                PreferencesHelper.savePlayerData(playerIndex: 1, avatarId: bottomAvatarId, playerName: newName);
              },
              onAvatarChange: (id) {
                setState(() => bottomAvatarId = id);
                PreferencesHelper.savePlayerData(playerIndex: 1, avatarId: id, playerName: playerNames[1]);
              },
              onLifeChange: (value) => setState(() => bottomLife = value),
              initiativePlayer: widget.initiativePlayer,
              onInitiativeClaimed: widget.onInitiativeClaimed,
              playerId: 1,
              onPlayerDefeated: _handlePlayerDefeated,
            ),
          ),
        ],
      ),
    );
  }
}


class ThreePlayerLayout extends StatefulWidget {
  final int? initiativePlayer;
  final Function(int) onInitiativeClaimed;
  final VoidCallback onShowPlayerCount;

  const ThreePlayerLayout({
    super.key,
    required this.initiativePlayer,
    required this.onInitiativeClaimed,
    required this.onShowPlayerCount,
  });

  @override
  State<ThreePlayerLayout> createState() => _ThreePlayerLayoutState();
}

class _ThreePlayerLayoutState extends State<ThreePlayerLayout> {
  List<int> lives = [20, 20, 20];
  List<int> avatarIds = [1, 2, 3];
  List<String> names = ["Player 1", "Player 2", "Player 3"];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Player (Rotated)
        Expanded(
          flex: 2,
          child: _buildCounter(0, isTop: true),
        ),
        // Central Control Bar
        _buildControlBar(),
        // Bottom Two Players (Side-by-Side)
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(child: _buildCounter(1, isTop: false)),
              const VerticalDivider(width: 1, color: Colors.white24),
              Expanded(child: _buildCounter(2, isTop: false)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounter(int index, {required bool isTop}) {
    return PlayerCounter(
      isTopPlayer: isTop,
      life: lives[index],
      playerName: names[index],
      avatarId: avatarIds[index],
      playerId: index,
      initiativePlayer: widget.initiativePlayer,
      onInitiativeClaimed: widget.onInitiativeClaimed,
      onLifeChange: (val) => setState(() => lives[index] = val),
      onAvatarChange: (id) => setState(() => avatarIds[index] = id),
      onNameChange: (name) => setState(() => names[index] = name),
    );
  }

  Widget _buildControlBar() {
    return Container(
      height: 50,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), 
            onPressed: () => setState(() => lives = [20, 20, 20])),
          IconButton(icon: const Icon(Icons.people, color: Colors.white), 
            onPressed: widget.onShowPlayerCount),
        ],
      ),
    );
  }
}

class FourPlayerLayout extends StatefulWidget {
  final int? initiativePlayer;
  final Function(int) onInitiativeClaimed;
  final VoidCallback onShowPlayerCount;

  const FourPlayerLayout({
    super.key,
    required this.initiativePlayer,
    required this.onInitiativeClaimed,
    required this.onShowPlayerCount,
  });

  @override
  State<FourPlayerLayout> createState() => _FourPlayerLayoutState();
}

class _FourPlayerLayoutState extends State<FourPlayerLayout> {
  List<int> lives = [20, 20, 20, 20];
  List<int> avatarIds = [1, 2, 3, 4];
  List<String> names = ["P1", "P2", "P3", "P4"];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Row (P1 & P2 - Rotated)
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildCounter(0, isTop: true)),
              const VerticalDivider(width: 1, color: Colors.white24),
              Expanded(child: _buildCounter(1, isTop: true)),
            ],
          ),
        ),
        // Middle Control Bar
        _buildControlBar(),
        // Bottom Row (P3 & P4 - Normal)
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildCounter(2, isTop: false)),
              const VerticalDivider(width: 1, color: Colors.white24),
              Expanded(child: _buildCounter(3, isTop: false)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounter(int index, {required bool isTop}) {
    return PlayerCounter(
      isTopPlayer: isTop,
      life: lives[index],
      playerName: names[index],
      avatarId: avatarIds[index],
      playerId: index,
      initiativePlayer: widget.initiativePlayer,
      onInitiativeClaimed: widget.onInitiativeClaimed,
      onLifeChange: (val) => setState(() => lives[index] = val),
      onAvatarChange: (id) => setState(() => avatarIds[index] = id),
      onNameChange: (name) => setState(() => names[index] = name),
    );
  }

  Widget _buildControlBar() {
    return Container(
      height: 40,
      color: Colors.black,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.refresh, size: 20, color: Colors.white), 
              onPressed: () => setState(() => lives = [20, 20, 20, 20])),
            IconButton(icon: const Icon(Icons.people, size: 20, color: Colors.white), 
              onPressed: widget.onShowPlayerCount),
          ],
        ),
      ),
    );
  }
}