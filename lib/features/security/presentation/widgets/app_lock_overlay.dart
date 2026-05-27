import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/theme/app_theme.dart';
import 'package:fintech_app/features/security/presentation/bloc/security_cubit.dart';

class AppLockOverlay extends StatefulWidget {
  final Widget child;

  const AppLockOverlay({super.key, required this.child});

  @override
  State<AppLockOverlay> createState() => _AppLockOverlayState();
}

class _AppLockOverlayState extends State<AppLockOverlay>
    with WidgetsBindingObserver {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Trigger auth on first load if locked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometricFirst();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tryBiometricFirst();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Lock the app when it goes to background
      final cubit = context.read<SecurityCubit>();
      if (cubit.state.isAppLockEnabled) {
        cubit.lockApp();
      }
    }
  }

  Future<void> _tryBiometricFirst() async {
    final cubit = context.read<SecurityCubit>();
    if (!cubit.state.isAppLockEnabled ||
        cubit.state.isUnlocked ||
        _isAuthenticating) {
      return;
    }

    // Only try biometric if it's enabled
    if (cubit.state.isBiometricEnabled) {
      await _authenticateWithBiometric();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    final cubit = context.read<SecurityCubit>();
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (canAuthenticate) {
        final bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to access your account',
          options: const AuthenticationOptions(
            biometricOnly: true,
            useErrorDialogs: true,
            stickyAuth: true,
          ),
        );

        if (didAuthenticate && mounted) {
          cubit.setUnlocked(true);
        }
      }
    } on PlatformException catch (_) {
      // Biometric failed or cancelled — user can use PIN fallback
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SecurityCubit, SecurityState>(
      builder: (context, state) {
        return Stack(
          children: [
            widget.child,

            if (state.isAppLockEnabled && !state.isUnlocked)
              Positioned.fill(
                child: _LockScreen(
                  isAuthenticating: _isAuthenticating,
                  isBiometricEnabled: state.isBiometricEnabled,
                  hasPinSet: state.hasPinSet,
                  onBiometricTap: _authenticateWithBiometric,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LockScreen extends StatefulWidget {
  final bool isAuthenticating;
  final bool isBiometricEnabled;
  final bool hasPinSet;
  final VoidCallback onBiometricTap;

  const _LockScreen({
    required this.isAuthenticating,
    required this.isBiometricEnabled,
    required this.hasPinSet,
    required this.onBiometricTap,
  });

  @override
  State<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<_LockScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  String _newPin = '';
  bool _isSettingPin = false;
  bool _isConfirmingPin = false;
  bool _showError = false;
  String _errorMessage = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _isSettingPin = !widget.hasPinSet;

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumberTap(String number) {
    if (_enteredPin.length >= 4) return;

    setState(() {
      _enteredPin += number;
      _showError = false;
    });

    if (_enteredPin.length == 4) {
      _handlePinComplete();
    }
  }

  void _onDeleteTap() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _showError = false;
    });
  }

  void _handlePinComplete() {
    final cubit = context.read<SecurityCubit>();

    if (_isSettingPin && !_isConfirmingPin) {
      // First PIN entry — save and ask to confirm
      setState(() {
        _newPin = _enteredPin;
        _enteredPin = '';
        _isConfirmingPin = true;
      });
      return;
    }

    if (_isSettingPin && _isConfirmingPin) {
      // Confirming new PIN
      if (_enteredPin == _newPin) {
        cubit.setPin(_enteredPin);
        cubit.setUnlocked(true);
      } else {
        _triggerError('PINs do not match. Try again.');
        setState(() {
          _isConfirmingPin = false;
          _newPin = '';
        });
      }
      return;
    }

    // Verifying existing PIN
    if (cubit.verifyPin(_enteredPin)) {
      cubit.setUnlocked(true);
    } else {
      _triggerError('Incorrect PIN. Try again.');
    }
  }

  void _triggerError(String message) {
    setState(() {
      _showError = true;
      _errorMessage = message;
      _enteredPin = '';
    });
    _shakeController.forward(from: 0);
    HapticFeedback.heavyImpact();
  }

  String get _title {
    if (_isSettingPin && _isConfirmingPin) return 'Confirm Your PIN';
    if (_isSettingPin) return 'Set a 4-Digit PIN';
    return 'Enter Your PIN';
  }

  String get _subtitle {
    if (_isSettingPin && _isConfirmingPin) {
      return 'Re-enter your PIN to confirm';
    }
    if (_isSettingPin) return 'Create a PIN to secure your app';
    return 'Unlock to access your account';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Lock icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Title
            Text(
              _title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              _subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),

            const SizedBox(height: AppTheme.spacing32),

            // PIN dots
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                final offset =
                    _shakeAnimation.value *
                    10 *
                    ((_shakeController.value * 6).remainder(2) < 1 ? 1 : -1);
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _enteredPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: isFilled ? 20 : 16,
                    height: isFilled ? 20 : 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _showError
                          ? AppColors.error
                          : isFilled
                              ? AppColors.primary
                              : Colors.transparent,
                      border: Border.all(
                        color: _showError
                            ? AppColors.error
                            : isFilled
                                ? AppColors.primary
                                : (isDark ? Colors.white30 : Colors.black26),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Error message
            const SizedBox(height: AppTheme.spacing16),
            AnimatedOpacity(
              opacity: _showError ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                _errorMessage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Spacer(),

            // Number pad
            _NumberPad(
              onNumberTap: _onNumberTap,
              onDeleteTap: _onDeleteTap,
              onBiometricTap:
                  (!_isSettingPin && widget.isBiometricEnabled)
                      ? widget.onBiometricTap
                      : null,
              isAuthenticating: widget.isAuthenticating,
            ),

            const SizedBox(height: AppTheme.spacing32),
          ],
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  final void Function(String) onNumberTap;
  final VoidCallback onDeleteTap;
  final VoidCallback? onBiometricTap;
  final bool isAuthenticating;

  const _NumberPad({
    required this.onNumberTap,
    required this.onDeleteTap,
    this.onBiometricTap,
    this.isAuthenticating = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['bio', '0', 'del'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: buttons.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key == 'bio') {
                  if (onBiometricTap != null) {
                    return _PadButton(
                      onTap: isAuthenticating ? null : onBiometricTap,
                      child: isAuthenticating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(
                              Icons.fingerprint_rounded,
                              size: 28,
                              color: AppColors.primary,
                            ),
                    );
                  }
                  return const SizedBox(width: 72, height: 72);
                }

                if (key == 'del') {
                  return _PadButton(
                    onTap: onDeleteTap,
                    child: const Icon(Icons.backspace_outlined, size: 24),
                  );
                }

                return _PadButton(
                  onTap: () => onNumberTap(key),
                  child: Text(
                    key,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PadButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _PadButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
