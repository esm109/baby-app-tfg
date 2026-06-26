import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/hospital_bag_item.dart';
import '../services/api_service.dart';

class HospitalBagScreen extends StatefulWidget {
  final int selectedWeek;

  const HospitalBagScreen({
    super.key,
    required this.selectedWeek,
  });

  @override
  State<HospitalBagScreen> createState() => _HospitalBagScreenState();
}

class _HospitalBagScreenState extends State<HospitalBagScreen> {
  List<HospitalBagItem> items = [];
  Map<int, bool> checkedItems = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBag();
  }

  Future<void> loadBag() async {
    final result = await ApiService.fetchHospitalBag();
    final prefs = await SharedPreferences.getInstance();

    final filteredItems = <HospitalBagItem>[];
    final savedChecks = <int, bool>{};

    

    for (final item in result) {
      final isDeleted =
          prefs.getBool('hospital_bag_deleted_${item.id}') ?? false;

      if (isDeleted) {
        continue;
      }

      final customName =
          prefs.getString('hospital_bag_custom_name_${item.id}');

      final finalItem = HospitalBagItem(
        id: item.id,
        itemName: customName ?? item.itemName,
        category: item.category,
      );

      filteredItems.add(finalItem);

      savedChecks[item.id] = prefs.getBool('hospital_bag_${item.id}') ?? false;
    }

    final customItems = prefs
    .getKeys()
    .where((key) => key.startsWith('hospital_bag_custom_item_'))
    .toList();

    for (final key in customItems) {
      final value = prefs.getString(key);

      if (value == null) continue;

      final parts = value.split('|');

      final id = int.parse(
        key.replaceFirst('hospital_bag_custom_item_', ''),
      );

      final itemName = parts[0];
      final category = parts.length > 1 ? parts[1] : 'Personalizado';

      filteredItems.add(
        HospitalBagItem(
          id: id,
          itemName: itemName,
          category: category,
        ),
      );

      savedChecks[id] = prefs.getBool('hospital_bag_$id') ?? false;
    }

    setState(() {
      items = filteredItems;
      checkedItems = savedChecks;
      isLoading = false;
    });
  }

  Future<void> saveItem(int id, bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'hospital_bag_$id',
      value,
    );
  }

  Future<void> deleteItem(HospitalBagItem item) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      items.removeWhere((element) => element.id == item.id);
      checkedItems.remove(item.id);
    });

    await prefs.setBool('hospital_bag_deleted_${item.id}', true);
    await prefs.remove('hospital_bag_${item.id}');
  }

  Future<void> editItemName(HospitalBagItem item) async {
    final controller = TextEditingController(text: item.itemName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar elemento'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre del elemento',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();

              if (newName.isEmpty) return;

              final prefs = await SharedPreferences.getInstance();

              await prefs.setString(
                'hospital_bag_custom_name_${item.id}',
                newName,
              );

              setState(() {
                final index = items.indexWhere((e) => e.id == item.id);

                if (index != -1) {
                  items[index] = HospitalBagItem(
                    id: item.id,
                    itemName: newName,
                    category: item.category,
                  );
                }
              });

              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = checkedItems.values.where((e) => e).length;

    final progress = items.isEmpty ? 0.0 : completed / items.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7FD),

      appBar: AppBar(
        title: const Text('Bolsa del hospital'),
        actions: [
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Restaurar lista'),
                  content: const Text(
                    '¿Quieres restaurar la lista original? Se perderán los cambios personalizados.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await resetHospitalBag();
                      },
                      child: const Text('Restaurar'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Restaurar'),
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBE6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🎒 Preparación para el parto',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (widget.selectedWeek < 28)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3CD),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFFD54F),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.orange,
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    'Se recomienda comenzar a preparar la bolsa del hospital a partir de la semana 28. Actualmente estás en la semana ${widget.selectedWeek}.',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 10),

                        Text(
                          '$completed de ${items.length} elementos preparados',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 9,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: addItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Añadir elemento'),
                    ),
                  ),

                  const SizedBox(height: 16), 

                  Expanded(
                    child: ListView(
                      children: items
                          .map((item) => item.category)
                          .toSet()
                          .map((category) {
                        final categoryItems = items
                            .where((item) => item.category == category)
                            .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 12,
                                bottom: 8,
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            ...categoryItems.map((item) {
                              return Card(
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: CheckboxListTile(
                                  title: Text(item.itemName),
                                  subtitle: Text(item.category),
                                  value: checkedItems[item.id] ?? false,
                                  secondary: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        editItemName(item);
                                      } else if (value == 'delete') {
                                        deleteItem(item);
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Editar'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                  onChanged: (value) async {
                                    final newValue = value ?? false;

                                    setState(() {
                                      checkedItems[item.id] = newValue;
                                    });

                                    await saveItem(item.id, newValue);
                                  },
                                ),
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> addItem() async {
    final nameController = TextEditingController();
    final categoryController = TextEditingController(text: 'Personalizado');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir elemento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del elemento',
              ),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Categoría',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final category = categoryController.text.trim();

              if (name.isEmpty) return;

              final prefs = await SharedPreferences.getInstance();

              final newId = DateTime.now().millisecondsSinceEpoch;

              final newItem = HospitalBagItem(
                id: newId,
                itemName: name,
                category: category.isEmpty ? 'Personalizado' : category,
              );

              await prefs.setString(
                'hospital_bag_custom_item_$newId',
                '${newItem.itemName}|${newItem.category}',
              );

              setState(() {
                items.add(newItem);
                checkedItems[newId] = false;
              });

              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  Future<void> resetHospitalBag() async {
    final prefs = await SharedPreferences.getInstance();

    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith('hospital_bag_')) {
        await prefs.remove(key);
      }
    }

    await loadBag();
  }
}