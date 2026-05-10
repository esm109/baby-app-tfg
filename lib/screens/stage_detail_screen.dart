import 'package:flutter/material.dart';
import '../models/stage_details.dart';
import '../services/api_service.dart';

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
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadDetails();
  }

  Future<void> loadDetails() async {
    try {
      final result = await ApiService.fetchStageDetails(widget.stageId);
      setState(() {
        details = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar la información: $e';
        isLoading = false;
      });
    }
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

  Widget buildItem({
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader(StageDetails data) {
    final progress = widget.selectedWeek / 40;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E7F8),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.stage.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semana ${widget.selectedWeek} de embarazo',
            style: const TextStyle(fontSize: 17),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 12),
          Text(
            data.stage.shortDescription,
            style: const TextStyle(fontSize: 15, height: 1.4),
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
        title: const Text('Tu etapa'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFCF7FD),
        elevation: 0,
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
                  ? const Center(child: Text('No hay información disponible'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildHeader(data),

                          buildSection(
                            title: 'Desarrollo del bebé',
                            icon: Icons.child_care,
                            children: data.babyDevelopment
                                .map(
                                  (item) => buildItem(
                                    title: item.title,
                                    description: item.description,
                                  ),
                                )
                                .toList(),
                          ),

                          buildSection(
                            title: 'Cambios en la madre',
                            icon: Icons.favorite_outline,
                            children: data.motherChanges
                                .map(
                                  (item) => buildItem(
                                    title: item.symptom,
                                    description: item.description,
                                  ),
                                )
                                .toList(),
                          ),

                          buildSection(
                            title: 'Recomendaciones',
                            icon: Icons.lightbulb_outline,
                            children: data.recommendations
                                .map(
                                  (item) => buildItem(
                                    title: item.category,
                                    description: item.recommendation,
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