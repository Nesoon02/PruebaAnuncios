import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class CategoryService {

  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  Map<int, List<dynamic>> _cache = {};

  Future<List<dynamic>> getCategories({
    required int accountId,
    required String token,
  }) async {

    if (_cache.containsKey(accountId)) {
      print("📦 Categorias desde CACHE");
      return _cache[accountId]!;
    }

    final url = Uri.parse('$API_BASE_URL/categorias/')
        .replace(queryParameters: {
      'idcuenta': accountId.toString(),
    });

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {

      final List<dynamic> data = json.decode(response.body);

      _cache[accountId] = data;

      print("🌐 Categorias desde API");

      return data;
    }

    throw Exception("Error cargando categorias");
  }

  void clearCache(){
    _cache.clear();
  }
}