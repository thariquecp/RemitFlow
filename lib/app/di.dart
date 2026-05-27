import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fintech_app/core/network/dio_client.dart';
import 'package:fintech_app/core/network/network_info.dart';
import 'package:fintech_app/core/security/secure_storage_service.dart';
import 'package:fintech_app/features/exchange/data/datasources/exchange_local_source.dart';
import 'package:fintech_app/features/exchange/data/datasources/exchange_remote_source.dart';
import 'package:fintech_app/features/exchange/data/repositories/exchange_repository_impl.dart';
import 'package:fintech_app/features/exchange/domain/repositories/exchange_repository.dart';
import 'package:fintech_app/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:fintech_app/features/beneficiary/data/datasources/beneficiary_local_source.dart';
import 'package:fintech_app/features/beneficiary/presentation/bloc/beneficiary_bloc.dart';
import 'package:fintech_app/features/transactions/data/datasources/transaction_local_source.dart';
import 'package:fintech_app/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:fintech_app/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:fintech_app/features/security/presentation/bloc/security_cubit.dart';
import 'package:fintech_app/features/auth/presentation/bloc/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());

  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  // Exchange Feature
  final exchangeLocalSource = ExchangeLocalSource();
  await exchangeLocalSource.init();
  sl.registerSingleton<ExchangeLocalSource>(exchangeLocalSource);

  sl.registerLazySingleton<ExchangeRemoteSource>(
    () => ExchangeRemoteSource(sl<DioClient>().dio),
  );

  sl.registerLazySingleton<ExchangeRepository>(
    () => ExchangeRepositoryImpl(
      remoteSource: sl<ExchangeRemoteSource>(),
      localSource: sl<ExchangeLocalSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerFactory<ExchangeBloc>(
    () => ExchangeBloc(repository: sl<ExchangeRepository>()),
  );

  // Beneficiary Feature
  final beneficiaryLocalSource = BeneficiaryLocalSource();
  await beneficiaryLocalSource.init(sl<SecureStorageService>());
  sl.registerSingleton<BeneficiaryLocalSource>(beneficiaryLocalSource);

  sl.registerFactory<BeneficiaryBloc>(
    () => BeneficiaryBloc(localSource: sl<BeneficiaryLocalSource>()),
  );

  // Transaction Feature
  final transactionLocalSource = TransactionLocalSource();
  await transactionLocalSource.init();
  sl.registerSingleton<TransactionLocalSource>(transactionLocalSource);

  sl.registerFactory<TransactionBloc>(
    () => TransactionBloc(localSource: sl<TransactionLocalSource>()),
  );

  // Settings & Security
  sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl<SharedPreferences>()));

  sl.registerLazySingleton<SecurityCubit>(
    () => SecurityCubit(sl<SharedPreferences>()),
  );

  sl.registerFactory<AuthCubit>(() => AuthCubit(sl<SecureStorageService>()));
}
