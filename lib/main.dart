import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'screens/login_screen.dart';
import 'screens/team_dashboard_screen.dart';
import 'screens/team_notifications_screen.dart';
import 'screens/team_complaint_details_screen.dart';
import 'screens/team_announcement_screen.dart';
import 'screens/announcement_home_screen.dart';
import 'screens/create_announcement_screen.dart';
import 'team-mritteka/complaint_electrician_mritteka.dart';
import 'screens/announcement_screen.dart';
import 'screens/guest_complaint_screen.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Initialize Local Notifications
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FixItNow',
      theme: ThemeData(primarySwatch: Colors.pink, useMaterial3: false),
      home: const LoginScreen(),
      routes: {
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
            collection: args['collection'], // ✅ this is the fix
          );
        },
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
        '/postedAnnouncements': (context) => const AnnouncementScreen(),
      },
    );
  }
}
