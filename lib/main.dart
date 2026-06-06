import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'providers/user_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/landlord/landlord_dashboard.dart';
import 'screens/tenant/tenant_dashboard.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
    return MaterialApp(
      title: 'EasyRent PH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E88E5),
          secondary: const Color(0xFF1E88E5),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
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

    // Initial Splash state
    if (!userProvider.isInitialized) {
      return const SplashScreen();
    }

    // After initialization, if we have a user model, go to their dashboard
    if (userProvider.user != null) {
      if (userProvider.user!.role == 'Landlord') {
        return const LandlordDashboard();
      } else {
        return const TenantDashboard();
      }
    }

    // If initialized but no user profile found despite being authenticated in Firebase
    if (FirebaseAuth.instance.currentUser != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Unable to load your profile.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => AuthService().signOut(),
                  child: const Text("Sign Out and Try Again"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If not logged in, show the entry flow starting from Onboarding
    // Note: In a production app, you might use SharedPreferences to check if 
    // onboarding was already seen. For now, we follow the user's flow.
    return const SplashScreen();
  }
}
