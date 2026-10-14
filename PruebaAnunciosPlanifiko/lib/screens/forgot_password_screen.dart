// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:app_muchik/services/auth_service.dart';

// --- COLORES OFICIALES ---
final Color cPetrolBlue = const Color(0xFF264653);
final Color cMintGreen = const Color(0xFF2A9D8F);
final Color cLightGrey = const Color(0xFFF4F4F4);
final Color cWhite = const Color(0xFFFFFFFF);

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _authService.forgotPassword(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/forgot-password-otp',
        arguments: _emailController.text.trim(),
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
      body: Stack(
        children: [
          // Fondo gradiente Planifiko
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cPetrolBlue, cMintGreen],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _Content(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _Content() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Header
          Text(
            'Recuperar contraseña',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: cWhite,
              fontFamily: 'Poppins',
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Ingresa tu correo electrónico y te enviaremos un código de verificación.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: cWhite.withOpacity(0.9),
              fontFamily: 'Poppins',
            ),
          ),

          const SizedBox(height: 30),

          // Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cWhite.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _EmailField(),
                const SizedBox(height: 24),
                _ContinueButton(),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            '¿No tienes acceso a tu correo?\nEscríbenos a admin@muchiktec.com',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: cWhite.withOpacity(0.8),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _EmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correo electrónico',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cPetrolBlue,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingresa tu correo';
            }
            if (!value.contains('@')) {
              return 'Correo inválido';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'ejemplo@correo.com',
            prefixIcon: Icon(Icons.email_outlined, color: cPetrolBlue),
            filled: true,
            fillColor: cLightGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.black12,
                width: 1,
              ),
            ),
          ),
          style: TextStyle(
            color: cPetrolBlue,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _ContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: cMintGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Text(
          'Enviar código',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
