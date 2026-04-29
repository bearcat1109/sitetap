import 'package:flutter/material.dart';
import 'statistics_manager.dart';
import 'models.dart';

// First time welcome dialog
class FirstTimeWelcomeDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const FirstTimeWelcomeDialog({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Welcome to SiteTap!'),
      content: const Text(
        "All images and Star Wars property of Disney and Fantasy Flight Games. \n\n" "SiteTap is a life counter app designed for Sorcery: Contested Realm." "This app was created as a personal project, and is and will always be free.I do not own any of the images or characters used.\n\n" "Created by Bearcat!\n" "Youtube.com/@bearcatmakesgames\n\n" +
            "Feedback is awesome. Please email feedback or bugs to bearcatfeedback@gmail.com\n\n" +
            "Want to support the development of SiteTap? You rock! PayPal.me/BearcatCodes",
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text('Got it!'),
        ),
      ],
    );
  }
}

// Player name and avatar selectiond dialog
class PlayerNameDialog extends StatefulWidget {
  final String initialName;
  final int leaderId; // This is your Avatar ID
  final VoidCallback onDismissRequest;
  
  // UPDATE: Change from Function(String, int, int) to Function(String, int)
  final Function(String, int) onConfirm; 

  const PlayerNameDialog({
    super.key,
    required this.initialName,
    // REMOVED: required this.baseId,
    required this.leaderId,
    required this.onDismissRequest,
    required this.onConfirm,
  });

  @override
  State<PlayerNameDialog> createState() => _PlayerNameDialogState();
}

class _PlayerNameDialogState extends State<PlayerNameDialog> {
  late TextEditingController _nameController;
  late int _selectedBaseId;
  late int _selectedLeaderId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedLeaderId = widget.leaderId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedLeader = Avatar.findById(_selectedLeaderId);

    return AlertDialog(
      title: const Text('Player Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Player name input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Player Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Leader selection
            Card(
              child: ListTile(
                title: Text('Leader: ${selectedLeader?.name ?? "Unknown"}'),
                leading: selectedLeader?.imagePath != null
                    ? CircleAvatar(
                  backgroundImage: AssetImage(selectedLeader!.imagePath),
                  onBackgroundImageError: (_, __) {
                    // Handle image loading error
                  },
                )
                    : const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                onTap: () => _showLeaderSelector(context),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onDismissRequest,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onConfirm(
              _nameController.text.trim().isEmpty
                  ? widget.initialName
                  : _nameController.text.trim(),
              _selectedLeaderId, // Only pass the Leader/Avatar ID
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }


  void _showLeaderSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _LeaderSelectorDialog(
        selectedLeaderId: _selectedLeaderId,
        onLeaderSelected: (leaderId) {
          setState(() {
            _selectedLeaderId = leaderId;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// Separate stateful widget for leader selector with search
class _LeaderSelectorDialog extends StatefulWidget {
  final int selectedLeaderId;
  final Function(int) onLeaderSelected;

  const _LeaderSelectorDialog({
    required this.selectedLeaderId,
    required this.onLeaderSelected,
  });

  @override
  State<_LeaderSelectorDialog> createState() => _LeaderSelectorDialogState();
}

class _LeaderSelectorDialogState extends State<_LeaderSelectorDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Avatar> _filteredLeaders = avatars;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterLeaders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLeaders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLeaders = avatars;
      } else {
        _filteredLeaders = avatars.where((leader) {
          return leader.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Leader'),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Leaders',
                hintText: 'Type to search...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            // Results count
            if (_searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${_filteredLeaders.length} result${_filteredLeaders.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            // Leader list
            Expanded(
              child: _filteredLeaders.isEmpty
                  ? const Center(
                child: Text(
                  'No leaders found',
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredLeaders.length,
                itemBuilder: (context, index) {
                  final leader = _filteredLeaders[index];
                  return ListTile(
                    title: Text(leader.name),
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(leader.imagePath),
                      onBackgroundImageError: (_, __) {
                        // Handle image loading error
                      },
                      child: const Icon(Icons.person), // Fallback icon
                    ),
                    selected: leader.id == widget.selectedLeaderId,
                    onTap: () => widget.onLeaderSelected(leader.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}


// Info dialog
class InfoDialog extends StatelessWidget {
  final VoidCallback onDismissRequest;

  const InfoDialog({super.key, required this.onDismissRequest});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('About BaseTap'),
      content: const SingleChildScrollView(
        child: Text(
          'SiteTap is a life counter app for Sorcery..\n\n'
          'All images and cards used do not belong to me. They are property of Curiosa Games.\n\n'
              
        ),
      ),
      actions: [
        TextButton(
          onPressed: onDismissRequest,
          child: const Text('Close'),
        ),
      ],
    );
  }
}

// Victory confirmation dialog - NEW
class VictoryDialog extends StatelessWidget {
  final String winnerName;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const VictoryDialog({
    super.key,
    required this.winnerName,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Victory!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            '$winnerName has won the game!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Record this victory?',
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Record Win'),
        ),
      ],
    );
  }
}

// Statistics screen dialog - NEW
class StatisticsDialog extends StatefulWidget {
  final VoidCallback onDismissRequest;

  const StatisticsDialog({super.key, required this.onDismissRequest});

  @override
  State<StatisticsDialog> createState() => _StatisticsDialogState();
}

class _StatisticsDialogState extends State<StatisticsDialog> {
  Map<String, int> playerStats = {};
  int totalGames = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await StatisticsManager.getAllPlayerStats();
    final games = await StatisticsManager.getTotalGamesPlayed();

    setState(() {
      playerStats = stats;
      totalGames = games;
      isLoading = false;
    });
  }

  Future<void> _resetStats() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Statistics'),
        content: const Text(
          'Are you sure you want to reset all statistics? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StatisticsManager.resetAllStats();
      _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Sort players by wins (descending)
    final sortedPlayers = playerStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Statistics'),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Statistics',
            onPressed: _resetStats,
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // Total games summary
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Games Played:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$totalGames',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Player statistics list
            if (sortedPlayers.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No statistics yet.\nPlay some games to see your stats!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: sortedPlayers.length,
                  itemBuilder: (context, index) {
                    final entry = sortedPlayers[index];
                    final playerName = entry.key;
                    final wins = entry.value;
                    final winPercentage = totalGames > 0
                        ? (wins / totalGames * 100).toStringAsFixed(1)
                        : '0.0';

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: index == 0
                              ? Colors.amber
                              : index == 1
                              ? Colors.grey
                              : index == 2
                              ? Colors.brown
                              : Colors.blue,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          playerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text('$wins wins'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$winPercentage%',
                            style: TextStyle(
                              color: Colors.green.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onDismissRequest,
          child: const Text('Close'),
        ),
      ],
    );
  }
}