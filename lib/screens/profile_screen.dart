import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_setup_screen.dart';
import '../utils/pregnancy_calculator.dart';

class ProfileScreen extends StatefulWidget {
  final int selectedWeek;

  const ProfileScreen({
    super.key,
    required this.selectedWeek,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DateTime? dueDate;

  @override
  void initState() {
    super.initState();
    loadDueDate();
  }

  Future<void> loadDueDate() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('due_date');

    if (savedDate != null) {
      setState(() {
        dueDate = DateTime.parse(savedDate);
      });
    }
  }

  Future<void> selectDueDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now().add(const Duration(days: 140)),
      firstDate: DateTime.now().subtract(const Duration(days: 280)),
      lastDate: DateTime.now().add(const Duration(days: 280)),
    );

    if (selected == null) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'due_date',
      selected.toIso8601String(),
    );

    final calculatedWeek =
    PregnancyCalculator.calculateWeekFromDueDate(
      selected,
    );

    await prefs.setInt(
      'selectedWeek',
      calculatedWeek,
    );

    setState(() {
      dueDate = selected;
    });
  }

  String getStageNameFromWeek(int week) {
    if (week >= 1 && week <= 12) return 'Primer trimestre';
    if (week >= 13 && week <= 28) return 'Segundo trimestre';
    return 'Tercer trimestre';
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final calculatedWeek = dueDate != null
        ? PregnancyCalculator.calculateWeekFromDueDate(dueDate!)
        : widget.selectedWeek;

    final daysRemaining = dueDate != null
        ? PregnancyCalculator.calculateDaysRemaining(dueDate!)
        : null;

    final stageName = getStageNameFromWeek(calculatedWeek);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.pregnant_woman,
              size: 80,
              color: Colors.purple,
            ),

            const SizedBox(height: 20),

            Text(
              'Semana $calculatedWeek',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              stageName,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            if (dueDate != null)
              Column(
                children: [
                  Text(
                    'Fecha probable de parto: ${formatDate(dueDate!)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Faltan $daysRemaining días aproximadamente',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: selectDueDate,
                icon: const Icon(Icons.event),
                label: const Text('Editar fecha de parto'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileSetupScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Cambiar semana manualmente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}