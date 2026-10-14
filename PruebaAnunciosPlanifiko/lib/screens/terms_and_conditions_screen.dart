import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  // Colores oficiales (puedes centralizarlos luego si quieres)
  final Color cPetrolBlue = const Color(0xFF264653);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Términos y Condiciones',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: cPetrolBlue,
              fontFamily:  'Poppins',
            ),
            children: _buildTermsSpans(),
          ),
        ),
      ),
    );
  }
}

List<TextSpan> _buildTermsSpans() {
  TextSpan normal(String text) => TextSpan(text: text);
  TextSpan bold(String text) => TextSpan(
    text: text,
    style: const TextStyle(fontWeight: FontWeight.w700),
  );

  return [
    bold('POLÍTICA DE PRIVACIDAD – PLANIFIKO\n\n'),

    normal(
      'En Planifiko, valoramos la privacidad de nuestros usuarios y estamos comprometidos con la protección de sus datos personales.\n'
          'La presente Política de Privacidad describe cómo recopilamos, utilizamos, almacenamos y protegemos la información cuando utilizas nuestra aplicación móvil.\n'
          'Al registrarte y utilizar Planifiko, aceptas las prácticas descritas en esta política.\n\n',
    ),

    bold('1. Información que recopilamos\n'),
    bold('a) Información proporcionada por el usuario\n'),
    normal(
      'Al crear una cuenta y utilizar Planifiko, recopilamos:\n'
          '- Nombres y apellidos\n'
          '- Correo electrónico\n'
          '- Número de teléfono\n'
          '- Contraseña (almacenada de forma cifrada)\n'
          '- Fecha de nacimiento\n\n'
          'El usuario puede registrar voluntariamente información financiera personal, incluyendo:\n'
          '- Ingresos\n'
          '- Gastos\n'
          '- Presupuestos\n'
          '- Préstamos otorgados\n'
          '- Préstamos recibidos\n'
          '- Reportes y registros financieros\n'
          'Planifiko no solicita ni almacena datos bancarios, tarjetas de crédito, cuentas financieras externas, DNI, dirección ni género.\n\n',
    ),

    bold('b) Información recopilada automáticamente\n'),
    normal(
      '- Información del dispositivo\n'
          '- Dirección IP\n'
          '- Datos de uso de la aplicación\n'
          '- Identificadores publicitarios (versión gratuita)\n\n',
    ),

    bold('c) Permisos solicitados\n'),
    normal(
      '- Notificaciones\n'
          '- Acceso a Internet\n\n',
    ),

    bold('2. Uso de la información\n'),
    normal(
      'La información recopilada se utiliza para:\n'
          '- Administrar cuentas\n'
          '- Verificar mayoría de edad\n'
          '- Gestionar información financiera\n'
          '- Generar reportes\n'
          '- Enviar notificaciones\n'
          '- Mostrar publicidad\n'
          '- Gestionar pagos\n'
          '- Mejorar el servicio\n'
          '- Cumplir obligaciones legales\n\n',
    ),

    bold('3. Uso de la fecha de nacimiento\n'),
    normal(
      'La fecha de nacimiento se solicita exclusivamente para verificar que el usuario sea mayor de 18 años.\n\n',
    ),

    bold('4. Publicidad y pagos\n'),
    normal(
      '• La versión gratuita puede mostrar publicidad.\n'
          '• La versión premium elimina la publicidad.\n'
          '• Los pagos se procesan mediante plataformas externas.\n\n',
    ),

    bold('5. Compartición de información\n'),
    normal(
      'Planifiko no vende ni comercializa datos personales.\n'
          'Solo se comparte información con proveedores tecnológicos, plataformas de pago o autoridades cuando la ley lo exige.\n\n',
    ),

    bold('6. Seguridad de los datos\n'),
    normal(
      'Se aplican medidas razonables de seguridad, sin garantizar protección absoluta.\n\n',
    ),

    bold('7. Retención de la información\n'),
    normal(
      'Los datos personales identificables se conservan mientras la cuenta esté activa.\n'
          'Al eliminar la cuenta, los datos serán eliminados o anonimizados.\n'
          'La información estadística y agregada podrá conservarse para análisis y mejora del servicio.\n\n',
    ),

    bold('8. Derechos del usuario\n'),
    normal(
      'El usuario puede acceder, rectificar, eliminar datos o revocar su consentimiento conforme a la Ley N.º 29733.\n\n',
    ),

    bold('9. Privacidad de menores\n'),
    normal(
      'Planifiko está dirigida exclusivamente a mayores de 18 años.\n\n',
    ),

    bold('10. Cambios en la política\n'),
    normal(
      'Planifiko puede actualizar esta política en cualquier momento.\n\n',
    ),

    bold('11. Contacto\n'),
    normal(
      'Correo de contacto: admin@muchiktec.com\n\n',
    ),

    bold('Última actualización: 26/01/2026\n\n'),
  ];
}
