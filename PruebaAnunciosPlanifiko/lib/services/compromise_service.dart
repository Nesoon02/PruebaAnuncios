import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/compromise_model.dart';

class CompromiseService {

  static final CompromiseService _instance = CompromiseService._internal();
  factory CompromiseService() => _instance;
  CompromiseService._internal();

  List<CompromiseModel>? _cache;
  int? _cachedAccountId;

  Future<List<CompromiseModel>> getCompromises({
    required int accountId,
    required String token,
    Map<String,String>? filters,
  }) async {

    // si no hay filtros usamos cache
    if(filters == null && _cache != null && _cachedAccountId == accountId){
      print("📦 Compromisos desde CACHE");
      return _cache!;
    }

    Map<String,String> queryParams = {
      'idcuenta': accountId.toString(),
      if(filters != null) ...filters
    };

    final url = Uri.parse('$API_BASE_URL/compromisos').replace(
        queryParameters: queryParams
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if(response.statusCode == 200){

      final List<dynamic> data = json.decode(response.body);

      final parsed = data
          .map((json) => CompromiseModel.fromJson(json))
          .toList();

      if(filters == null){
        _cache = parsed;
        _cachedAccountId = accountId;
      }

      return parsed;

    }else{
      throw Exception("Error obteniendo compromisos");
    }
  }

  void clearCache(){
    _cache = null;
    _cachedAccountId = null;
    print("🗑️ Cache compromisos limpiado");
  }
}