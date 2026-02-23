import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'responder/config/app_theme.dart';
import 'responder/constants/app_constants.dart';
import 'responder/constants/app_strings.dart';
import 'responder/screens/shell/main_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inject the Mapbox public access token (supplied at build/run time via
  // --dart-define-from-file=.env — copy .env.example → .env and fill in
  // your token; never commit the .env file).
  if (AppConstants.mapboxAccessToken.isNotEmpty) {
    MapboxOptions.setAccessToken(AppConstants.mapboxAccessToken);
  }

  runApp(const ResQLinkApp());
}

/// Root widget of the ResQLink user application.
class ResQLinkApp extends StatelessWidget {
  const ResQLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppTheme.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _PlatformGuard(),
    );
  }
}

/// Guards the entire app so it only runs on iOS and Android.
/// On any other platform (web, desktop) an informational screen is shown.
class _PlatformGuard extends StatelessWidget {
  const _PlatformGuard();

  bool get _isSupportedPlatform {
    // kIsWeb must be checked first – dart:io Platform throws on web.
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  @override
  Widget build(BuildContext context) {
    if (_isSupportedPlatform) {
      return const MainShellScreen();
    }
    return const _UnsupportedPlatformScreen();
  }
}

/// Shown when the app is launched on an unsupported platform (web / desktop).
class _UnsupportedPlatformScreen extends StatelessWidget {
  const _UnsupportedPlatformScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.smartphone, size: 72, color: Colors.grey),
              const SizedBox(height: 24),
              Text(
                AppStrings.unsupportedPlatformTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.unsupportedPlatformMessage,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
