import 'dart:math';

import 'package:flutter/material.dart';

class GameCell extends StatelessWidget {
  final bool _value;
  
  final Point _coordinates;

  final void Function(Point, bool) _setValueAt;
  final bool Function(Point) _isPointSelected;
  final bool Function() _isGameOver;

  ValueNotifier<bool>? isFilled;

  GameCell(
    {
      required bool value,
      required Point coordinates,
      required void Function(Point, bool) setValueAt,
      required bool Function(Point) isPointSelected,
      required bool Function() isGameOver
    })
        : _value = value,
        _coordinates = coordinates,
        _setValueAt = setValueAt,
        _isPointSelected = isPointSelected,
        _isGameOver = isGameOver;
  
  void setValue(bool value) {
    isFilled?.value = value;
  }

  bool? getValue() {
    return isFilled?.value;
  }

  @override
  Widget build(BuildContext context) {
    isFilled = ValueNotifier<bool>(_value);

    return DragTarget<Point>(
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.grey
            ),
          ),
          ValueListenableBuilder(
            valueListenable: isFilled!,
            builder: (context, value, child) => Draggable<Point>(
              data: _coordinates,
              feedback: value ? Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  color: Colors.black
                ),
              ) : Container(),
              childWhenDragging: Container(),
              child: value ? Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  color: Colors.black
                ),
              ): Container(),
            )
          )
        ]
      ),
      onAcceptWithDetails: (DragTargetDetails<Point> details) {
        if (
          details.data.x == _coordinates.x
          && (
            details.data.y == _coordinates.y - 2
            || details.data.y == _coordinates.y + 2
          )
          && (
            getValue() == false
            && _isPointSelected(
              Point(
                _coordinates.x,
                (details.data.y + _coordinates.y) ~/ 2
              )
            ) == true
            && !_isPointSelected(_coordinates)
          )
        ) {
          setValue(true);
          _setValueAt(
            Point(
              _coordinates.x,
              (details.data.y + _coordinates.y) ~/ 2
            ),
            false
          );
          _setValueAt(
            details.data,
            false
          );

          if (_isGameOver()) {
            showDialog(
              context: context,
              builder: (context) => const Text('Game Over'),
            );
          }
        }
        else if (
          details.data.y == _coordinates.y
          && (
            details.data.x == _coordinates.x - 2
            || details.data.x == _coordinates.x + 2
          )
          && (
            getValue() == false
            && _isPointSelected(
              Point(
                (details.data.x + _coordinates.x) ~/ 2,
                _coordinates.y
              )
            ) == true
            && !_isPointSelected(_coordinates)
          )
        ) {
          setValue(true);
          _setValueAt(
            Point(
              (details.data.x + _coordinates.x) ~/ 2,
              _coordinates.y
            ),
            false
          );
          _setValueAt(
            details.data,
            false
          );

          if (_isGameOver()) {
            showDialog(
              context: context,
              builder: (context) => const Text('Game Over'),
            );
          }
        }
      },
    );
  }
}