import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_cell.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  static const Point<int> _center = Point<int>(3, 3);

  late Map<Point<int>, bool> _cells;
  int _moves = 0;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  bool _started = false;
  bool _finished = false;
  final List<_Move> _history = [];

  static const String _kBestMoves = 'brainvita_best_moves';
  static const String _kBestTimeSec = 'brainvita_best_time_sec';
  int? _bestMoves;
  int? _bestTimeSec;
  bool _newRecordMoves = false;
  bool _newRecordTime = false;

  @override
  void initState() {
    super.initState();
    _resetState();
    _loadBestStats();
  }

  Future<void> _loadBestStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _bestMoves = prefs.getInt(_kBestMoves);
        _bestTimeSec = prefs.getInt(_kBestTimeSec);
      });
    } catch (_) {
      // shared_preferences unavailable (e.g. some test envs); ignore.
    }
  }

  Future<void> _maybeUpdateBestStats() async {
    if (!_isPerfectWin()) return;
    final int moves = _moves;
    final int seconds = _elapsed.inSeconds;
    bool newMoves = false;
    bool newTime = false;
    if (_bestMoves == null || moves < _bestMoves!) {
      _bestMoves = moves;
      newMoves = true;
    }
    if (_bestTimeSec == null || seconds < _bestTimeSec!) {
      _bestTimeSec = seconds;
      newTime = true;
    }
    _newRecordMoves = newMoves;
    _newRecordTime = newTime;
    if (!newMoves && !newTime) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (newMoves) await prefs.setInt(_kBestMoves, moves);
      if (newTime) await prefs.setInt(_kBestTimeSec, seconds);
    } catch (_) {
      // ignore persistence failures
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetState() {
    _cells = _buildInitialCells();
    _moves = 0;
    _elapsed = Duration.zero;
    _started = false;
    _finished = false;
    _newRecordMoves = false;
    _newRecordTime = false;
    _history.clear();
    _timer?.cancel();
    _timer = null;
  }

  Map<Point<int>, bool> _buildInitialCells() {
    final Map<Point<int>, bool> cells = {};
    for (int i = 0; i < 7; i++) {
      final bool narrow = i < 2 || i > 4;
      final int colStart = narrow ? 2 : 0;
      final int colEnd = narrow ? 5 : 7;
      for (int j = colStart; j < colEnd; j++) {
        cells[Point<int>(i, j)] = !(i == _center.x && j == _center.y);
      }
    }
    return cells;
  }

  void _restart() {
    setState(_resetState);
  }

  void _ensureTimerStarted() {
    if (_started) return;
    _started = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  bool _attemptMove(Point<int> from, Point<int> to) {
    if (_finished) return false;
    if (!_cells.containsKey(from) || !_cells.containsKey(to)) return false;
    if (_cells[from] != true || _cells[to] != false) return false;

    final int dx = to.x - from.x;
    final int dy = to.y - from.y;
    final bool straight =
        (dx == 0 && dy.abs() == 2) || (dy == 0 && dx.abs() == 2);
    if (!straight) return false;

    final Point<int> middle = Point<int>(from.x + dx ~/ 2, from.y + dy ~/ 2);
    if (_cells[middle] != true) return false;

    setState(() {
      _ensureTimerStarted();
      _cells[from] = false;
      _cells[middle] = false;
      _cells[to] = true;
      _moves++;
      _history.add(_Move(from: from, middle: middle, to: to));
      if (_isGameOver()) {
        _finished = true;
        _timer?.cancel();
        _maybeUpdateBestStats();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showEndDialog();
        });
      }
    });
    return true;
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      final move = _history.removeLast();
      _cells[move.from] = true;
      _cells[move.middle] = true;
      _cells[move.to] = false;
      if (_moves > 0) _moves--;
      if (_finished) {
        _finished = false;
        if (_started && _timer == null) {
          _timer = Timer.periodic(const Duration(seconds: 1), (_) {
            if (!mounted) return;
            setState(() => _elapsed += const Duration(seconds: 1));
          });
        }
      }
    });
  }

  int get _remaining =>
      _cells.values.where((filled) => filled).length;

  bool _hasAnyMove() {
    for (final entry in _cells.entries) {
      if (entry.value != true) continue;
      final Point<int> p = entry.key;
      const directions = [
        Point<int>(2, 0),
        Point<int>(-2, 0),
        Point<int>(0, 2),
        Point<int>(0, -2),
      ];
      for (final d in directions) {
        final Point<int> to = Point<int>(p.x + d.x, p.y + d.y);
        final Point<int> mid = Point<int>(p.x + d.x ~/ 2, p.y + d.y ~/ 2);
        if (_cells[to] == false && _cells[mid] == true) return true;
      }
    }
    return false;
  }

  bool _isGameOver() => !_hasAnyMove();

  bool _isPerfectWin() => _remaining == 1 && _cells[_center] == true;

  void _showEndDialog() {
    final bool perfect = _isPerfectWin();
    final int remaining = _remaining;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              perfect ? Icons.emoji_events : Icons.flag,
              color: perfect
                  ? const Color(0xFFFFD166)
                  : const Color(0xFF718096),
            ),
            const SizedBox(width: 8),
            Text(perfect ? 'Perfect Win!' : 'Game Over'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              perfect
                  ? 'You finished with the last peg in the center.'
                  : remaining == 1
                      ? 'One peg left, but not in the center.'
                      : 'No more moves available.',
            ),
            const SizedBox(height: 12),
            _statRow('Pegs left', '$remaining'),
            _statRow(
              'Moves',
              '$_moves',
              highlight: perfect && _newRecordMoves,
            ),
            _statRow(
              'Time',
              _formatDuration(_elapsed),
              highlight: perfect && _newRecordTime,
            ),
            if (perfect && (_newRecordMoves || _newRecordTime)) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.star, size: 16, color: Color(0xFFB8651A)),
                  SizedBox(width: 6),
                  Text(
                    'New personal best!',
                    style: TextStyle(
                      color: Color(0xFFB8651A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _restart();
            },
            child: const Text('Play again'),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF4A5568))),
          Row(
            children: [
              if (highlight) ...[
                const Icon(
                  Icons.arrow_upward,
                  size: 14,
                  color: Color(0xFFB8651A),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: highlight
                      ? const Color(0xFFB8651A)
                      : const Color(0xFF1A202C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _statsBar(),
                  if (_bestMoves != null || _bestTimeSec != null) ...[
                    const SizedBox(height: 8),
                    _bestStatsLine(),
                  ],
                  const SizedBox(height: 20),
                  _board(),
                  const SizedBox(height: 24),
                  _actionButtons(),
                  const SizedBox(height: 8),
                  const Text(
                    'Jump a peg over its neighbour into an empty hole.',
                    style: TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _stat(Icons.circle, 'Pegs', '$_remaining'),
          _stat(Icons.swap_horiz, 'Moves', '$_moves'),
          _stat(Icons.timer, 'Time', _formatDuration(_elapsed)),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFFB8651A)),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.1,
                color: Color(0xFF718096),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A202C),
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _board() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEDE0C9), Color(0xFFD7B98A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < 7; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int j = 0; j < 7; j++)
                  if (_cells.containsKey(Point<int>(i, j)))
                    GameCell(
                      isFilled: _cells[Point<int>(i, j)]!,
                      coordinates: Point<int>(i, j),
                      onMove: _attemptMove,
                    )
                  else
                    const SizedBox(width: 60, height: 60),
              ],
            ),
        ],
      ),
    );
  }

  Widget _bestStatsLine() {
    final parts = <String>[];
    if (_bestMoves != null) parts.add('${_bestMoves!} moves');
    if (_bestTimeSec != null) {
      parts.add(_formatDuration(Duration(seconds: _bestTimeSec!)));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.emoji_events,
          size: 14,
          color: Color(0xFFB8651A),
        ),
        const SizedBox(width: 6),
        Text(
          'Best perfect win: ${parts.join(' / ')}',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _actionButtons() {
    final bool canUndo = _history.isNotEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: canUndo ? _undo : null,
          icon: const Icon(Icons.undo),
          label: const Text('Undo'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1A202C),
            side: BorderSide(
              color: canUndo
                  ? const Color(0xFFB8651A)
                  : const Color(0xFFCBD5E0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _restart,
          icon: const Icon(Icons.refresh),
          label: const Text('Restart'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB8651A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _Move {
  final Point<int> from;
  final Point<int> middle;
  final Point<int> to;
  const _Move({required this.from, required this.middle, required this.to});
}
