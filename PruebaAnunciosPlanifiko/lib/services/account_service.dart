import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class AccountService {

  static final AccountService _instance = AccountService._internal();
  factory AccountService() => _instance;
  AccountService._internal();

  Map<int, dynamic>? _accountCache;
  List<dynamic>? _cachedAccounts;

  Future<dynamic> getAccount({
    required int accountId,
    required String token,
  }) async {

    // 🔥 si ya existe en cache no llamamos API
    if (_accountCache != null && _accountCache!.containsKey(accountId)) {
      print("📦 Account desde CACHE");
      return _accountCache![accountId];
    }

    final url = Uri.parse('$API_BASE_URL/accounts/$accountId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {

      final data = json.decode(response.body);

      _accountCache ??= {};
      _accountCache![accountId] = data;

      print("🌐 Account desde API");

      return data;
    }

    throw Exception("Error cargando cuenta");
  }

  Future<List<dynamic>> getAccounts({
    required String token,
  }) async {

    if (_cachedAccounts != null) {
      print("📦 Usando cache de cuentas");
      return _cachedAccounts!;
    }

    final response = await http.get(
      Uri.parse('$API_BASE_URL/cuentas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _cachedAccounts = data;
      return data;
    } else {
      throw Exception('Error al obtener cuentas');
    }
  }

  void clearCacheaccountslist() {
    _cachedAccounts = null;
  }

  void clearCache(){
    _accountCache = null;
  }
}