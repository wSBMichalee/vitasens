import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_theme.dart';
import 'package:vitasense/features/auth/bloc/auth_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_event.dart';
import 'package:vitasense/features/auth/data/auth_repository.dart';
import 'package:vitasense/features/detect/bloc/detect_bloc.dart';
import 'package:vitasense/features/detect/data/detect_repository.dart';
import 'package:vitasense/features/macros/bloc/macros_bloc.dart';
import 'package:vitasense/features/macros/data/macros_repository.dart';
import 'package:vitasense/features/pantry/bloc/pantry_bloc.dart';
import 'package:vitasense/features/pantry/data/pantry_repository.dart';
import 'package:vitasense/features/recipes/bloc/recipes_bloc.dart';
import 'package:vitasense/features/recipes/data/recipes_repository.dart';
import 'package:vitasense/features/shopping/bloc/shopping_bloc.dart';
import 'package:vitasense/features/shopping/data/shopping_repository.dart';
import 'package:vitasense/features/family/bloc/family_bloc.dart';
import 'package:vitasense/features/family/data/family_repository.dart';
import 'package:vitasense/features/browse/bloc/browse_bloc.dart';
import 'package:vitasense/features/browse/data/browse_repository.dart';
import 'package:vitasense/features/extract/bloc/extract_bloc.dart';
import 'package:vitasense/features/extract/data/extract_repository.dart';
import 'package:vitasense/features/subscription/bloc/subscription_bloc.dart';
import 'package:vitasense/features/subscription/data/subscription_repository.dart';
import 'package:vitasense/features/voice/bloc/voice_bloc.dart';
import 'package:vitasense/features/voice/data/voice_repository.dart';

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
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(
                authRepository: AuthRepository(),
              )..add(const AppStarted()),
            ),
            BlocProvider<PantryBloc>(
              create: (context) => PantryBloc(
                repository: PantryRepository(),
              ),
            ),
            BlocProvider<RecipesBloc>(
              create: (context) => RecipesBloc(
                repository: RecipesRepository(),
              ),
            ),
            BlocProvider<MacrosBloc>(
              create: (context) => MacrosBloc(
                repository: MacrosRepository(),
              ),
            ),
            BlocProvider<DetectBloc>(
              create: (context) => DetectBloc(
                repository: DetectRepository(),
              ),
            ),
            BlocProvider<ShoppingBloc>(
              create: (context) => ShoppingBloc(
                repository: ShoppingRepository(),
              ),
            ),
            BlocProvider<FamilyBloc>(
              create: (context) => FamilyBloc(
                repository: FamilyRepository(),
              ),
            ),
            BlocProvider<BrowseBloc>(
              create: (context) => BrowseBloc(
                repository: BrowseRepository(),
              ),
            ),
            BlocProvider<ExtractBloc>(
              create: (context) => ExtractBloc(
                repository: ExtractRepository(),
              ),
            ),
            BlocProvider<SubscriptionBloc>(
              create: (context) => SubscriptionBloc(
                repository: SubscriptionRepository(),
              ),
            ),
            BlocProvider<VoiceBloc>(
              create: (context) => VoiceBloc(
                repository: VoiceRepository(),
              ),
            ),
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
