import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:vitasense/app.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('${bloc.runtimeType} $error');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja Bloc Observer
  Bloc.observer = const AppBlocObserver();

  // Dane Supabase (konfigurowalne przez --dart-define lub z wartościami domyślnymi)
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-anon-key',
  );

  // Inicjalizacja Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Klucz RevenueCat (konfigurowalny przez --dart-define)
  const revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: 'placeholder-rc-key',
  );

  // Konfiguracja RevenueCat (tylko jeśli podano poprawny klucz)
  if (revenueCatApiKey != 'placeholder-rc-key') {
    await Purchases.configure(PurchasesConfiguration(revenueCatApiKey));
  }

  runApp(const MyApp());
}
