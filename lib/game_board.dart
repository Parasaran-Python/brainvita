import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _resetState();
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
      if (_isGameOver()) {
        _finished = true;
        _timer?.cancel();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showEndDialog();
        });
      }
    });
    return true;
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
            _statRow('Moves', '$_moves'),
            _statRow('Time', _formatDuration(_elapsed)),
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

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF4A5568))),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 20),
                  _board(),
                  const SizedBox(height: 24),
                  _restartButton(),
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

  Widget _restartButton() {
    return ElevatedButton.icon(
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
    );
  }
}
