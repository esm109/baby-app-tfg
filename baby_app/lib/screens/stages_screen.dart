import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/stage.dart';
import '../services/api_service.dart';
import 'stage_detail_screen.dart';
import '../widgets/app_menu_button.dart';
import '../widgets/app_bottom_menu_bar.dart';

class StagesScreen extends StatefulWidget {
  const StagesScreen({super.key});

  @override
  State<StagesScreen> createState() => _StagesScreenState();
}

class _StagesScreenState extends State<StagesScreen> {
  List<Stage> stages = [];
  bool isLoading = true;
  String errorMessage = '';
  int selectedWeek = 12;

  @override
  void initState() {
    super.initState();
    loadSelectedWeek();
    loadStages();
  }

  final PageController _pageController = PageController(
    viewportFraction: 0.88,
  );

  int currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadSelectedWeek() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      selectedWeek = prefs.getInt('selectedWeek') ?? 12;
    });
  }

  int getCurrentTrimesterId(int week) {
    if (week >= 1 && week <= 12) return 1;
    if (week >= 13 && week <= 28) return 2;
    return 3;
  }

  final List<Map<String, dynamic>> trimesters = [
    {
      'id': 1,
      'title': 'Primer trimestre',
      'weeks': 'Semana 1 - 12',
      'image': 'assets/images/trimester_1.png',
      'description': 'Inicio del embarazo y formación principal del bebé.',
      'color': Color(0xFFFFE8F2),
      'points': [
        'Formación de órganos',
        'Primer latido cardíaco',
        'Náuseas y cansancio',
        'Primera ecografía',
        'Cambios hormonales',
      ],
    },
    {
      'id': 2,
      'title': 'Segundo trimestre',
      'weeks': 'Semana 13 - 28',
      'image': 'assets/images/trimester_1.png',
      'description': 'Etapa de crecimiento y mayor estabilidad del embarazo.',
      'color': Color(0xFFE8F8EE),
      'points': [
        'Crecimiento rápido del bebé',
        'Primeros movimientos',
        'Menos náuseas',
        'Aumento de energía',
        'Ecografía morfológica',
      ],
    },
    {
      'id': 3,
      'title': 'Tercer trimestre',
      'weeks': 'Semana 29 - 40',
      'image': 'assets/images/trimester_1.png',
      'description': 'Preparación final para el nacimiento del bebé.',
      'color': Color(0xFFFFF4E8),
      'points': [
        'Mayor peso del bebé',
        'Preparación de la bolsa del hospital',
        'Contracciones de práctica',
        'Citas médicas más frecuentes',
        'Preparación para el parto',
      ],
    },
  ];

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

  void openTrimester(int trimesterId) {
    final representativeWeek = getRepresentativeWeekByTrimester(trimesterId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StageDetailScreen(
          stageId: trimesterId,
          selectedWeek: representativeWeek,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etapas del embarazo'),
        centerTitle: true,
        actions: const [
          AppMenuButton(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Desliza para explorar cada etapa del embarazo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: trimesters.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = trimesters[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: buildTrimesterCard(item),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                trimesters.length,
                (index) {
                  final isActive = currentPage == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.purple : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomMenuBar(),
    );
  }

  Widget buildTrimesterCard(Map<String, dynamic> item) {
    final int trimesterId = item['id'];

    return GestureDetector(
      onTap: () {
        openTrimester(trimesterId);
      },
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: item['color'],
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 300,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Image.asset(
                    item['image'],
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                item['title'],
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                item['weeks'],
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                item['description'],
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  title: const Text(
                    'Qué puedes experimentar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    ...List.generate(
                      item['points'].length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• '),
                            Expanded(
                              child: Text(
                                item['points'][index],
                                style: const TextStyle(height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    openTrimester(trimesterId);
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Explorar trimestre'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int getRepresentativeWeekByTrimester(int trimesterId) {
    if (trimesterId == 1) {
      return 8;
    } else if (trimesterId == 2) {
      return 20;
    } else {
      return 32;
    }
  }
}