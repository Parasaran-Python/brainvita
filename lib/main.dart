import 'gameBoard.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Brainvita',
      home: Brainvita()
    );
  }
}

class Brainvita extends StatefulWidget {
  const Brainvita({super.key});

  @override
  State<Brainvita> createState() => _BrainvitaState();
}

class _BrainvitaState extends State<Brainvita> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: GameBoard()
      )
    );
  }
}
