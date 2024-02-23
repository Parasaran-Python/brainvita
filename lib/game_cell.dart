import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GameCell extends StatelessWidget {
  final bool _value;

  GameCell({required value}) : _value = value;

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isFilled = ValueNotifier<bool>(_value);

    return DragTarget<int>(
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
            valueListenable: isFilled,
            builder: (context, value, child) => Draggable<int>(
              data: 10,
              feedback: value ? Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  color: Colors.black
                ),
              ): Container(),
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
      onAcceptWithDetails: (DragTargetDetails<int> details) {
        
      }
    );
  }
}