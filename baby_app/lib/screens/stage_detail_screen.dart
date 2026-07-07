import 'package:flutter/material.dart';
import '../models/stage_details.dart';
import '../services/api_service.dart';
import 'profile_setup_screen.dart';
import '../models/baby_size_comparison.dart';
import '../models/weekly_tip.dart';
import '../models/checklist_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';
import 'baby_3d_viewer_screen.dart';
import 'hospital_bag_screen.dart';
import '../widgets/app_menu_button.dart';
import 'dart:convert';

class StageDetailScreen extends StatefulWidget {
  final int stageId;
  final int selectedWeek;


  const StageDetailScreen({
    super.key,
    required this.stageId,
    required this.selectedWeek,
  });

  @override
  State<StageDetailScreen> createState() => _StageDetailScreenState();
}


class _StageDetailScreenState extends State<StageDetailScreen> {
  StageDetails? details;
  List<BabySizeComparison> babySizes = [];
  List<ChecklistItem>? checklist;
  Map<int, bool> checkedTasks = {};
  List<Map<String, dynamic>> editableChecklist = [];
  int currentBabySizePage = 0;
  WeeklyTip? weeklyTip;
  List<Appointment> appointments = [];
  bool isLoading = true;
  String errorMessage = '';
  String userName = '';

  String getBabyModelByImage(String? mediaUrl) {
    if (mediaUrl?.contains('trimester_1') == true) {
      return 'assets/models/baby_trimester_1.glb';
    } else if (mediaUrl?.contains('trimester_2') == true) {
      return 'assets/models/baby_trimester_2.glb';
    } else {
      return 'assets/models/baby_trimester_3.glb';
    }
  }

  String getTrimesterTitleByImage(String? mediaUrl) {
    if (mediaUrl?.contains('trimester_1') == true) {
      return 'Primer trimestre';
    } else if (mediaUrl?.contains('trimester_2') == true) {
      return 'Segundo trimestre';
    } else {
      return 'Tercer trimestre';
    }
  }

