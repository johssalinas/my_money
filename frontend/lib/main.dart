import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_money/core/api/api_service.dart';
import 'package:my_money/features/auth/bloc/auth_bloc.dart';
import 'package:my_money/features/auth/services/auth_service.dart';
import 'package:my_money/features/auth/views/auth_screen.dart';
import 'package:my_money/features/home/views/home_screen.dart';
import 'package:my_money/shared/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_money/features/finances/bloc/finances_bloc.dart';
import 'package:my_money/features/finances/services/finances_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración de la orientación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final apiService = ApiService();
  final authService = AuthService(apiService);
  final financesService = FinancesService(apiService);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authService: authService)
            ..add(AuthCheckStatusEvent()),
        ),
        BlocProvider<FinancesBloc>(
          create: (context) => FinancesBloc(financesService: financesService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Crear instancias de servicios
    final apiService = ApiService();
    final authService = AuthService(apiService);
    final financesService = FinancesService(apiService);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authService: authService)
            ..add(AuthCheckStatusEvent()),
        ),
        BlocProvider<FinancesBloc>(
          create: (context) => FinancesBloc(financesService: financesService),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            navigatorKey.currentState?.pushReplacementNamed('/dashboard');
          }
        },
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'My Money',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
          locale: const Locale('es', 'ES'),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthenticatedState) {
                return HomeScreen(user: state.user);
              } else {
                return const AuthScreen();
              }
            },
          ),
          routes: {
            '/dashboard':
                (context) => HomeScreen(
                  user:
                      (context.read<AuthBloc>().state as AuthenticatedState)
                          .user,
                ),
            '/login': (context) => AuthScreen(),
          },
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'My Money',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
