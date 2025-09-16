import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'theme_controller.dart';

import 'screens/login_screen.dart';
import 'screens/team_dashboard_screen.dart';
import 'screens/team_notifications_screen.dart';
import 'screens/team_complaint_details_screen.dart';
import 'screens/team_announcement_screen.dart';
import 'screens/announcement_home_screen.dart';
import 'screens/create_announcement_screen.dart';
<<<<<<< HEAD
import 'team-mritteka/complaint_electrician_mritteka.dart';
import 'screens/announcement_screen.dart';
=======
import 'screens/announcement_screen.dart'; // CR view
>>>>>>> 382cbbf (Final Update)
import 'screens/guest_complaint_screen.dart';
import 'screens/team_complaint_stats_screen.dart';
import 'screens/admin_announcement_screen.dart'; // Admin view


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FixItNow',
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'Sans',
        scaffoldBackgroundColor: const Color(0xFFF8F4F0),

        // ⬇️ UPDATED: global AppBar height = 120
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8B5E3C),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          toolbarHeight: 135, // <- makes all AppBars 120 tall by default
        ),

        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF8B5E3C),
          secondary: const Color(0xFF8B5E3C),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5E3C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF8B5E3C), width: 2),
          ),
        ),
      ),

      initialRoute: '/',

      // ⬇️ ROUTES — each role has its own route
      routes: {
        '/': (context) => const LoginScreen(),

        '/teamDashboard': (context) {
          final teamName = ModalRoute.of(context)!.settings.arguments as String;
          return TeamDashboardScreen(teamName: teamName);

        },

        '/guestComplaint': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return GuestComplaintScreen(
            guestUid: args['guestUid']!,
            guestPhone: args['guestPhone']!,
          );
        },

        '/teamNotifications': (context) {
          final teamName = ModalRoute.of(context)!.settings.arguments as String;
          return TeamNotificationsScreen(teamName: teamName);
        },

        '/teamComplaintDetails': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return TeamComplaintDetailsScreen(
            data: args['data'],
            docId: args['docId'],
            collection: args['collection'],
          );
        },

        // TEAM announcements (needs team name)
        '/teamAnnouncements': (context) {
          final teamName = ModalRoute.of(context)!.settings.arguments as String;
          return TeamAnnouncementScreen(teamName: teamName);
        },

        '/announcementHome': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return AnnouncementHomeScreen(
            userType: args['userType'],
            teamType: args['teamType'],
          );
        },

        '/createAnnouncement': (context) => const CreateAnnouncementScreen(),

        // CR announcements (view-only)
        '/crAnnouncements': (context) =>
            const AnnouncementScreen(userType: 'cr'),

        // ADMIN announcements (All + Mark Expired)
        '/adminAnnouncements': (context) => const AdminAnnouncementScreen(),

        '/teamComplaintStats': (context) {
          final teamName = ModalRoute.of(context)!.settings.arguments as String;
          return TeamComplaintStatsScreen(teamName: teamName);
        },
      },
    );
  }
}

/// Helper to route users to the correct announcements screen
void openAnnouncements(BuildContext context, String role, {String? teamName}) {
  switch (role.toLowerCase()) {
    case 'admin':
      Navigator.pushNamed(context, '/adminAnnouncements');
      break;
    case 'team':
      Navigator.pushNamed(context, '/teamAnnouncements', arguments: teamName);
      break;
    default: // 'cr'
      Navigator.pushNamed(context, '/crAnnouncements');
  }
}