  int getWeekByImage(String? mediaUrl) {
    if (mediaUrl?.contains('trimester_1') == true) {
      return 8;
    } else if (mediaUrl?.contains('trimester_2') == true) {
      return 20;
    } else {
      return 32;
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserName();
    loadDetails();
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name') ?? '';

    setState(() {
      userName = savedName;
    });
  }

  Future<void> loadDetails() async {
    try {
      final result = await ApiService.fetchStageDetails(widget.stageId);

      final sizeResult = await ApiService.fetchBabySizeComparison(
        widget.selectedWeek,
      );

      final weeklyTipResult = await ApiService.fetchWeeklyTip(
        widget.selectedWeek,
      );

      final checklistResult = await ApiService.fetchChecklist(
        widget.selectedWeek,
      );

      final savedEditableChecklist = await loadSavedEditableChecklist();

      final appointmentsResult = await ApiService.fetchAppointments(
        widget.selectedWeek,
      );

      final savedAppointments = await loadSavedAppointments();

      setState(() {
        details = result;
        babySizes = sizeResult;
        weeklyTip = weeklyTipResult;
        checklist = checklistResult;

        editableChecklist = savedEditableChecklist ?? checklistResult.map((item) {
          return {
            'id': item.id,
            'task': item.task,
            'source': 'app',
          };
        }).toList();

        appointments = savedAppointments ?? appointmentsResult;
        isLoading = false;
      });

      await loadChecklistState();
      
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar la información: $e';
        isLoading = false;
      });
    }
  }

  String get appointmentsStorageKey => 'custom_appointments';

  Future<List<Appointment>?> loadSavedAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(appointmentsStorageKey);

    if (savedData == null) return null;

    final decoded = jsonDecode(savedData) as List<dynamic>;

    return decoded.map<Appointment>((item) {
      final map = item as Map<String, dynamic>;

      return Appointment(
        id: map['id'],
        weekNumber: map['weekNumber'],
        title: map['title'],
        description: map['description'],
        appointmentType: map['appointmentType'] ?? 'personal',
      );
    }).toList();
  }

  Future<void> saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();

    final data = appointments.map((item) {
      return {
        'id': item.id,
        'weekNumber': item.weekNumber,
        'title': item.title,
        'description': item.description,
        'appointmentType': item.appointmentType,
      };
    }).toList();

    await prefs.setString(
      appointmentsStorageKey,
      jsonEncode(data),
    );
  }

  Widget buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 26),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildExpandableItem({
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: const Color(0xFFF8F3FA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              description,
              style: const TextStyle(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader(StageDetails data) {

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EEFC),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          if (data.stage.mediaType == 'image')
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Baby3DViewerScreen(
                      weekNumber: widget.selectedWeek,
                      modelPath: getBabyModelByImage(data.stage.mediaUrl),
                      trimesterTitle:
                          getTrimesterTitleByImage(data.stage.mediaUrl),
                    ),
                  ),
                );
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Image.asset(
                  data.stage.mediaUrl ?? '',
                  key: ValueKey(data.stage.mediaUrl),
                  height: 240,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          const SizedBox(height: 8),

          const Text(
            'Explora el bebé en 3D tocando la imagen',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            getTrimesterTitleByImage(data.stage.mediaUrl),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF363636),
            ),
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: widget.selectedWeek / 40,
              minHeight: 10,
              backgroundColor: const Color(0xFFE6DDF2),
              valueColor: const AlwaysStoppedAnimation(
                Color(0xFF8E6BD6),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            '${((widget.selectedWeek / 40) * 100).round()}% del embarazo completado',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            data.stage.shortDescription ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
              height: 1.5,
            ),
          ),

          if (data.stage.mediaType == 'emoji')
            Text(
              data.stage.mediaUrl ?? '',
              style: const TextStyle(fontSize: 80),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = details;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7FD),
      appBar: AppBar(
        title: Text(
          'Semana ${widget.selectedWeek}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
        backgroundColor: const Color(0xFFFCF7FD),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileSetupScreen(
                      isEditing: true,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Editar semana'),
            ),
          ),
          const AppMenuButton(),
        ],




      ),

      body: isLoading
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 18),
                Text(
                  'Cargando tu embarazo...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : data == null
                  ? const Center(child: Text('No hay información disponible'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildWelcomeMessage(),
                          buildHeader(data),

                          if (babySizes.isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(
                                top: 20,
                                bottom: 20,
                              ),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4E8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tamaño de tu bebé',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                    SizedBox(
                                      height: 320,
                                      child: PageView.builder(
                                        controller: PageController(viewportFraction: 0.88),
                                        onPageChanged: (index) {
                                          setState(() {
                                            currentBabySizePage = index;
                                          });
                                        },
                                        itemCount: babySizes.length,
                                        itemBuilder: (context, index) {
                                          final item = babySizes[index];

                                          return Padding(
                                            padding: const EdgeInsets.only(right: 12),
                                            child: Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(24),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.orange.withOpacity(0.12),
                                                    blurRadius: 18,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    item.emoji,
                                                    style: const TextStyle(fontSize: 58),
                                                  ),

                                                  const SizedBox(height: 12),

                                                  Text(
                                                    item.title,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 6),

                                                  Text(
                                                    getCategoryName(item.comparisonType),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      letterSpacing: 1.5,
                                                      color: Colors.grey,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 12),

                                                  Text(
                                                    item.description,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      height: 1.35,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,

                                      children: List.generate(
                                        babySizes.length,
                                        (index) {
                                          final isActive =
                                              currentBabySizePage == index;

                                          return AnimatedContainer(
                                            duration: const Duration(milliseconds: 250),

                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),

                                            width: isActive ? 22 : 8,
                                            height: 8,

                                            decoration: BoxDecoration(
                                              color: isActive
                                                  ? Colors.orange
                                                  : Colors.grey.shade300,

                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),

                          if (weeklyTip != null)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F6FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.lightbulb_outline),
                                      SizedBox(width: 8),
                                      Text(
                                        'Consejo de esta semana',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 14),

                                  Text(
                                    weeklyTip!.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    weeklyTip!.description,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  if (shouldShowHospitalBagLink()) ...[
                                    const SizedBox(height: 18),

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => HospitalBagScreen(
                                                selectedWeek: widget.selectedWeek,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 20,
                                        ),
                                        label: const Text(
                                          'Preparar bolsa',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],














                                ],
                              ),
                            ),

                          if ((checklist ?? []).isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBE6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          'Checklist semanal',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          await showChecklistForm();
                                        },
                                        icon: const Icon(Icons.add_circle_outline),
                                        tooltip: 'Añadir tarea',
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  Builder(
                                    builder: (context) {
                                      final total = editableChecklist.length;
                                      final completed = checkedTasks.values.where((value) => value).length;
                                      final progress = total > 0 ? completed / total : 0.0;

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$completed de $total tareas completadas',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),

                                          const SizedBox(height: 8),

                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child: LinearProgressIndicator(
                                              value: progress,
                                              minHeight: 8,
                                            ),
                                          ),

                                          const SizedBox(height: 16),
                                        ],
                                      );
                                    },
                                  ),

                                  if (editableChecklist.isEmpty)
                                    const Text(
                                      'Todavía no hay tareas añadidas.',
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),

                                  ...editableChecklist.asMap().entries.map(
                                    (entry) {
                                      final index = entry.key;
                                      final item = entry.value;

                                      final id = item['id'] as int;
                                      final task = item['task'] as String;

                                      return Card(
                                        elevation: 0,
                                        color: Colors.white,
                                        margin: const EdgeInsets.only(bottom: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 4,
                                          ),
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                value: checkedTasks[id] ?? false,
                                                onChanged: (value) async {
                                                  final newValue = value ?? false;

                                                  setState(() {
                                                    checkedTasks[id] = newValue;
                                                  });

                                                  await saveChecklistItem(id, newValue);
                                                },
                                              ),

                                              Expanded(
                                                child: Text(
                                                  task,
                                                  style: TextStyle(
                                                    decoration: checkedTasks[id] == true
                                                        ? TextDecoration.lineThrough
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.edit_outlined),
                                                onPressed: () async {
                                                  await showChecklistForm(
                                                    item: item,
                                                    index: index,
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline),
                                                onPressed: () {
                                                  deleteChecklistTask(index);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }

  Future<void> loadChecklistState() async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final todayReset = DateTime(now.year, now.month, now.day, 7);

    final lastResetString = prefs.getString('lastChecklistReset');
    final lastReset = lastResetString != null
        ? DateTime.tryParse(lastResetString)
        : null;

    if (lastReset == null || now.isAfter(todayReset) && lastReset.isBefore(todayReset)) {
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith('checklist_')) {
          await prefs.remove(key);
        }
      }
      await prefs.setString('lastChecklistReset', now.toIso8601String());
    }

    final savedChecks = <int, bool>{};

    for (final item in editableChecklist) {
      final id = item['id'] as int;
      savedChecks[id] = prefs.getBool(checklistCheckKey(id)) ?? false;
    }

    setState(() {
      checkedTasks = savedChecks;
    });
  }

  Future<void> saveChecklistItem(int id, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(checklistCheckKey(id), value);
  }

  String getCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'fruit':
        return 'Fruta';
      case 'animal':
        return 'Animal';
      case 'object':
        return 'Objeto';
      default:
        return category;
    }
  }

  String normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  bool shouldShowHospitalBagLink() {
    if (weeklyTip == null) return false;

    final text = normalizeText(
      '${weeklyTip!.title} ${weeklyTip!.description}',
    );

    return text.contains('bolsa') &&
        (text.contains('prepar') ||
            text.contains('hospital') ||
            text.contains('parto'));
  }

  Widget buildWelcomeMessage() {
    final displayName = userName.trim().isEmpty ? 'mamá' : userName.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E7F8),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, $displayName! 👋',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Estás en la semana ${widget.selectedWeek}. Tu bebé sigue creciendo cada día.',
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showAppointmentForm({
    Appointment? appointment,
    int? index,
  }) async {
    final weekController = TextEditingController(
      text: appointment?.weekNumber.toString() ?? widget.selectedWeek.toString(),
    );

    final titleController = TextEditingController(
      text: appointment?.title ?? '',
    );

    final descriptionController = TextEditingController(
      text: appointment?.description ?? '',
    );

    final result = await showDialog<Appointment>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            appointment == null ? 'Añadir cita' : 'Editar cita',
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: weekController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Semana',
                    hintText: 'Ej. 20',
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Ej. Ecografía morfológica',
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Añade información sobre la cita',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final week = int.tryParse(weekController.text.trim());

                if (week == null ||
                    titleController.text.trim().isEmpty ||
                    descriptionController.text.trim().isEmpty) {
                  return;
                }

                Navigator.pop(
                  context,
                  Appointment(
                    id: appointment?.id ?? DateTime.now().millisecondsSinceEpoch,
                    weekNumber: week,
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    appointmentType: appointment?.appointmentType ?? 'personal',
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    setState(() {
      if (index == null) {
        appointments.add(result);
      } else {
        appointments[index] = result;
      }

      appointments.sort(
        (a, b) => a.weekNumber.compareTo(b.weekNumber),
      );
    });

    await saveAppointments();
  }

  Future<void> deleteAppointment(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar cita'),
          content: const Text(
            '¿Seguro que quieres eliminar esta cita?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      appointments.removeAt(index);
    });

    await saveAppointments();
  }

  bool isUserAppointment(Appointment appointment) {
    return appointment.appointmentType == 'personal';
  }

  String getAppointmentLabel(Appointment appointment) {
    return isUserAppointment(appointment)
        ? 'Añadida por ti'
        : 'Sugerida por la app';
  }

  Color getAppointmentLabelColor(Appointment appointment) {
    return isUserAppointment(appointment)
        ? const Color(0xFFE8F3FF)
        : const Color(0xFFFFF4E8);
  }

  Color getAppointmentLabelTextColor(Appointment appointment) {
    return isUserAppointment(appointment)
        ? const Color(0xFF3F6FA3)
        : const Color(0xFFB36B2C);
  }

  String get editableChecklistStorageKey => 'editable_checklist_week_${widget.selectedWeek}';

  String checklistCheckKey(int id) {
    return 'checklist_${widget.selectedWeek}_$id';
  }

  Future<List<Map<String, dynamic>>?> loadSavedEditableChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(editableChecklistStorageKey);

    if (savedData == null) return null;

    final decoded = jsonDecode(savedData) as List<dynamic>;

    return decoded.map<Map<String, dynamic>>((item) {
      final map = item as Map<String, dynamic>;
      return {
        'id': map['id'] is int
            ? map['id']
            : int.tryParse(map['id'].toString()) ?? DateTime.now().millisecondsSinceEpoch,
        'task': map['task']?.toString() ?? '',
        'source': map['source']?.toString() ?? 'app',
      };
    }).toList();
  }

  Future<void> saveEditableChecklist() async {
    final prefs = await SharedPreferences.getInstance();

    final data = editableChecklist.map((item) {
      return {
        'id': item['id'],
        'task': item['task'],
        'source': item['source'] ?? 'app',
      };
    }).toList();

    await prefs.setString(
      editableChecklistStorageKey,
      jsonEncode(data),
    );
  }

 





  Future<void> showChecklistForm({
    Map<String, dynamic>? item,
    int? index,
  }) async {
    String taskText = item?['task']?.toString() ?? '';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            item == null ? 'Añadir tarea' : 'Editar tarea',
          ),
          content: TextFormField(
            initialValue: taskText,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Tarea',
              hintText: 'Ej. Preparar documentación médica',
            ),
            onChanged: (value) {
              taskText = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final task = taskText.trim();

                if (task.isEmpty) return;

                Navigator.of(dialogContext).pop(task);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (result == null || result.trim().isEmpty) return;

    final newChecklist = List<Map<String, dynamic>>.from(editableChecklist);

    if (index == null) {
      newChecklist.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'task': result.trim(),
        'source': 'personal',
      });
    } else {
      newChecklist[index] = {
        'id': newChecklist[index]['id'],
        'task': result.trim(),
        'source': newChecklist[index]['source'] ?? 'app',
      };
    }

    setState(() {
      editableChecklist = newChecklist;
    });

    await saveEditableChecklist();
  }















  Future<void> deleteChecklistTask(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar tarea'),
          content: const Text(
            '¿Seguro que quieres eliminar esta tarea del checklist?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final id = editableChecklist[index]['id'] as int;

    setState(() {
      editableChecklist.removeAt(index);
      checkedTasks.remove(id);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(checklistCheckKey(id));

    await saveEditableChecklist();
  }
}