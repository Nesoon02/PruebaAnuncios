import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import 'auth_service.dart';

class SubscriptionService {

  bool? _cachedPremium;
  DateTime? _lastCheck;

  Future<bool> verifySubscription({
    required String productId,
    required String purchaseToken,
  }) async {

    final authToken = await AuthService().getToken();

    if (authToken == null) {
      print("Usuario no autenticado");
      return false;
    }

    final response = await http.post(
      Uri.parse('$API_BASE_URL/subscription/verify'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'product_id': productId,
        'purchase_token': purchaseToken,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    }

    print("Error backend: ${response.body}");
    return false;
  }


  Future<bool> checkPremiumStatus() async {

    if (_cachedPremium != null &&
        _lastCheck != null &&
        DateTime.now().difference(_lastCheck!).inMinutes < 5) {

      return _cachedPremium!;
    }

    final authToken = await AuthService().getToken();

    if (authToken == null) {
      print("Usuario no autenticado");
      return false;
    }

    final response = await http.get(
      Uri.parse('$API_BASE_URL/subscription/status'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      _cachedPremium = data['premium'] == true;
      _lastCheck = DateTime.now();

      return _cachedPremium!;
    }

    print("Error status: ${response.body}");
    return false;
  }
}