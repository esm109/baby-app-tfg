import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final TextEditingController controller = TextEditingController();

  List<String> diaryKeys = [];
  String selectedMood = '😊';
  String selectedDiaryDate = DateTime.now().toIso8601String().substring(0, 10);

  String formatDate(String rawDate) {
    final parts = rawDate.split('-');

    if (parts.length != 3) {
      return rawDate;
    }

    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  @override
  void initState() {
    super.initState();
    loadDiary();
  }

  Future<void> loadDiary() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      controller.text = prefs.getString('diary_$selectedDiaryDate') ?? '';
      selectedMood = prefs.getString('mood_$selectedDiaryDate') ?? '😊';

      diaryKeys = prefs
          .getKeys()
          .where((key) => key.startsWith('diary_'))
          .toList()
        ..sort((a, b) => b.compareTo(a));
    });
  }

  Future<void> saveDiary() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('diary_$selectedDiaryDate', controller.text);
    await prefs.setString('mood_$selectedDiaryDate', selectedMood);

    await loadDiary();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diario guardado')),
    );
  }

  Future<void> goToToday() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      selectedDiaryDate = today;
      controller.text = prefs.getString('diary_$today') ?? '';
      selectedMood = prefs.getString('mood_$today') ?? '😊';
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7FD),
      appBar: AppBar(
        title: const Text(
          'Mi Diario',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFCF7FD),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedDiaryDate == today
                  ? '¿Cómo te encuentras hoy?'
                  : 'Entrada del ${formatDate(selectedDiaryDate)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Estado de ánimo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['😊', '😌', '😐', '😢', '🤢'].map((mood) {
                final isSelected = selectedMood == mood;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMood = mood;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF1E7F8)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.purple
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      mood,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: controller,
              maxLines: 8,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Escribe aquí tus pensamientos...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: saveDiary,
                icon: const Icon(Icons.save),
                label: const Text('Guardar entrada'),
              ),
            ),

            const SizedBox(height: 10),

            TextButton.icon(
              onPressed: goToToday,
              icon: const Icon(Icons.today),
              label: const Text('Volver a hoy'),
            ),

            const SizedBox(height: 24),

            const Text(
              'Historial',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: diaryKeys.map((key) {
                  final rawDate = key.replaceFirst('diary_', '');
                  final formattedDate = formatDate(rawDate);
                  final moodKey = key.replaceFirst('diary_', 'mood_');

                  return Card(
                    elevation: 0,
                    color: const Color(0xFFFFF1F7),
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: FutureBuilder<SharedPreferences>(
                        future: SharedPreferences.getInstance(),
                        builder: (context, snapshot) {
                          final prefs = snapshot.data;
                          final moodValue = prefs?.getString(moodKey) ?? '📔';

                          return Text(
                            moodValue,
                            style: const TextStyle(fontSize: 26),
                          );
                        },
                      ),
                      title: Text(formattedDate),
                      trailing: const Icon(Icons.info_outline),
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final text = prefs.getString(key) ?? '';
                        final moodValue = prefs.getString(moodKey) ?? '😊';

                        if (!mounted) return;

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(formattedDate),
                            content: Text(
                              text.isNotEmpty ? text : 'Sin contenido',
                            ),

                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cerrar'),
                              ),

                              TextButton(
                                onPressed: () async {
                                  await prefs.remove(key);
                                  await prefs.remove(moodKey);

                                  if (!mounted) return;

                                  Navigator.pop(context);
                                  await loadDiary();
                                },
                                child: const Text('Eliminar'),
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);

                                  setState(() {
                                    selectedDiaryDate = rawDate;
                                    controller.text = text;
                                    selectedMood = moodValue;
                                  });
                                },
                                child: const Text('Editar'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}