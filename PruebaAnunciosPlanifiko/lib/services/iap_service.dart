import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'subscription_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final SubscriptionService _subscriptionService = SubscriptionService();

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  List<ProductDetails> products = [];

  final String _productId = 'planifiko_premium_yearly';

  Future<void> initialize() async {

    final bool available = await _iap.isAvailable();

    if (!available) {
      print("Google Play Billing no disponible");
      return;
    }

    _subscription = _iap.purchaseStream.listen(_listenToPurchaseUpdated);

    await _loadProducts();

    await _iap.restorePurchases();

    await retryPendingPurchase();
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails({_productId});

    if (response.notFoundIDs.isNotEmpty) {
      print("Producto no encontrado");
    }

    products = response.productDetails;
  }

  Future<void> buySubscription() async {
    if (products.isEmpty) {
      print("Producto no cargado aún");
      return;
    }

    final productDetails = products.first;
    final purchaseParam = PurchaseParam(productDetails: productDetails);

    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {

    for (var purchase in purchaseDetailsList) {

      if (purchase.status == PurchaseStatus.pending) {
        print("Compra pendiente...");
      }

      if (purchase.status == PurchaseStatus.purchased ||  purchase.status == PurchaseStatus.restored) {

        final purchaseToken =
            purchase.verificationData.serverVerificationData;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_purchase_token', purchaseToken);

        print("Token: $purchaseToken");

        // 🔥 Validar con backend
        final isValid = await _subscriptionService.verifySubscription(
          productId: purchase.productID,
          purchaseToken: purchaseToken,
        );

        if (isValid) {
          print("Suscripción validada en backend ✅");
          await prefs.remove('pending_purchase_token');
        } else {
          print("Suscripción inválida ❌");
        }

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }

      if (purchase.status == PurchaseStatus.error) {
        print("Error en compra: ${purchase.error}");
      }
    }
  }

  Future<void> retryPendingPurchase() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('pending_purchase_token');

    if (token != null) {
      print("Reintentando enviar compra pendiente");

      await _subscriptionService.verifySubscription(
        productId: _productId,
        purchaseToken: token,
      );

      await prefs.remove('pending_purchase_token');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }
}