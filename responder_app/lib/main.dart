// main.dart
// LB-Sentry | App Entry Point
// Opens directly to DashboardScreen — No auth, no login

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/config/app_theme.dart';
import 'features/controllers/responder_controller.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const LBSentryApp());
}

class LBSentryApp extends StatelessWidget {
  const LBSentryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Future: Add FirebaseAuthProvider, FirestoreProvider etc. here
        ChangeNotifierProvider(create: (_) => ResponderController()),
      ],
      child: MaterialApp(
        title: 'LB-Sentry',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: AppRoutes.dashboard,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
