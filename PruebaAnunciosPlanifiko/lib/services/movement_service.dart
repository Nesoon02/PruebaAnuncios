import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_muchik/config/constants.dart';

class MovementService {
  static final MovementService _instance = MovementService._internal();
  factory MovementService() => _instance;
  MovementService._internal();

  // El caché guarda la lista de movimientos por idCuenta
  Map<int, List<dynamic>> _cache = {};

  Future<List<dynamic>> getMovements({required int accountId, required String token}) async {
    if (_cache.containsKey(accountId)) {
      print("📦 Usando caché para movimientos de la cuenta: $accountId");
      return _cache[accountId]!;
    }

    final url = Uri.parse('$API_BASE_URL/movimientos?idcuenta=$accountId');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cache[accountId] = data;
        return data;
      } else {
        throw Exception('Error al obtener movimientos');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getMovementsFilter({
    required int accountId,
    required String token,
    int? categoryId,
    int? month,
    int? year,
  }) async {

    final queryParams = {
      'idcuenta': accountId.toString(),
    };

    if (categoryId != null) {
      queryParams['idcategoria'] = categoryId.toString();
    }

    if (month != null) {
      queryParams['mes'] = month.toString();
    }

    if (year != null) {
      queryParams['anio'] = year.toString();
    }

    final url = Uri.parse('$API_BASE_URL/movimientos')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener movimientos filtrados');
    }
  }
  // 🔥 CRUCIAL: Limpiar caché cuando el usuario agrega/edita un gasto o ingreso
  void clearCache() {
    _cache.clear();
    print("🗑️ Caché de movimientos limpiado.");
  }
}