import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsScreen extends StatefulWidget {
  final int selectedWeek;

  const StatsScreen({
    super.key,
    required this.selectedWeek,
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int diaryEntries = 0;
  int hospitalBagChecked = 0;
  int hospitalBagTotal = 0;
  int diaryStreak = 0;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();

    final diaryCount = prefs
        .getKeys()
        .where((key) => key.startsWith('diary_'))
        .length;
    


    final diaryDates = prefs
      .getKeys()
      .where((key) => key.startsWith('diary_'))
      .map((key) => key.replaceFirst('diary_', ''))
      .toList();

    diaryDates.sort();

    int streak = 0;

    DateTime current =
        DateTime.now();

    while (true) {
      final dateString =
          current.toIso8601String().substring(0, 10);

      if (diaryDates.contains(dateString)) {
        streak++;
        current =
            current.subtract(
              const Duration(days: 1),
            );
      } else {
        break;
      }
    }

    final hospitalKeys = prefs
        .getKeys()
        .where((key) => key.startsWith('hospital_bag_') && prefs.getBool(key) == true)
        .toList();

    setState(() {
      diaryEntries = diaryCount;
      hospitalBagChecked = hospitalKeys.length;
      hospitalBagTotal = 15;
      diaryStreak = streak;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pregnancyProgress = widget.selectedWeek / 40;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7FD),
      appBar: AppBar(
        title: const Text('Estadísticas'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFCF7FD),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            statCard(
              icon: Icons.calendar_today,
              title: 'Semana actual',
              value: 'Semana ${widget.selectedWeek}',
              color: const Color(0xFFF1E7F8),
            ),
            statCard(
              icon: Icons.auto_graph,
              title: 'Progreso del embarazo',
              value: '${(pregnancyProgress * 100).round()}%',
              color: const Color(0xFFFFE8F2),
            ),
            statCard(
              icon: Icons.book,
              title: 'Entradas del diario',
              value: '$diaryEntries',
              color: const Color(0xFFE8F3FF),
            ),
            statCard(
              icon: Icons.local_fire_department,
              title: 'Racha del diario',
              value: '$diaryStreak días',
              color: const Color(0xFFFFE6D5),
            ),
            statCard(
              icon: Icons.shopping_bag,
              title: 'Bolsa del hospital',
              value: '$hospitalBagChecked/$hospitalBagTotal',
              color: const Color(0xFFFFFBE6),
            ),
          ],
        ),
      ),
    );
  }

  Widget statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 34),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}