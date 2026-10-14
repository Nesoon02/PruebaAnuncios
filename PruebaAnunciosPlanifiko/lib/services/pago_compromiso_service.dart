import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_muchik/config/constants.dart';
import '../models/pago_compromiso_model.dart';

class PagoCompromisoService {
  static final PagoCompromisoService _instance = PagoCompromisoService._internal();
  factory PagoCompromisoService() => _instance;
  PagoCompromisoService._internal();

  // cache por compromiso
  final Map<String, List<PagoCompromisoModel>> _cache = {};

  Future<List<PagoCompromisoModel>> getPayments({
    required String compromiseId,
    required String token,
  }) async {

    if (_cache.containsKey(compromiseId)) {
      print("📦 Usando caché de pagos para compromiso: $compromiseId");
      return _cache[compromiseId]!;
    }

    final url = Uri.parse('$API_BASE_URL/compromisos/$compromiseId/pagos');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final payments = data
          .map((json) => PagoCompromisoModel.fromJson(json))
          .toList();

      _cache[compromiseId] = payments;

      return payments;
    } else {
      throw Exception('Error al obtener historial de pagos');
    }
  }

  // limpiar todo
  void clearAllCache() {
    _cache.clear();
    print("🗑️ Caché de pagos completamente limpiado");
  }
}