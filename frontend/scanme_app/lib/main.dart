import 'package:flutter/material.dart';
import 'package:scanme_app/router/app_router.dart';
import 'package:scanme_app/theme/app_theme.dart';

import 'package:scanme_app/services/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager().init();
  runApp(const ScanMeApp());
}

class ScanMeApp extends StatelessWidget {
  const ScanMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ScanMe',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
