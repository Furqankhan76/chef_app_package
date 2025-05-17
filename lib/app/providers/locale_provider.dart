import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to manage the current locale state
final localeProvider = StateProvider<Locale>((ref) {
  // Default locale is Arabic as per new requirements
  return const Locale('ar');
});

