import 'dart:math';

import 'game_cell.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatelessWidget {

  Map<Point, GameCell>? cellsMap;

  bool _isGameOver() {
    Iterable<MapEntry<Point<num>, GameCell>>? cells = cellsMap?.entries;

    if (cells == null) {
      return false;
    }

    for (int i = 0; i < cells.length; i++) {

      Point currPoint = cells.elementAt(i).key;

      if (
        cellsMap?[currPoint]?.isFilled?.value == true
        && (
          (cellsMap?[
            Point(
              currPoint.x - 1,
              currPoint.y
            )
          ]?.isFilled?.value == true && cellsMap?[
            Point(
              currPoint.x - 2,
              currPoint.y
            )
          ]?.isFilled?.value == false)

          || (cellsMap?[
            Point(
              currPoint.x + 1,
              currPoint.y
            )
          ]?.isFilled?.value == true && cellsMap?[
            Point(
              currPoint.x + 2,
              currPoint.y
            )
          ]?.isFilled?.value == false)

          || (cellsMap?[
            Point(
              currPoint.x,
              currPoint.y - 1
            )
          ]?.isFilled?.value == true && cellsMap?[
            Point(
              currPoint.x,
              currPoint.y - 2
            )
          ]?.isFilled?.value == false)

          || (cellsMap?[
            Point(
              currPoint.x,
              currPoint.y + 1
            )
          ]?.isFilled?.value == true && cellsMap?[
            Point(
              currPoint.x,
              currPoint.y + 2
            )
          ]?.isFilled?.value == false)
        )
      ) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {

    cellsMap = <Point, GameCell>{};

    for (int i = 0; i < 7; i++) {
      for (int j = 0;
        j < ([0, 1, 5, 6].contains(i) ? 3 : 7);
        j++) {
          int y = j;
          if ([0, 1, 5, 6].contains(i)) {
            y += 2;
          }
          cellsMap?[Point(i, y)] = GameCell(
            value: (i == 3 && y == 3) ? false : true,
            coordinates: Point(i, y),
            setValueAt: (Point point, bool value) => cellsMap?[point]?.setValue(value),
            isPointSelected: (Point point) => cellsMap?[point]?.getValue() == true,
            isGameOver: _isGameOver
          );
        }
    }


    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 7; i++) ...{
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int j = 0;
                  j < ([0, 1, 5, 6].contains(i) ? 3 : 7);
                  j++) ...{
                (cellsMap?[Point(i, [0, 1, 5, 6].contains(i) ? j + 2 : j)])!
              }
            ]
          )
        }
      ],
    );
  }

}