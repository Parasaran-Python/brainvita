import 'dart:math';

import 'package:flutter/material.dart';

class GameCell extends StatelessWidget {
  final bool isFilled;
  final Point<int> coordinates;
  final bool Function(Point<int> from, Point<int> to) onMove;

  const GameCell({
    super.key,
    required this.isFilled,
    required this.coordinates,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Point<int>>(
      onWillAcceptWithDetails: (details) =>
          !isFilled && details.data != coordinates,
      onAcceptWithDetails: (details) => onMove(details.data, coordinates),
      builder: (context, candidate, rejected) {
        final bool hovering = candidate.isNotEmpty;
        return Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _hole(hovering),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: isFilled
                      ? Draggable<Point<int>>(
                          key: const ValueKey('peg'),
                          data: coordinates,
                          feedback: _peg(dragging: true),
                          childWhenDragging: const SizedBox.shrink(),
                          child: _peg(),
                        )
                      : const SizedBox.shrink(key: ValueKey('empty')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _hole(bool hovering) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: hovering
              ? const [Color(0xFF4A5568), Color(0xFF2D3748)]
              : const [Color(0xFF2D3748), Color(0xFF1A202C)],
          radius: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: -1,
          ),
        ],
        border: Border.all(
          color: hovering
              ? const Color(0xFFFFD166)
              : const Color(0x4D000000),
          width: hovering ? 2 : 1,
        ),
      ),
    );
  }

  Widget _peg({bool dragging = false}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.3),
          radius: 0.95,
          colors: [
            Color(0xFFFFE7A0),
            Color(0xFFFFB347),
            Color(0xFFB8651A),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: dragging
                ? const Color(0x88000000)
                : const Color(0x66000000),
            blurRadius: dragging ? 10 : 4,
            offset: Offset(0, dragging ? 4 : 2),
          ),
        ],
      ),
    );
  }
}
