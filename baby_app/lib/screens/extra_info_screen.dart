import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/appointment.dart';
import '../models/stage_details.dart';
import '../services/api_service.dart';
import '../widgets/app_menu_button.dart';
import 'stages_screen.dart';

class ExtraInfoScreen extends StatefulWidget {
  final int stageId;
  final int selectedWeek;

  const ExtraInfoScreen({
    super.key,
    required this.stageId,
    required this.selectedWeek,
  });

  @override
  State<ExtraInfoScreen> createState() => _ExtraInfoScreenState();
}

class _ExtraInfoScreenState extends State<ExtraInfoScreen> {
  StageDetails? details;
  List<Appointment> appointments = [];
  bool isLoading = true;
  String errorMessage = '';

  String get appointmentsStorageKey => 'custom_appointments';

  @override
  void initState() {
    super.initState();
    loadExtraInfo();
  }

  Future<void> loadExtraInfo() async {
    try {
      final result = await ApiService.fetchStageDetails(widget.stageId);

      final appointmentsResult = await ApiService.fetchAppointments(
        widget.selectedWeek,
      );

      final savedAppointments = await loadSavedAppointments();

      setState(() {
        details = result;
        appointments = savedAppointments ?? appointmentsResult;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar la información: $e';
        isLoading = false;
      });
    }
  }

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

  Widget buildExtraInfoHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E7F8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.info_outline),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Más información de esta semana',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Aquí encontrarás información detallada sobre el desarrollo del bebé, los cambios en tu cuerpo y las recomendaciones para esta etapa.',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
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

  Widget buildAppointmentsSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E8FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                color: Color(0xFF8B6CCF),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Próximas citas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  showAppointmentForm();
                },
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Añadir cita',
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (appointments.isEmpty)
            const Text(
              'Todavía no hay citas añadidas.',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

          ...appointments.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final item = entry.value;

              return Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFDCCEFF),
                    child: Text(
                      '${item.weekNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A3FA3),
                      ),
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: getAppointmentLabelColor(item),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getAppointmentLabel(item),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: getAppointmentLabelTextColor(item),
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          showAppointmentForm(
                            appointment: item,
                            index: index,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          deleteAppointment(index);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(item.title),
                        content: Text(item.description),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
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

  @override
  Widget build(BuildContext context) {
    final data = details;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7FD),
      appBar: AppBar(
        title: const Text(
          'Más información',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFCF7FD),
        elevation: 0,
        actions: const [
          AppMenuButton(),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                  ? const Center(
                      child: Text('No hay información disponible'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildExtraInfoHeader(),

                          buildAppointmentsSection(),

                          const SizedBox(height: 10),

                          buildSection(
                            title: 'Desarrollo del bebé',
                            icon: Icons.child_care,
                            children: data.babyDevelopment
                                .map(
                                  (item) => Card(
                                    elevation: 0,
                                    color: const Color(0xFFFFE8F2),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      leading: const CircleAvatar(
                                        backgroundColor: Color(0xFFFFB6D5),
                                        child: Icon(Icons.child_care),
                                      ),
                                      title: Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: const Icon(Icons.info_outline),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(item.title),
                                            content: Text(item.description),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cerrar'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                          const SizedBox(height: 10),

                          buildSection(
                            title: 'Cambios en la madre',
                            icon: Icons.favorite_outline,
                            children: data.motherChanges
                                .map(
                                  (item) => Card(
                                    elevation: 0,
                                    color: const Color(0xFFFFF0E6),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      leading: const CircleAvatar(
                                        backgroundColor: Color(0xFFFFC89A),
                                        child: Icon(Icons.favorite),
                                      ),
                                      title: Text(
                                        item.symptom,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: const Icon(Icons.info_outline),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(item.symptom),
                                            content: Text(item.description),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cerrar'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                          const SizedBox(height: 10),

                          buildSection(
                            title: 'Recomendaciones',
                            icon: Icons.lightbulb_outline,
                            children: data.recommendations
                                .map(
                                  (item) => Card(
                                    elevation: 0,
                                    color: const Color(0xFFE8F8EE),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      leading: const CircleAvatar(
                                        backgroundColor: Color(0xFF9FE3B0),
                                        child: Icon(Icons.lightbulb),
                                      ),
                                      title: Text(
                                        item.category.isNotEmpty
                                            ? item.category[0].toUpperCase() +
                                                item.category.substring(1)
                                            : '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: const Icon(Icons.info_outline),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(item.category),
                                            content: Text(item.recommendation),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cerrar'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
    );
  }
} 