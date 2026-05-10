import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/category.dart';
import '../models/tip.dart';
import '../models/stage.dart';
import '../models/stage_details.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';
  
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
}