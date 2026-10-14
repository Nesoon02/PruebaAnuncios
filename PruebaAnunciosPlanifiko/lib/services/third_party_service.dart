import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class ThirdPartyService {

  static final ThirdPartyService _instance = ThirdPartyService._internal();
  factory ThirdPartyService() => _instance;
  ThirdPartyService._internal();

  List<dynamic>? _cache;
  int? _cachedAccountId;

  Future<List<dynamic>> getThirdParties({
    required int accountId,
    required String token,
  }) async {

    // ✅ usar cache si ya existe
    if (_cache != null && _cachedAccountId == accountId) {
      print("📦 Usando cache de terceros");
      return _cache!;
    }

    final url = Uri.parse('$API_BASE_URL/terceros?idcuenta=$accountId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {

      final List<dynamic> data = json.decode(response.body);

      _cache = data;
      _cachedAccountId = accountId;

      return data;

    } else {
      throw Exception('Error al obtener terceros');
    }
  }

  void clearCache() {
    _cache = null;
    print("🗑️ Cache de terceros limpiado");
  }
}