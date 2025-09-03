import 'package:flows/services/audio_player_service.dart';
import 'package:flows/views/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio_background/just_audio_background.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {  
  // const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  // if (env == 'dev') {
  //   await dotenv.load(fileName: '/Users/user/AndroidStudioProjects/Flows/.env');
  // }
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: "com.flows.app.audio", // Fixed: provide unique channel ID
    androidNotificationChannelName: "Audio playback",
    androidNotificationChannelDescription: "Background audio playback for Flows app", // Added description
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true, // Added notification badge
    androidNotificationClickStartsActivity: true, // Added click handling
    androidNotificationIcon: 'mipmap/ic_launcher', // Added app icon
  );

  // Initialize audio player service
  await AudioPlayerService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flows App',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          textTheme: GoogleFonts.rubikTextTheme(),
        ),
      home: SplashScreen()
    );
  }
}
