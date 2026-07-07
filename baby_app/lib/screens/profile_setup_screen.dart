import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation_screen.dart';
import '../utils/pregnancy_calculator.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isEditing;

  const ProfileSetupScreen({
    super.key,
    this.isEditing = false,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}
class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  DateTime? dueDate;
  String userName = '';

  int getStageIdFromWeek(int week) {
    if (week >= 1 && week <= 12) return 1;
    if (week >= 13 && week <= 28) return 2;
    return 3;
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSavedProfile();
  }

  Future<void> loadSavedProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final savedName = prefs.getString('user_name') ?? '';
    final savedDueDate = prefs.getString('due_date');

    setState(() {
      nameController.text = savedName;

      if (savedDueDate != null) {
        dueDate = DateTime.parse(savedDueDate);
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> selectDueDate() async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final selected = await showDatePicker(
      context: context,
      initialDate: dueDate ?? todayOnly,
      firstDate: todayOnly,
      lastDate: todayOnly.add(const Duration(days: 280)),
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

    final name = nameController.text.trim();

    if (name.isNotEmpty) {
      await prefs.setString('user_name', name);
    } else {
      await prefs.remove('user_name');
    }

    await prefs.setString(
      'due_date',
      dueDate!.toIso8601String(),
    );

    await prefs.setInt(
      'selectedWeek',
      calculatedWeek,
    );

    if (!mounted) return;

    if (widget.isEditing) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainNavigationScreen(
            stageId: stageId,
            selectedWeek: calculatedWeek,
          ),
        ),
        (route) => false,
      );
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    final calculatedWeek = dueDate != null
        ? PregnancyCalculator.calculateWeekFromDueDate(dueDate!)
        : null;

    return Scaffold(
      appBar: widget.isEditing
          ? AppBar(
              title: const Text('Editar datos'),
              backgroundColor: const Color(0xFFFCF7FD),
              foregroundColor: Colors.black87,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              24,
              widget.isEditing ? 24 : 48,
              24,
              24 + MediaQuery.of(context).viewInsets.bottom,
            ),
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

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tu nombre',
                    hintText: 'Ej. Elena',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

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

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: dueDate == null ? null : saveProfile,
                    child: Text(
                      widget.isEditing ? 'Guardar cambios' : 'Continuar',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                if (!widget.isEditing)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showManualWeekSelector();
                      },
                      icon: const Icon(Icons.help_outline),
                      label: const Text(
                        'No sé mi fecha de parto',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

        

  Future<void> saveProfileWithManualWeek(int week) async {
    final prefs = await SharedPreferences.getInstance();

    final name = nameController.text.trim();

    if (name.isNotEmpty) {
      await prefs.setString('user_name', name);
    } else {
      await prefs.remove('user_name');
    }

    await prefs.setInt('selectedWeek', week);

    // Como no sabe la fecha de parto, eliminamos la fecha guardada si existía
    await prefs.remove('due_date');

    final stageId = getStageIdFromWeek(week);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigationScreen(
          stageId: stageId,
          selectedWeek: week,
        ),
      ),
    );
  }

  Future<void> showManualWeekSelector() async {
    int temporaryWeek = 12;

    final selectedWeek = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    '¿En qué semana estás?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Si no sabes tu fecha probable de parto, puedes indicar una semana aproximada.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E7F8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Semana $temporaryWeek',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Slider(
                          value: temporaryWeek.toDouble(),
                          min: 1,
                          max: 40,
                          divisions: 39,
                          label: 'Semana $temporaryWeek',
                          onChanged: (value) {
                            setModalState(() {
                              temporaryWeek = value.round();
                            });
                          },
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              '1',
                              style: TextStyle(color: Colors.black54),
                            ),
                            Text(
                              '40',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, temporaryWeek);
                      },
                      child: const Text('Continuar con esta semana'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, 12);
                    },
                    child: const Text(
                      'Tampoco sé la semana, empezar en la 12',
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selectedWeek == null) return;

    await saveProfileWithManualWeek(selectedWeek);
  }
}