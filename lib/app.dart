import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            // BLoC-i będą odkomentowywane w miarę implementacji kolejnych modułów
            // BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
            // BlocProvider<PantryBloc>(create: (context) => PantryBloc()),
            // BlocProvider<ShoppingBloc>(create: (context) => ShoppingBloc()),
            // BlocProvider<MacrosBloc>(create: (context) => MacrosBloc()),
            // BlocProvider<SubscriptionBloc>(create: (context) => SubscriptionBloc()),
            BlocProvider<DummyBloc>(create: (context) => DummyBloc()),
          ],
          child: const _MaterialApp(),
        );
      },
    );
  }
}

class _MaterialApp extends StatelessWidget {
  const _MaterialApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VitaSense',
      debugShowCheckedModeBanner: false,

      // Router
      routerConfig: appRouter,

      // Motyw
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Lokalizacja
      locale: const Locale('pl', 'PL'),
      supportedLocales: const [
        Locale('pl', 'PL'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

// Tymczasowy DummyBloc zapewniający kompilację w fazie CORE
class DummyBloc extends Cubit<int> {
  DummyBloc() : super(0);
}
