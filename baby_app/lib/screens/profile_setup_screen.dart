import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_navigation_screen.dart';
import '../utils/pregnancy_calculator.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  DateTime? dueDate;

  int getStageIdFromWeek(int week) {
    if (week >= 1 && week <= 12) return 1;
    if (week >= 13 && week <= 28) return 2;
    return 3;
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> selectDueDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now().add(const Duration(days: 140)),
      firstDate: DateTime.now().subtract(const Duration(days: 280)),
      lastDate: DateTime.now().add(const Duration(days: 280)),
    );

    if (selected == null) return;

    setState(() {
      dueDate = selected;
    });
  }

  Future<void> saveProfile() async {
    if (dueDate == null) return;

    final calculatedWeek =
        PregnancyCalculator.calculateWeekFromDueDate(dueDate!);

    final stageId = getStageIdFromWeek(calculatedWeek);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'due_date',
      dueDate!.toIso8601String(),
    );

    await prefs.setInt(
      'selectedWeek',
      calculatedWeek,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigationScreen(
          stageId: stageId,
          selectedWeek: calculatedWeek,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calculatedWeek = dueDate != null
        ? PregnancyCalculator.calculateWeekFromDueDate(dueDate!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del embarazo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Cuál es tu fecha probable de parto?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Usaremos esta fecha para calcular automáticamente tu semana de embarazo y personalizar toda la información de la app.',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 32),

            Center(
              child: Icon(
                Icons.event_available,
                size: 90,
                color: Colors.purple.shade300,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: selectDueDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  dueDate == null
                      ? 'Seleccionar fecha de parto'
                      : 'Fecha: ${formatDate(dueDate!)}',
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (calculatedWeek != null)
              Center(
                child: Text(
                  'Semana calculada: $calculatedWeek',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: dueDate == null ? null : saveProfile,
                child: const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}