import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'providers/user_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/landlord/landlord_dashboard.dart';
import 'screens/landlord/location_setup_screen.dart';
import 'screens/tenant/tenant_dashboard.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';

String? _firebaseInitError;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (_) {
      if (kIsWeb) {
        debugPrint('Firebase initialization failed on web. Using mock mode.');
      } else {
        await Firebase.initializeApp();
      }
    }
  } catch (e, st) {
    if (!kIsWeb) {
      _firebaseInitError = '$e\n$st';
    }
    debugPrint('Firebase.initializeApp() failed: $e');
  }

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('An error occurred', style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(details.exceptionAsString(), style: const TextStyle(color: Colors.black87)),
              const SizedBox(height: 12),
              Text(details.stack?.toString() ?? '', style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const EasyRentApp(),
    ),
  );
}

class EasyRentApp extends StatelessWidget {
  const EasyRentApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (_firebaseInitError != null) {
      return MaterialApp(
        title: 'EasyRent PH - Firebase Error',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(title: const Text('Firebase Initialization Error')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Firebase failed to initialize.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('This commonly happens on web when Firebase options are not configured.'),
                  const SizedBox(height: 12),
                  const Text('To fix:'),
                  const SizedBox(height: 6),
                  const Text('• Run `flutterfire configure` to generate `firebase_options.dart` and call Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)\n• Or add Firebase SDK & config to your web/index.html'),
                  const SizedBox(height: 12),
                  const Text('Captured error:' , style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  SelectableText(_firebaseInitError ?? ''),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'EasyRent PH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E88E5),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        }),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (!userProvider.isInitialized) {
      return const SplashScreen();
    }

    // Safely check for Firebase user
    User? firebaseUser;
    try {
      firebaseUser = FirebaseAuth.instance.currentUser;
    } catch (e) {
      debugPrint("AuthWrapper: Firebase not initialized or accessible: $e");
    }

    final user = userProvider.user;

    if (user != null) {
      if (user.role == 'Landlord') {
        if (user.location == null) {
          return const LocationSetupScreen();
        }
        return const LandlordDashboard();
      } else {
        return const TenantDashboard();
      }
    }

    if (firebaseUser != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Profile not found. Please try again."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => AuthService().signOut(),
                child: const Text("Sign Out"),
              ),
            ],
          ),
        ),
      );
    }

    return const OnboardingScreen();
  }
}
