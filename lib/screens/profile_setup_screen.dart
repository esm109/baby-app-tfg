import 'package:flutter/material.dart';
import 'stage_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation_screen.dart';
import 'package:flutter/cupertino.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int selectedWeek = 12;

  int getStageIdFromWeek(int week) {
    if (week >= 1 && week <= 12) return 1;
    if (week >= 13 && week <= 28) return 2;
    return 3;
  }

  String getStageNameFromWeek(int week) {
    if (week >= 1 && week <= 12) return 'Primer trimestre';
    if (week >= 13 && week <= 28) return 'Segundo trimestre';
    return 'Tercer trimestre';
  }

  @override
  Widget build(BuildContext context) {
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
              '¿En qué semana de embarazo estás?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Selecciona la semana para mostrarte información adaptada a tu etapa.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),

            Center(
              child: Text(
                'Semana $selectedWeek',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFF1E7F8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: selectedWeek - 1,
                ),
                itemExtent: 50,
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedWeek = index + 1;
                  });
                },
                children: List.generate(
                  40,
                  (index) => Center(
                    child: Text(
                      'Semana ${index + 1}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
              
            const SizedBox(height: 16),

            Center(
              child: Text(
                getStageNameFromWeek(selectedWeek),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final stageId = getStageIdFromWeek(selectedWeek);

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('selectedWeek', selectedWeek);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainNavigationScreen(
                        stageId: stageId,
                        selectedWeek: selectedWeek,
                      ),
                    ),
                  );
                },
                child: const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}