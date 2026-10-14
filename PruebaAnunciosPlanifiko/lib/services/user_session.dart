import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/constants.dart';
import 'subscription_service.dart';

class UserSession extends ChangeNotifier {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  String? _accessToken;
  String? _userName;

  // 🔥 NUEVOS CAMPOS PREMIUM
  bool _isPremium = false;
  DateTime? _expiresAt;

  String? get accessToken => _accessToken;
  String? get userName => _userName;
  bool get isPremium => _isPremium;
  DateTime? get expiresAt => _expiresAt;
  bool get isLoggedIn => _accessToken != null;

  void setUserData({required String token, required String name}) {
    _accessToken = token;
    _userName = name;
    // Al loguearse, lo ideal es checar el status premium de una vez
    checkPremiumStatus();
    notifyListeners();
  }

  // 🔥 FUNCIÓN PARA CONSULTAR EL BACKEND
  Future<void> checkPremiumStatus() async {
    if (_accessToken == null) return;

    try {

      final isPremium = await SubscriptionService().checkPremiumStatus();

      _isPremium = isPremium;

      print("💎 Estado Premium: $_isPremium");

      notifyListeners();

    } catch (e) {
      print("❌ Error verificando suscripción: $e");
    }
  }

  void clearSession() {
    _accessToken = null;
    _userName = null;
    _isPremium = false;
    _expiresAt = null;
    notifyListeners();
  }
}