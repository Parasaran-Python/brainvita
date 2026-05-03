import 'package:flutter/material.dart';

import 'game_board.dart';

void main() {
  runApp(const BrainvitaApp());
}

class BrainvitaApp extends StatelessWidget {
  const BrainvitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brainvita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB8651A),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F2E7),
      ),
      home: const BrainvitaHome(),
    );
  }
}

class BrainvitaHome extends StatelessWidget {
  const BrainvitaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF1A202C),
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Brainvita',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFAF5EA), Color(0xFFE8DCC0)],
          ),
        ),
        child: const SafeArea(child: GameBoard()),
      ),
    );
  }
}
