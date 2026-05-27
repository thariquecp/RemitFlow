import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_app/core/security/secure_storage_service.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthCubit extends Cubit<AuthState> {
  static const String _sessionKey = 'user_session_token';
  final SecureStorageService _secureStorage;

  AuthCubit(this._secureStorage) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    try {
      final token = await _secureStorage.read(_sessionKey);
      if (token != null && token.isNotEmpty) {
        emit(Authenticated());
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    // Generate a mock token
    final mockToken = 'token_${DateTime.now().millisecondsSinceEpoch}';
    await _secureStorage.write(_sessionKey, mockToken);

    emit(Authenticated());
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await _secureStorage.delete(_sessionKey);
    emit(Unauthenticated());
  }
}
