import 'game_cell.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
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
                GameCell(
                  value: (i == 3 && j == 3) ? false : true,
                )
              }
            ]
          )
        }
      ],
    );
  }

}