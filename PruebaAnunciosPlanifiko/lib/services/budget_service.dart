import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class BudgetService {

  static List<dynamic>? _cachedBudgets;
  static int? _cachedAccountId;

  Future<List<dynamic>> getBudgets({
    required int accountId,
    required String token,
  }) async {

    // ✅ Si ya tenemos cache para esta cuenta
    if (_cachedBudgets != null && _cachedAccountId == accountId) {
      return _cachedBudgets!;
    }

    final uri = Uri.parse('$API_BASE_URL/presupuestos').replace(
      queryParameters: {
        'idcuenta': accountId.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      _cachedBudgets = data;
      _cachedAccountId = accountId;

      return data;
    } else {
      throw Exception('Error al obtener presupuestos');
    }
  }

  Map<String,dynamic>? getBudgetFromCache(int id) {
    if (_cachedBudgets == null) return null;

    try {
      return _cachedBudgets!.firstWhere(
        // Comparamos convirtiendo ambos a String por seguridad
        (b) => b['id'].toString() == id.toString(),
        orElse: () => null,
      );
    } catch (e) {
      return null;
    }
  }

  void clearCache() {
    _cachedBudgets = null;
    _cachedAccountId = null;
  }
}