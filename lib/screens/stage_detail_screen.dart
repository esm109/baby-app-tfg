import 'package:flutter/material.dart';
import '../models/stage_details.dart';
import '../services/api_service.dart';
import 'profile_setup_screen.dart';
import '../models/baby_size_comparison.dart';
import 'stages_screen.dart';
import '../models/weekly_tip.dart';

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
  WeeklyTip? weeklyTip;
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

      final sizeResult = await ApiService.fetchBabySizeComparison(
        widget.selectedWeek,
      );

      final weeklyTipResult = await ApiService.fetchWeeklyTip(
        widget.selectedWeek,
      );

      setState(() {
        details = result;
        babySizes = sizeResult;
        isLoading = false;
        weeklyTip = weeklyTipResult;
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
    final progress = widget.selectedWeek / 40;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF1E7F8),
            Color(0xFFFFF1F7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          if (data.stage.mediaType == 'image')
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Image.asset(
                data.stage.mediaUrl ?? '',
                key: ValueKey(data.stage.mediaUrl),
                height: 220,
                fit: BoxFit.contain,
              ),
            ),

          if (data.stage.mediaType == 'emoji')
            Text(
              data.stage.mediaUrl ?? '',
              style: const TextStyle(fontSize: 70),
            ),

          const SizedBox(height: 18),

          Text(
            'Semana ${widget.selectedWeek}',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            data.stage.name,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF6B5870),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            '${(progress * 100).round()}% del embarazo completado',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            data.stage.shortDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
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

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileSetupScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Editar semana'),
            ),
          ),
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
                  ? const Center(child: Text('No hay información disponible'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildHeader(data),

                          if (babySizes.isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 20),
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
                                                    item.comparisonType.toUpperCase(),
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
                                ],
                              ),
                            ),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const StagesScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.calendar_month),
                              label: const Text('Ver otros trimestres'),
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
                                ],
                              ),
                            ),

                          const SizedBox(height: 20),

                          buildSection(
                            title: 'Desarrollo del bebé',
                            icon: Icons.child_care,
                            children: data.babyDevelopment
                                .map(
                                  (item) => buildExpandableItem(
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
                                  (item) => buildExpandableItem(
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
                                  (item) => buildExpandableItem(
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