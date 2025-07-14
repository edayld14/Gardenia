import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/notification_service.dart';

// Ekranlar
import 'screens/intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/chat_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Arka planda gelen mesajları yönetmek için burası kullanılabilir
  debugPrint("Arka planda mesaj alındı: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env dosyasını yükle
  await dotenv.load(fileName: "assets/.env");

  // Firebase'i başlat
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Bildirim sistemi başlat
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.init(); // bildirim altyapısı

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showIntro = true;

  void _handleIntroEnd() {
    setState(() {
      _showIntro = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeFCMToken(); // Uygulama açıldığında FCM tokeni al
  }

  Future<void> _initializeFCMToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint("FCM Token: $token"); // Admin veya backend'e gönderilebilir
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gardenia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      routes: {'/chat': (context) => const ChatScreen()},
      home:
          _showIntro
              ? IntroScreen(onIntroEnd: _handleIntroEnd)
              : StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasData && snapshot.data!.emailVerified) {
                    return const MainScreen();
                  }

                  return const LoginScreen();
                },
              ),
    );
  }
}
