import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/main_navigation_screen.dart';

class AppBottomMenuBar extends StatelessWidget {
  final int? currentIndex;

  const AppBottomMenuBar({
    super.key,
    this.currentIndex,
  });

  int getStageIdFromWeek(int week) {
    if (week >= 1 && week <= 12) return 1;
    if (week >= 13 && week <= 28) return 2;
    return 3;
  }

  Future<void> openMainTab(BuildContext context, int index) async {
    final prefs = await SharedPreferences.getInstance();

    final selectedWeek = prefs.getInt('selectedWeek') ?? 12;
    final stageId = getStageIdFromWeek(selectedWeek);

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigationScreen(
          stageId: stageId,
          selectedWeek: selectedWeek,
          initialIndex: index,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelectedTab = currentIndex != null;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: hasSelectedTab ? Colors.purple : Colors.grey,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      currentIndex: currentIndex ?? 0,
      onTap: (index) {
        openMainTab(context, index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
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
    );
  }

  Widget _bottomItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? Colors.purple : Colors.grey;

    return Expanded(
      child: InkWell(
        onTap: () {
          openMainTab(context, index);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}