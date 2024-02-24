import 'dart:math';

import 'game_cell.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    Map<Point, GameCell> cellsMap = <Point, GameCell>{};

    for (int i = 0; i < 7; i++) {
      for (int j = 0;
        j < ([0, 1, 5, 6].contains(i) ? 3 : 7);
        j++) {
          int y = j;
          if ([0, 1, 5, 6].contains(i)) {
            y += 2;
          }
          cellsMap[Point(i, y)] = GameCell(
            value: (i == 3 && y == 3) ? false : true,
            coordinates: Point(i, y),
            setValueAt: (Point point, bool value) => cellsMap[point]?.setValue(value),
            isPointSelected: (Point point) => cellsMap[point]?.getValue() == true
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
                cellsMap[Point(i, [0, 1, 5, 6].contains(i) ? j + 2 : j)]!
              }
            ]
          )
        }
      ],
    );
  }

}