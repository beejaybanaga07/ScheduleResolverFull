import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/schedule_provider.dart';
import 'services/ai_schedule_service.dart';
import 'screens/dashboard_screens.dart';

void main() {
  runApp(const ScheduleResolverApp());
}

class ScheduleResolverApp extends StatelessWidget {
  const ScheduleResolverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => AiScheduleService()),
      ],
      child: MaterialApp(
        title: 'Schedule Resolver',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF2D78),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0D0D0D),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0D0D0D),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF2D78),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: const Color(0xFF1A1A1A),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFFF2D78),
            foregroundColor: Colors.white,
          ),
        ),
        home: const DashboardScreens(),
      ),
    );
  }
}