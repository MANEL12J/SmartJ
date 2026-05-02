import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/event.dart';
import '../../models/participation.dart';
import '../../models/rider.dart';
import '../../models/horse.dart';

class JudgeEventRunningScreen extends StatefulWidget {
  final Event event;

  const JudgeEventRunningScreen({
    super.key,
    required this.event,
  });

  @override
  State<JudgeEventRunningScreen> createState() =>
      _JudgeEventRunningScreenState();
}

class _JudgeEventRunningScreenState extends State<JudgeEventRunningScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Participation> _participations = [];
  Map<String, Rider> _riders = {};
  Map<String, Horse> _horses = {};
  bool _isLoading = true;

  int _currentRiderIndex = 0;
  bool _isRunning = false;
  bool _isFinished = false;

  // Timer
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  // Score
  final TextEditingController _scoreController = TextEditingController();
  double? _aiSuggestedScore;
  bool _isDisqualified = false;

  @override
  void initState() {
    super.initState();
    _loadParticipations();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _loadParticipations() async {
    try {
      final participations = await _firebaseService
          .getParticipationsByEvent(widget.event.id ?? '');

      // Load rider and horse info
      final riders = await _firebaseService.getRiders();
      final horses = await _firebaseService.getHorses();

      final riderMap = <String, Rider>{};
      for (var r in riders) {
        if (r.id != null) riderMap[r.id!] = r;
      }

      final horseMap = <String, Horse>{};
      for (var h in horses) {
        if (h.id != null) horseMap[h.id!] = h;
      }

      setState(() {
        _participations = participations;
        _riders = riderMap;
        _horses = horseMap;
        _isLoading = false;

        if (participations.isEmpty) {
          _currentRiderIndex = 0;
          _isFinished = true;
        } else {
          // Find first rider that hasn't passed yet
          _currentRiderIndex =
              participations.indexWhere((p) => p.statut == 'en_attente');
          if (_currentRiderIndex == -1) {
            // All riders have passed
            _currentRiderIndex = 0;
            _isFinished = true;
          }
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Erreur lors du chargement: $e');
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _stopwatch = Stopwatch()..start();
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          _elapsed = _stopwatch.elapsed;
        });
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _stopwatch.stop();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _stopwatch.stop();
    setState(() {
      _isRunning = false;
      _elapsed = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final centiseconds = (duration.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$centiseconds';
  }

  void _generateAIScore() {
    // Simulate AI score generation based on barème and time
    // In a real app, this would call an AI model
    final bareme = widget.event.bareme;
    double baseScore = 0;

    if (bareme.contains('A')) {
      // Barème A: score based on faults + time
      baseScore = _elapsed.inSeconds.toDouble();
    } else if (bareme == 'C') {
      // Barème C: style score
      baseScore = 5.0 + (_elapsed.inSeconds * 0.1);
    } else {
      baseScore = 0.0;
    }

    setState(() {
      _aiSuggestedScore = double.parse(baseScore.toStringAsFixed(2));
      _scoreController.text = _aiSuggestedScore.toString();
    });
  }

  Future<void> _saveScore() async {
    if (_currentRiderIndex < 0 || _currentRiderIndex >= _participations.length) {
      return;
    }

    final participation = _participations[_currentRiderIndex];
    final score = double.tryParse(_scoreController.text) ?? 0.0;
    final status = _isDisqualified ? 'disqualifie' : 'passe';

    try {
      await _firebaseService.updateParticipationScoreAndStatus(
        participation.id ?? '',
        score,
        status,
      );

      setState(() {
        _participations[_currentRiderIndex] = participation.copyWith(
          score: score,
          statut: status,
        );
      });

      _showSuccess(
          'Score enregistré pour ${_getRiderName(participation.riderId)}');

      // Move to next rider
      _nextRider();
    } catch (e) {
      _showError('Erreur: $e');
    }
  }

  void _nextRider() {
    _stopTimer();
    _resetTimer();
    _scoreController.clear();
    _aiSuggestedScore = null;
    _isDisqualified = false;

    int nextIndex = _participations.indexWhere(
      (p) => p.statut == 'en_attente',
    );

    if (nextIndex == -1) {
      setState(() {
        _isFinished = true;
        _currentRiderIndex = 0;
      });
    } else {
      setState(() {
        _currentRiderIndex = nextIndex;
      });
    }
  }

  void _disqualifyRider() {
    setState(() {
      _isDisqualified = true;
      _scoreController.text = '0';
    });
  }

  String _getRiderName(String riderId) {
    final rider = _riders[riderId];
    if (rider != null) {
      return '${rider.prenom} ${rider.nom}';
    }
    return 'Cavalier inconnu';
  }

  String _getHorseName(String horseId) {
    final horse = _horses[horseId];
    return horse?.nom ?? 'Cheval inconnu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Left: Rider list
                _buildRiderList(),
                // Center + Right: Running area
                Expanded(
                  child:
                      _isFinished ? _buildFinishedView() : _buildRunningArea(),
                ),
              ],
            ),
    );
  }

  Widget _buildRiderList() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.green[800],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.green[900]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.nom,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.event.bareme} — ${widget.event.hauteur}m',
                  style: TextStyle(fontSize: 12, color: Colors.green[200]),
                ),
              ],
            ),
          ),
          // Rider list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _participations.length,
              itemBuilder: (context, index) {
                final p = _participations[index];
                final isCurrent = index == _currentRiderIndex && !_isFinished;
                final isPast = p.statut == 'passe' || p.statut == 'disqualifie';
                final isDisqualified = p.statut == 'disqualifie';

                Color bgColor;
                if (isCurrent) {
                  bgColor = Colors.white.withOpacity(0.2);
                } else if (isDisqualified) {
                  bgColor = Colors.red.withOpacity(0.3);
                } else if (isPast) {
                  bgColor = Colors.green.withOpacity(0.15);
                } else {
                  bgColor = Colors.transparent;
                }

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: isCurrent
                        ? const Border(
                            left: BorderSide(color: Colors.white, width: 4))
                        : const Border(
                            left: BorderSide(
                                color: Colors.transparent, width: 4)),
                  ),
                  child: Row(
                    children: [
                      // Order number
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? Colors.white
                              : isPast
                                  ? Colors.green[400]
                                  : Colors.green[600],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            '${p.ordrePassage}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  isCurrent ? Colors.green[800] : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Rider info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getRiderName(p.riderId),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isCurrent
                                    ? Colors.white
                                    : Colors.green[100],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _getHorseName(p.horseId),
                              style: TextStyle(
                                fontSize: 11,
                                color: isCurrent
                                    ? Colors.green[200]
                                    : Colors.green[300],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Score or status
                      if (isPast)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDisqualified
                                ? Colors.red[700]
                                : Colors.green[600],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isDisqualified
                                ? 'DISQ'
                                : p.score.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunningArea() {
    final currentParticipation =
        (!_isFinished && _currentRiderIndex < _participations.length)
            ? _participations[_currentRiderIndex]
            : null;

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          // Top bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                  color: Colors.green[700],
                ),
                const SizedBox(width: 8),
                Icon(Icons.sports_gymnastics,
                    size: 24, color: Colors.green[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.event.nom,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700]),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.event.bareme,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: currentParticipation == null
                ? Center(
                    child: Text(
                      'Aucun cavalier en attente',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : Row(
                    children: [
                      // Left: Camera area
                      Expanded(
                        flex: 2,
                        child: _buildCameraArea(),
                      ),
                      // Divider
                      Container(width: 2, color: Colors.grey[300]),
                      // Right: Timer + Score
                      Expanded(
                        flex: 1,
                        child: _buildTimerAndScoreArea(currentParticipation),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraArea() {
    return Container(
      color: Colors.black87,
      child: Column(
        children: [
          // Camera feed - demo image
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/resultat_detection.jpg',
                  fit: BoxFit.contain,
                ),
                // Overlay label
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.videocam, size: 16, color: Colors.red[400]),
                        const SizedBox(width: 4),
                        const Text(
                          'CAMéra LIVE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerAndScoreArea(Participation participation) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current rider info
          Text(
            'Cavalier #${participation.ordrePassage}',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          Text(
            _getRiderName(participation.riderId),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Cheval: ${_getHorseName(participation.horseId)}',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),

          // Timer display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Text(
                  _formatDuration(_elapsed),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isRunning ? null : _startTimer,
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Démarrer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isRunning ? _stopTimer : null,
                      icon: const Icon(Icons.pause, size: 18),
                      label: const Text('Arrêter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    IconButton(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh, size: 20),
                      color: Colors.grey[600],
                      tooltip: 'Réinitialiser',
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // Score section
          const Text(
            'Score',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),

          // AI suggested score
          if (_aiSuggestedScore != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.smart_toy, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 6),
                  Text(
                    'Score IA: ${_aiSuggestedScore!.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
            ),

          // Score input
          TextField(
            controller: _scoreController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Score',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.star, size: 20),
              suffixIcon: _isDisqualified
                  ? Icon(Icons.block, color: Colors.red[700])
                  : null,
              enabled: !_isDisqualified,
              filled: _isDisqualified,
              fillColor: _isDisqualified ? Colors.red[50] : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isDisqualified ? Colors.red : Colors.black,
            ),
          ),
          const SizedBox(height: 8),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: !_isRunning ? _generateAIScore : null,
                  icon: const Icon(Icons.smart_toy, size: 16),
                  label: const Text('Score IA', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isDisqualified ? null : _disqualifyRider,
                  icon: const Icon(Icons.block, size: 16),
                  label: const Text('Disqualifier',
                      style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Save & Next button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _saveScore,
              icon: const Icon(Icons.check_circle, size: 20),
              label: const Text('Enregistrer & Suivant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishedView() {
    // Sort by score (ascending = best for jumping)
    final sorted = List<Participation>.from(_participations)
      ..sort((a, b) {
        if (a.statut == 'disqualifie' && b.statut != 'disqualifie') return 1;
        if (b.statut == 'disqualifie' && a.statut != 'disqualifie') return -1;
        if (a.statut == 'disqualifie' && b.statut == 'disqualifie') return 0;
        return a.score.compareTo(b.score);
      });

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                  color: Colors.green[700],
                ),
                const SizedBox(width: 8),
                Icon(Icons.emoji_events, size: 24, color: Colors.green[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Résultats — ${widget.event.nom}',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700]),
                  ),
                ),
              ],
            ),
          ),

          // Results list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final p = sorted[index];
                final isDisqualified = p.statut == 'disqualifie';
                final rank = isDisqualified ? '-' : '${index + 1}';

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? Colors.amber[100]
                            : index == 1
                                ? Colors.grey[200]
                                : index == 2
                                    ? Colors.brown[100]
                                    : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          rank,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                isDisqualified ? Colors.red : Colors.green[700],
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      _getRiderName(p.riderId),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration:
                            isDisqualified ? TextDecoration.lineThrough : null,
                        color: isDisqualified ? Colors.red : Colors.black,
                      ),
                    ),
                    subtitle: Text(_getHorseName(p.horseId)),
                    trailing: isDisqualified
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('DISQ',
                                style: TextStyle(
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold)),
                          )
                        : Text(
                            '${p.score.toStringAsFixed(1)} pts',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700]),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
