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
              if ([0, 1, 5, 6].contains(i)) ...{
                for (int j = 0; j < 3; j++) ...{
                  GameCell()
                }
              }
              else ...{
                for (int j = 0; j < 7; j++) ...{
                  GameCell()
                }
              }
            ]
          )
        }
      ],
    );
  }

}