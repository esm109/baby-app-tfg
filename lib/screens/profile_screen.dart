import 'package:flutter/material.dart';
import 'profile_setup_screen.dart';

class ProfileScreen extends StatelessWidget {
  final int selectedWeek;

  const ProfileScreen({
    super.key,
    required this.selectedWeek,
  });

  String getStageNameFromWeek(int week) {
    if (week >= 1 && week <= 12) return 'Primer trimestre';
    if (week >= 13 && week <= 28) return 'Segundo trimestre';
    return 'Tercer trimestre';
  }

  @override
  Widget build(BuildContext context) {
    final stageName = getStageNameFromWeek(selectedWeek);

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
              'Semana $selectedWeek',
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

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileSetupScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Cambiar semana'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}