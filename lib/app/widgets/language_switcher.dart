import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chef_app/app/providers/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: AppLocalizations.of(context)?.language ?? 'Language',
      onSelected: (Locale locale) {
        localeNotifier.state = locale;
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
        PopupMenuItem<Locale>(
          value: const Locale('en'),
          child: Row(
            children: [
              if (currentLocale.languageCode == 'en')
                const Icon(Icons.check, size: 18),
              const SizedBox(width: 8),
              const Text('English'),
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('es'),
          child: Row(
            children: [
              if (currentLocale.languageCode == 'es')
                const Icon(Icons.check, size: 18),
              const SizedBox(width: 8),
              const Text('Español'),
            ],
          ),
        ),
      ],
    );
  }
}
