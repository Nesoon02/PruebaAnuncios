import 'package:flutter/material.dart';
import 'package:app_muchik/services/iap_service.dart';
import 'package:app_muchik/services/subscription_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});


  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isProcessing = false;
  bool _purchaseSuccess = false;
  final IAPService _iapService = IAPService();
  // Colores oficiales de Planifiko
  final Color cAzulPetroleo = const Color(0xFF264653);
  final Color cVerdeMenta = const Color(0xFF2A9D8F);
  final Color cBlanco = const Color(0xFFFFFFFF);
  final Color cGrisFondo = const Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _iapService.initialize();
  }

  @override
  void dispose() {
    _iapService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (_purchaseSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/loading',
                (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: cGrisFondo,
        body: CustomScrollView(
          slivers: [
            // Header con Gradiente y Estilo Moderno
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              backgroundColor: cAzulPetroleo,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text(
                  'Planifiko Premium',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [cAzulPetroleo, cAzulPetroleo.withOpacity(0.8)],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.auto_awesome, size: 60, color: cVerdeMenta),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      
            // Lista de Beneficios con diseño de Tarjetas
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Desbloquea tu potencial financiero',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: cAzulPetroleo,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Únete a la comunidad de Planifiko y toma el control total.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    ),
                    const SizedBox(height: 24),
      
                    // Beneficios
                    _buildPremiumCard(Icons.app_blocking, 'Cero Anuncios', 'Navega por la app sin distracciones publicitarias.'),
                    _buildPremiumCard(Icons.group_add_rounded, 'Multiperfiles', 'Crea hasta 10 perfiles para toda tu familia.'),
                    _buildPremiumCard(Icons.file_download_rounded, 'Exportar Reportes', 'Descarga tus informes detallados en formato PDF y Excel.'),
                    _buildPremiumCard(Icons.security_rounded, 'Soporte VIP', 'Atención prioritaria para cualquier consulta.'),
                  ],
                ),
              ),
            ),
      
            // Espacio para que el botón no tape el contenido
            const SliverToBoxAdapter(child: SizedBox(height: 180)),
          ],
        ),
      
        // Botón Flotante de Compra (CTA)
        bottomSheet: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cBlanco,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Suscripción Anual', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(
                    'S/ 4.90',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cAzulPetroleo),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _startPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cVerdeMenta,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: cVerdeMenta.withOpacity(0.4),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                      : const Text(
                    'OBTENER PREMIUM',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Prueba de 7 días gratis • Cancela cuando quieras',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cBlanco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cVerdeMenta.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: cVerdeMenta, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: cVerdeMenta.withOpacity(0.3), size: 20),
        ],
      ),
    );
  }

  Future<void> _startPurchase() async {
    setState(() => _isProcessing = true);

    try {
      // 1. Lanza el flujo de Google Play
      // Nota: El plugin de IAP suele devolver true/false o manejarlo por listeners
      await _iapService.buySubscription();

      // 2. Bucle de verificación (Polling)
      // Vamos a intentar verificar el estatus premium hasta 5 veces (una cada 2 segundos)
      // porque el backend de Google y el tuyo pueden tardar un poquito en "hablar".
      bool confirmedPremium = false;
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(seconds: 2));
        final status = await SubscriptionService().checkPremiumStatus();
        if (status) {
          confirmedPremium = true;
          break; // ¡Ya es premium! Salimos del bucle
        }
      }

      if (confirmedPremium) {
        setState(() => _purchaseSuccess = true);
        _showSuccessDialog(); // Se dispara SOLO de forma automática
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Procesando suscripción... Si no se activa, intenta reingresar en unos momentos.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print("Error en la compra: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo completar la compra.'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // ✅ Obligamos a que use el botón para evitar estados inconsistentes
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2A9D8F), size: 80), // cVerdeMenta
            const SizedBox(height: 16),
            const Text(
              '¡Bienvenido a Premium!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ahora tienes acceso a todos los beneficios de Planifiko.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF264653)), // cAzulPetroleo
                onPressed: () {
                  Navigator.pop(context); // Cierra el diálogo
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/loading', // Asegúrate de que este sea el nombre de tu ruta en AppRoutes
                        (route) => false,
                  );
                },
                child: const Text('EMPEZAR', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}