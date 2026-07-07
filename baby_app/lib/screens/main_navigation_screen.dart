import 'package:flutter/material.dart';
import 'stage_detail_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'extra_info_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int stageId;
  final int selectedWeek;
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    required this.stageId,
    required this.selectedWeek,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int currentIndex;

  @override
  Widget build(BuildContext context) {
    final screens = [
      StageDetailScreen(
        stageId: widget.stageId,
        selectedWeek: widget.selectedWeek,
      ),
      ExtraInfoScreen(stageId: widget.stageId, selectedWeek: widget.selectedWeek),
      ChatScreen(selectedWeek: widget.selectedWeek,),
      ProfileScreen(selectedWeek: widget.selectedWeek),
    ];

    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,

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
            icon: Icon(Icons.info_outline),
            label: 'Más',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Guía',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }
}