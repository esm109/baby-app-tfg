import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Baby3DViewerScreen extends StatelessWidget {
  const Baby3DViewerScreen({
    super.key,
    required this.weekNumber,
  });

  final int weekNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F2),
      appBar: AppBar(
        title: const Text('Vista 3D del bebé'),
        backgroundColor: const Color(0xFFFFD6C9),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          Text(
            'Semana $weekNumber',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Arrastra el modelo para girarlo y pellizca la pantalla para ampliar o reducir.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  color: const Color(0xFFFFEFE8),
                  child: const ModelViewer(
                    backgroundColor: Color(0xFFFFEFE8),
                    src: 'assets/models/baby_fetus.glb',
                    alt: 'Modelo 3D del bebé',
                    cameraControls: true,
                    autoRotate: true,
                    disableZoom: false,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}