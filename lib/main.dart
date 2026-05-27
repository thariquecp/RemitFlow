import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:fintech_app/app/di.dart';
import 'package:fintech_app/core/theme/app_theme.dart';
import 'package:fintech_app/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:fintech_app/features/exchange/presentation/bloc/exchange_event.dart';
import 'package:fintech_app/features/beneficiary/presentation/bloc/beneficiary_bloc.dart';
import 'package:fintech_app/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:fintech_app/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:fintech_app/features/security/presentation/bloc/security_cubit.dart';
import 'package:fintech_app/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:fintech_app/features/security/presentation/widgets/app_lock_overlay.dart';
import 'package:fintech_app/features/auth/presentation/pages/login_page.dart';
import 'package:fintech_app/navigation/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for consistent UX
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register all dependencies
  await initDependencies();

  runApp(const RemitFlowApp());
}

class RemitFlowApp extends StatelessWidget {
  const RemitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        BlocProvider<SecurityCubit>.value(value: sl<SecurityCubit>()),
        BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider<ExchangeBloc>(
          create: (_) => sl<ExchangeBloc>()..add(const ExchangeStarted()),
        ),
        BlocProvider<BeneficiaryBloc>(
          create: (_) =>
              sl<BeneficiaryBloc>()..add(const BeneficiaryLoadRequested()),
        ),
        BlocProvider<TransactionBloc>(
          create: (_) =>
              sl<TransactionBloc>()..add(const TransactionLoadRequested()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'RemitFlow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            home: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                if (authState is AuthLoading || authState is AuthInitial) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (authState is Authenticated) {
                  return const AppLockOverlay(child: DashboardScreen());
                }
                return const LoginPage();
              },
            ),
          );
        },
      ),
    );
  }
}
