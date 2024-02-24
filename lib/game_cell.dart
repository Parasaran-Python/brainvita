import 'dart:math';

import 'package:flutter/material.dart';

class GameCell extends StatelessWidget {
  final bool _value;
  
  final Point _coordinates;

  final void Function(Point, bool) _setValueAt;
  final bool Function(Point) _isPointSelected;

  ValueNotifier<bool>? isFilled;

  GameCell(
    {
      required bool value,
      required Point coordinates,
      required void Function(Point, bool) setValueAt,
      required bool Function(Point) isPointSelected
    })
        : _value = value,
        _coordinates = coordinates,
        _setValueAt = setValueAt,
        _isPointSelected = isPointSelected;
  
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
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.grey
            ),
          ),
          ValueListenableBuilder(
            valueListenable: isFilled!,
            builder: (context, value, child) => Draggable<Point>(
              data: _coordinates,
              feedback: value ? Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  color: Colors.black
                ),
              ) : Container(),
              childWhenDragging: Container(),
              child: value ? Container(
                height: 70,
                width: 70,
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
                ((details.data.y + _coordinates.y) / 2) as int
              )
            ) == true
            && !_isPointSelected(_coordinates)
          )
        ) {
          setValue(true);
          _setValueAt(
            Point(
              _coordinates.x,
              ((details.data.y + _coordinates.y) / 2) as int
            ),
            false
          );
          _setValueAt(
            details.data,
            false
          );
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
                ((details.data.x + _coordinates.x) / 2) as int,
                _coordinates.y
              )
            ) == true
            && !_isPointSelected(_coordinates)
          )
        ) {
          setValue(true);
          _setValueAt(
            Point(
              ((details.data.x + _coordinates.x) / 2) as int,
              _coordinates.y
            ),
            false
          );
          _setValueAt(
            details.data,
            false
          );
        }
      },
    );
  }
}