import 'package:chef_app/app/providers/locale_provider.dart';
import 'package:chef_app/app/router/app_router.dart';
import 'package:chef_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import generated localizations

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      routerConfig: router,
      // title: AppLocalizations.of(context)?.appTitle ?? "Chef App", // Cannot access context here directly, set in specific screens
      theme: AppTheme.lightTheme, // Apply the theme with Arabic fonts
      // darkTheme: AppTheme.darkTheme, // Add if dark theme is implemented
      // themeMode: ThemeMode.system, // Or based on user preference
      localizationsDelegates: const [
        AppLocalizations.delegate, // Add generated delegate
        GlobalMaterialLocalizations.delegate, // Handles Material RTL
        GlobalWidgetsLocalizations.delegate, // Handles general widget RTL
        GlobalCupertinoLocalizations.delegate, // Handles Cupertino RTL
      ],
      supportedLocales: AppLocalizations.supportedLocales, // Use generated locales
      locale: locale, // Set locale based on provider (defaulting to 'ar')
      debugShowCheckedModeBanner: false,
    );
  }
}

