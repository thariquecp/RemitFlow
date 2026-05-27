import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityState extends Equatable {
  final bool isAppLockEnabled;
  final bool isBiometricEnabled;
  final bool isUnlocked;
  final bool hasPinSet;

  const SecurityState({
    this.isAppLockEnabled = false,
    this.isBiometricEnabled = false,
    this.isUnlocked = false,
    this.hasPinSet = false,
  });

  SecurityState copyWith({
    bool? isAppLockEnabled,
    bool? isBiometricEnabled,
    bool? isUnlocked,
    bool? hasPinSet,
  }) {
    return SecurityState(
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      hasPinSet: hasPinSet ?? this.hasPinSet,
    );
  }

  @override
  List<Object> get props =>
      [isAppLockEnabled, isBiometricEnabled, isUnlocked, hasPinSet];
}

class SecurityCubit extends Cubit<SecurityState> {
  static const _appLockKey = 'app_lock_enabled';
  static const _biometricKey = 'biometric_enabled';
  static const _pinKey = 'app_lock_pin';
  final SharedPreferences _prefs;

  SecurityCubit(this._prefs) : super(const SecurityState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final isAppLockEnabled = _prefs.getBool(_appLockKey) ?? false;
    final isBiometricEnabled = _prefs.getBool(_biometricKey) ?? false;
    final savedPin = _prefs.getString(_pinKey);
    final hasPinSet = savedPin != null && savedPin.isNotEmpty;

    emit(
      state.copyWith(
        isAppLockEnabled: isAppLockEnabled,
        isBiometricEnabled: isBiometricEnabled,
        hasPinSet: hasPinSet,
        isUnlocked:
            !isAppLockEnabled, // If lock is disabled, it's already unlocked
      ),
    );
  }

  Future<void> toggleAppLock() async {
    final newValue = !state.isAppLockEnabled;
    await _prefs.setBool(_appLockKey, newValue);

    // If disabling app lock, also disable biometrics and clear PIN
    if (!newValue) {
      await _prefs.setBool(_biometricKey, false);
      await _prefs.remove(_pinKey);
      emit(
        state.copyWith(
          isAppLockEnabled: newValue,
          isBiometricEnabled: false,
          hasPinSet: false,
          isUnlocked: true,
        ),
      );
    } else {
      emit(state.copyWith(isAppLockEnabled: newValue, isUnlocked: true));
    }
  }

  Future<void> toggleBiometric() async {
    final newValue = !state.isBiometricEnabled;
    await _prefs.setBool(_biometricKey, newValue);

    // Enabling biometrics requires app lock to be enabled
    if (newValue && !state.isAppLockEnabled) {
      await _prefs.setBool(_appLockKey, true);
      emit(
        state.copyWith(isBiometricEnabled: newValue, isAppLockEnabled: true),
      );
    } else {
      emit(state.copyWith(isBiometricEnabled: newValue));
    }
  }

  Future<bool> setPin(String pin) async {
    await _prefs.setString(_pinKey, pin);
    emit(state.copyWith(hasPinSet: true));
    return true;
  }

  bool verifyPin(String pin) {
    final savedPin = _prefs.getString(_pinKey);
    return savedPin != null && savedPin == pin;
  }

  Future<void> clearPin() async {
    await _prefs.remove(_pinKey);
    emit(state.copyWith(hasPinSet: false));
  }

  void setUnlocked(bool unlocked) {
    emit(state.copyWith(isUnlocked: unlocked));
  }

  void lockApp() {
    if (state.isAppLockEnabled) {
      emit(state.copyWith(isUnlocked: false));
    }
  }
}
