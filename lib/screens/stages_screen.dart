import 'package:flutter/material.dart';
import '../models/stage.dart';
import '../services/api_service.dart';
import 'stage_detail_screen.dart';

class StagesScreen extends StatefulWidget {
  const StagesScreen({super.key});

  @override
  State<StagesScreen> createState() => _StagesScreenState();
}

class _StagesScreenState extends State<StagesScreen> {
  List<Stage> stages = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadStages();
  }

  Future<void> loadStages() async {
    try {
      final result = await ApiService.fetchStages();

      setState(() {
        stages = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar las etapas';
        isLoading = false;
      });
    }
  }

  List<String> splitKeyPoints(String keyPoints) {
    return keyPoints
        .replaceAll('<br>', '\n')
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etapas del embarazo'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: stages.length,
                  itemBuilder: (context, index) {
                    final stage = stages[index];
                    final points = splitKeyPoints(stage.keyPoints);

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StageDetailScreen(
                              stageId: stage.id,
                              selectedWeek: stage.startWeek < 8 ? 8 : stage.startWeek,
                            ),
                          ),
                        );
                      },

                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(16),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                stage.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                'Semana ${stage.startWeek} - ${stage.endWeek}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(stage.shortDescription),

                              const SizedBox(height: 12),

                              ...points.map(
                                (point) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(point),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}