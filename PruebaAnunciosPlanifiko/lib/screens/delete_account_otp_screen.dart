// lib/screens/delete_account_otp_screen.dart
import 'package:app_muchik/services/auth_service.dart';
import 'package:flutter/material.dart';

class DeleteAccountOtpScreen extends StatefulWidget {
  const DeleteAccountOtpScreen({Key? key}) : super(key: key);

  @override
  _DeleteAccountOtpScreenState createState() => _DeleteAccountOtpScreenState();
}

class _DeleteAccountOtpScreenState extends State<DeleteAccountOtpScreen> {
  // --- DEFINICIÓN DE COLORES OFICIALES ---
  final Color cAzulPetroleo = const Color(0xFF264653);
  final Color cVerdeMenta = const Color(0xFF2A9D8F);
  final Color cGrisClaro = const Color(0xFFF4F4F4);
  final Color cBlanco = const Color(0xFFFFFFFF);
  final Color cRojoAlerta = const Color(0xFFE76F51); // Un rojo suave acorde a tu paleta

  final TextEditingController _tokenController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _confirmDelete() async {
    if (_tokenController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, ingresa el código de confirmación.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Llamamos al nuevo método que creamos en el AuthService
      await _authService.confirmDeleteAccount(_tokenController.text.trim());

      if (!mounted) return;

      // Si llegó aquí es porque el 200 fue exitoso y la sesión se limpió
      // Mostramos un mensaje de éxito y mandamos al login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu cuenta ha sido eliminada permanentemente.'),
          backgroundColor: Colors.black87,
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (route) => false,
      );

    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
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
              cRojoAlerta.withOpacity(0.6), // Cambio a tono rojizo por ser acción crítica
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: cBlanco,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ícono de advertencia
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.report_problem_outlined,
                            size: 60,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Confirmar Eliminación',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: cAzulPetroleo,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Por seguridad, ingresa el código que enviamos a tu correo para confirmar que deseas borrar tu cuenta.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: cAzulPetroleo.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'CÓDIGO DE VERIFICACIÓN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: cAzulPetroleo,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _tokenController,
                          style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 4,
                            fontWeight: FontWeight.bold,
                            color: cAzulPetroleo,
                          ),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: '......',
                            hintStyle: TextStyle(color: cAzulPetroleo.withOpacity(0.2)),
                            filled: true,
                            fillColor: cGrisClaro,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                            ),
                          ),
                        ),

                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const SizedBox(height: 30),

                        _isLoading
                            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent))
                            : SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            onPressed: _isLoading ? null : _confirmDelete,
                            child: const Text(
                              'BORRAR CUENTA AHORA',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
}