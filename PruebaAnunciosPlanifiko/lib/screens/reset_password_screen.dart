// lib/screens/reset_password_screen.dart
import 'package:app_muchik/services/auth_service.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // --- COLORES OFICIALES ---
  final Color cAzulPetroleo = const Color(0xFF264653);
  final Color cVerdeMenta = const Color(0xFF2A9D8F);
  final Color cGrisClaro = const Color(0xFFF4F4F4);
  final Color cBlanco = const Color(0xFFFFFFFF);

  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_passwordController.text.isEmpty ||
        _confirmController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Completa ambos campos.';
      });
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await AuthService().resetPassword(
        email: widget.email,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Contraseña actualizada con éxito'),
          backgroundColor: cVerdeMenta,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (_) => false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cAzulPetroleo,
              Color.lerp(cAzulPetroleo, cVerdeMenta, 0.35)!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Botón volver
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Card principal
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: cBlanco,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Icono
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cVerdeMenta.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_reset_rounded,
                            size: 60,
                            color: cVerdeMenta,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Nueva contraseña',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: cAzulPetroleo,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Crea una contraseña segura para\n${widget.email}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: cAzulPetroleo.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 28),

                        _buildPasswordField(
                          controller: _passwordController,
                          label: 'Nueva contraseña',
                        ),

                        const SizedBox(height: 16),

                        _buildPasswordField(
                          controller: _confirmController,
                          label: 'Confirmar contraseña',
                        ),

                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage,
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 28),

                        _isLoading
                            ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            cVerdeMenta,
                          ),
                        )
                            : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cVerdeMenta,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Actualizar contraseña',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: cBlanco,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: cGrisClaro,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cVerdeMenta, width: 2),
        ),
      ),
    );
  }
}
