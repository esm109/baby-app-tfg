import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../screens/diary_screen.dart';
import '../screens/stages_screen.dart';
import '../screens/hospital_bag_screen.dart';

class AppMenuButton extends StatelessWidget {
  const AppMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      onSelected: (value) async {
        if (value == 'diary') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DiaryScreen(),
            ),
          );
        }

        if (value == 'stages') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StagesScreen(),
            ),
          );
        }        

        if (value == 'hospital_bag') {
          final prefs = await SharedPreferences.getInstance();
          final selectedWeek = prefs.getInt('selectedWeek') ?? 12;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HospitalBagScreen(
                selectedWeek: selectedWeek,
              ),
            ),
          );
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'diary',
          child: Row(
            children: [
              Icon(Icons.book),
              SizedBox(width: 10),
              Text('Diario'),
            ],
          ),
        ),

        const PopupMenuItem(
          value: 'stages',
          child: Row(
            children: [
              Icon(Icons.calendar_month),
              SizedBox(width: 10),
              Text('Trimestres'),
            ],
          ),
        ),

        const PopupMenuItem(
          value: 'hospital_bag',
          child: Row(
            children: [
              Icon(Icons.shopping_bag),
              SizedBox(width: 10),
              Text('Bolsa del hospital'),
            ],
          ),
        ),
      ],
    );
  }
}