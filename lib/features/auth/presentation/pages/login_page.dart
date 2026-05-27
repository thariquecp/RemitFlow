import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/theme/app_theme.dart';
import 'package:fintech_app/features/auth/presentation/bloc/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;
      context.read<AuthCubit>().login(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            _isLoading = state is AuthLoading;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacing24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _logo,
                      const SizedBox(height: AppTheme.spacing32),
                      _welcomeText,
                      const SizedBox(height: AppTheme.spacing48),
                      _emailTextField,
                      const SizedBox(height: AppTheme.spacing20),
                      _passwordTextField,
                      const SizedBox(height: AppTheme.spacing12),
                      _forgotPasswordButton,
                      const SizedBox(height: AppTheme.spacing32),
                      _loginButton,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget get _logo {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.currency_exchange_rounded,
          size: 40,
          color: Colors.white,
        ),
      ),
    ).animate().scale(
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }

  Widget get _welcomeText {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'Welcome Back',
          style: theme.textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          'Sign in to manage your remittances',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget get _emailTextField {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enabled: !_isLoading,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        return null;
      },
    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.05, end: 0);
  }

  Widget get _passwordTextField {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _onLogin(),
      enabled: !_isLoading,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.05, end: 0);
  }

  Widget get _forgotPasswordButton {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isLoading ? null : () {},
        child: const Text('Forgot Password?'),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget get _loginButton {
    return ElevatedButton(
      onPressed: _isLoading ? null : _onLogin,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(
              'Login',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.95, 0.95));
  }
}
