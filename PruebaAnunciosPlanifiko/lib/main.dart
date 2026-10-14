// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../services/user_session.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/terms_and_conditions_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/forgot_password_otp_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/delete_account_otp_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/budgets_screen.dart';
import 'screens/assign_budget_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/compromises_screen.dart';
import 'screens/compromises_create_screen.dart';
import 'screens/compromises_detail_screen.dart';
import 'screens/accounts_screen.dart';
import 'screens/compromises_tiers_screen.dart';
import 'screens/movements_screen.dart';
import 'screens/notifications_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // <--- Importar

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No necesitas inicializar Firebase aquí. La librería lo maneja.
  print("🔔 Notificación recibida en segundo plano: ${message.messageId}");
  if (message.notification != null) {
    print("Título: ${message.notification!.title}");
    print("Cuerpo: ${message.notification!.body}");
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  await MobileAds.instance.initialize();
  initializeDateFormatting('es');
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserSession(), // Aquí creamos la instancia global
      child: const EconoMuchikApp(), // Tu app ahora es un hijo
    ),
  );
}

class EconoMuchikApp extends StatelessWidget {
  const EconoMuchikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planifiko',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Roboto',
      ),

      locale: const Locale('es', 'ES'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('en', 'US'), // Inglés
        Locale('es', 'ES'), // Español estándar
        Locale('es', 'PE'), // Español Perú
      ],

      home: const LoadingScreen(),
      onGenerateRoute: (settings) {
        print('onGenerateRoute called with: ${settings.name}');
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (context) => const RegisterScreen());
          case '/terms':
            return MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen());
          case '/forgot-password':
            return MaterialPageRoute(builder: (context) => const ForgotPasswordScreen());
          case '/forgot-password-otp':
            final email = settings.arguments as String?;
            return MaterialPageRoute(builder: (context) => ForgotPasswordOtpScreen(email: email),);
          case '/reset-password':
            final email = settings.arguments as String?;
            if (email == null) {
              return MaterialPageRoute(builder: (context) => const Scaffold(body: Center(child: Text('Email no válido'))),);
            }
            return MaterialPageRoute(builder: (context) => ResetPasswordScreen(email: email),);
          case '/delete-account-otp':
            return MaterialPageRoute(builder: (context) => DeleteAccountOtpScreen());
          case '/settings':
            return MaterialPageRoute(builder: (context) => const SettingsScreen());
          case '/loading':
            return MaterialPageRoute(builder: (context) => const LoadingScreen());
          case '/dashboard':
            return MaterialPageRoute(builder: (context) => const DashboardScreen());
          case '/reports':
            return MaterialPageRoute(builder: (context) => const ReportsScreen());
          case '/categories':
            return MaterialPageRoute(builder: (context) => const CategoriesScreen());
          case '/edit-profile':
            return MaterialPageRoute(builder: (context) => const EditProfileScreen());
          case '/budgets':
            return MaterialPageRoute(builder: (context) => const BudgetsScreen());
          case '/assign-budget':
            return MaterialPageRoute(builder: (context) => const AssignBudgetScreen());
          case '/compromises':
            return MaterialPageRoute(builder: (context) => const CompromisesScreen());
          case '/compromises_create':
            return MaterialPageRoute(builder: (context) => const CompromisesCreateScreen());
          case '/compromises_detail':
            if (settings.arguments is String) {
              final String compromiseId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => CompromisesDetailScreen(compromiseId: compromiseId),
              );
            }
            return MaterialPageRoute(builder: (context) => const Text('Error: Ruta no válida'));
          case '/accounts':
            return MaterialPageRoute(builder: (context) => const AccountsScreen());
          case '/compromises_tiers':
            return MaterialPageRoute(builder: (context) => const TercerosScreen());
          case '/movements':
            return MaterialPageRoute(builder: (context) => const MovementsScreen());
          case '/notifications':
            return MaterialPageRoute(builder: (context) => const NotificationsScreen());
          default:
            return MaterialPageRoute(builder: (context) => const LoginScreen());
        }
      },
    );
  }
}