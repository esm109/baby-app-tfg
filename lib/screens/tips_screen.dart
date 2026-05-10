import 'package:flutter/material.dart';
import '../models/tip.dart';
import '../services/api_service.dart';

class TipsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const TipsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  List<Tip> tips = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadTips();
  }

  Future<void> loadTips() async {
    try {
      final result = await ApiService.fetchTipsByCategory(widget.categoryId);
      setState(() {
        tips = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : tips.isEmpty
                  ? const Center(child: Text('No hay contenido disponible todavía'))
                  : ListView.builder(
                      itemCount: tips.length,
                      itemBuilder: (context, index) {
                        final tip = tips[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(
                              tip.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(tip.content),
                          ),
                        );
                      },
                    ),
    );
  }
}