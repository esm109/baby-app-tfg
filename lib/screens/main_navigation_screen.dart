import 'package:flutter/material.dart';
import 'profile_setup_screen.dart';
import 'stage_detail_screen.dart';
import 'stages_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int stageId;
  final int selectedWeek;

  const MainNavigationScreen({
    super.key,
    required this.stageId,
    required this.selectedWeek,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      StageDetailScreen(
        stageId: widget.stageId,
        selectedWeek: widget.selectedWeek,
      ),

      const StagesScreen(),

      ProfileScreen(selectedWeek: widget.selectedWeek),
    ];

    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Trimestres',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}