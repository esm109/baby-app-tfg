import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/category.dart';
import '../models/tip.dart';
import '../models/stage.dart';
import '../models/stage_details.dart';
import '../models/baby_size_comparison.dart';
import '../models/weekly_tip.dart';
import '../models/checklist_item.dart';
import '../models/appointment.dart';
import '../models/hospital_bag_item.dart';

class ApiService {
  //static const String baseUrl = 'http://localhost:3000';
  //static const String baseUrl = 'http://192.168.1.137:3000';
  static const String baseUrl = 'http://192.168.0.180:3000';
  
  static Future<String> fetchMessage() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/message'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'];
    } else {
      throw Exception('Error al cargar el mensaje');
    }
  }

  static Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/categories'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Category.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar las categorías');
    }
  }

  static Future<List<Tip>> fetchTipsByCategory(int categoryId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/tips/category/$categoryId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Tip.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar los tips');
    }
  }

  static Future<List<Stage>> fetchStages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/stages'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Stage.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar las etapas');
    }
  }

  static Future<StageDetails> fetchStageDetails(int stageId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stages/$stageId/details'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return StageDetails.fromJson(data);
    } else {
      throw Exception('Error al cargar los detalles de la etapa');
    }
  }

  static Future<List<BabySizeComparison>> fetchBabySizeComparison(int week) async {
    final response = await http.get(
      Uri.parse('$baseUrl/baby-size/$week'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      return data
          .map((item) => BabySizeComparison.fromJson(item))
          .toList();
    } else {
      throw Exception(
        'Error al cargar la comparación de tamaño',
      );
    }
  }

  static Future<WeeklyTip?> fetchWeeklyTip(int week) async {
    final response = await http.get(
      Uri.parse('$baseUrl/weekly-tip/$week'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeeklyTip.fromJson(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al cargar el consejo semanal');
    }
  }

  static Future<List<ChecklistItem>> fetchChecklist(int week) async {
    final response = await http.get(
      Uri.parse('$baseUrl/checklist/$week'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is List) {
        return data
            .map((item) => ChecklistItem.fromJson(item))
            .toList();
      }

      return [];
    } else {
      return [];
    }
  }

  static Future<List<Appointment>> fetchAppointments(
  int week,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/appointments/$week'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data =
          json.decode(response.body);

      return data
          .map((item) => Appointment.fromJson(item))
          .toList();
    }

    throw Exception(
      'Error al cargar citas',
    );
  }

  static Future<List<HospitalBagItem>> fetchHospitalBag() async {
    final response = await http.get(
      Uri.parse('$baseUrl/hospital-bag'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data =
          json.decode(response.body);

      return data
          .map(
            (item) =>
                HospitalBagItem.fromJson(item),
          )
          .toList();
    }

    throw Exception(
      'Error al cargar bolsa hospital',
    );
  }

  static Future<String> sendChatMessage({required String message, required int selectedWeek, String? mood, String? lastDiaryEntry, String? hospitalBagProgress,required List<Map<String, dynamic>> conversationHistory,}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'message': message,
        'selectedWeek': selectedWeek,
        'mood': mood,
        'lastDiaryEntry': lastDiaryEntry,
        'hospitalBagProgress': hospitalBagProgress,
        'conversationHistory': conversationHistory,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['reply'] ?? 'No he podido generar una respuesta.';
    }

    throw Exception('Error al enviar mensaje al asistente');
  }
}