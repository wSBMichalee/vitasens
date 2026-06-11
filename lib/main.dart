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
    defaultValue: 'https://jtggjdiaziggnpnfdcrv.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp0Z2dqZGlhemlnZ25wbmZkY3J2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA0NTQ4MzIsImV4cCI6MjA5NjAzMDgzMn0.AAcLu3sb7TmJ7ol1YbVW-NlxUDuFNEup9L4VpxbK7D8',
  );

  // Inicjalizacja Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Klucz RevenueCat (konfigurowalny przez --dart-define)
  const revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: 'sb_publishable_zTDgWgJw1Npfl2KqBkuK4w_qFToVItm',
  );

  // Konfiguracja RevenueCat (opóźniona by nie blokować cold startu)
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (revenueCatApiKey != 'placeholder-rc-key') {
      await Purchases.configure(PurchasesConfiguration(revenueCatApiKey));
    }
  });

  runApp(const MyApp());
}
