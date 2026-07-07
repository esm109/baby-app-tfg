import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../widgets/app_menu_button.dart';

class Baby3DViewerScreen extends StatelessWidget {
  const Baby3DViewerScreen({
    super.key,
    required this.weekNumber,
    required this.modelPath,
    required this.trimesterTitle,
  });

  final int weekNumber;
  final String modelPath;
  final String trimesterTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F2),
      appBar: AppBar(
        title: const Text('Vista 3D del bebé'),
        backgroundColor: const Color(0xFFFFD6C9),
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: const [
          AppMenuButton(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            Text(
              trimesterTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Semana $weekNumber',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8DF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.black87,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Información importante',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    Text(
                      'Este modelo 3D está pensado para ofrecer una referencia visual del desarrollo del bebé. '
                      'Es una representación orientativa, no sustituye la opinión de un profesional sanitario '
                      'ni refleja el tamaño real exacto del bebé.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Arrastra para girar el modelo y pellizca para ampliar o reducir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: ModelViewer(
                    backgroundColor: const Color(0xFFFFEFE8),
                    src: modelPath,
                    alt: 'Modelo 3D del bebé',
                    cameraControls: true,
                    autoRotate: true,
                    disableZoom: false,
                    shadowIntensity: 0.8,
                    exposure: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}