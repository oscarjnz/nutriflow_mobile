import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class NutriFlowApp extends StatelessWidget {
  const NutriFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NutriFlow',
      debugShowCheckedModeBanner: false,
      theme: NutriFlowTheme.light(),
      darkTheme: NutriFlowTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
