// lib/services/auth_service.dart

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:app_muchik/config/constants.dart';
import '../services/user_session.dart';

class AuthService {

  // --- FUNCIÓN LOGOUT (MEJORADA Y CORREGIDA) ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      print('No hay token para cerrar sesión.');
      UserSession().clearSession(); // <-- AÑADIDO: Limpia el UI
      return;
    }

    final url = Uri.parse('$API_BASE_URL/logout'); // <-- USANDO TU CONSTANTE

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      // ... tu lógica de print está bien
    } catch (e) {
      print('Error de conexión al intentar cerrar sesión: $e');
    } finally {
      // 1. Borra el token guardado
      await prefs.remove('accessToken');
      await prefs.remove('idCuenta'); // <-- AÑADIDO: Borra también idCuenta

      // 2. Notifica al UI que la sesión se cerró
      UserSession().clearSession(); // <-- AÑADIDO: Notifica al UI
      print('Token local eliminado y sesión del UI cerrada.');
    }
  }

  // --- FUNCIÓN DE VERIFICACIÓN (CORREGIDA) ---
  Future<Map<String, dynamic>> verifyEmailToken(String token) async {

    final response = await http.post(
      Uri.parse('$API_BASE_URL/email/verify'), // <-- USANDO TU CONSTANTE
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'token': token}),
    );

    if (response.statusCode == 200) {
      // Éxito
      final data = json.decode(response.body);
      final String accessToken = data['access_token'];
      final String userName = data['usuario']['username'];
      final int idCuenta = data['idCuenta']; // <-- Tu backend lo envía

      // --- ¡Lógica de "auto-login" completa! ---

      // 1. Guardamos los datos en SharedPreferences (para persistencia)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', accessToken);
      await prefs.setInt('idCuenta', idCuenta); // <-- AÑADIDO: Guardamos idCuenta

      // 2. Notificamos al UI (para que cambie de pantalla)
      UserSession().setUserData(token: accessToken, name: userName);

      return data;
    } else {
      // Error
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error al verificar el token');
    }
  }

  // --- FUNCIÓN FORGOT PASSWORD ---
  Future<void> forgotPassword(String email) async {
    final url = Uri.parse('$API_BASE_URL/forgot-password');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'correo': email,
        }),
      );

      if (response.statusCode == 200) {
        // Todo ok → no necesitamos retornar nada
        return;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error al enviar el código');
      }
    } catch (e) {
      throw Exception('No se pudo conectar con el servidor');
    }
  }

  Future<void> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$API_BASE_URL/verify-reset-otp');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'correo': email,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      return; // ✔️ OTP válido
    } else {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Código inválido');
    }
  }

  Future<void> resetPassword({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$API_BASE_URL/reset-password');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'correo': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return; // ✔️ Contraseña cambiada correctamente
    } else {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'No se pudo restablecer la contraseña');
    }
  }

  // --- ELIMINAR CUENTA: PASO 1 (Solicitud de OTP) ---
  Future<void> requestDeleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null) throw Exception('Sesión no válida');

    final url = Uri.parse('$API_BASE_URL/request-delete-account');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error al solicitar el código');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión al servidor');
    }
  }

  // --- ELIMINAR CUENTA: PASO 2 (Confirmación con OTP) ---
  Future<void> confirmDeleteAccount(String otp) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null) throw Exception('Sesión no válida');

    final url = Uri.parse('$API_BASE_URL/confirm-delete-account');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        // 🔥 ÉXITO: Limpiamos todo igual que en el logout
        await prefs.remove('accessToken');
        await prefs.remove('idCuenta');
        UserSession().clearSession();
        print('Cuenta eliminada y sesión local limpiada.');
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Código inválido o expirado');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al confirmar la eliminación');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }


}