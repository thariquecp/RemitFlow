import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/theme/app_theme.dart';
import 'package:fintech_app/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:fintech_app/features/security/presentation/bloc/security_cubit.dart';
import 'package:fintech_app/features/auth/presentation/bloc/auth_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: theme.textTheme.headlineMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        children: [
          // Theme toggle
          _SettingsTile(
            icon: Icons.color_lens_rounded,
            title: 'App Theme',
            subtitle: 'Choose your preferred theme',
            trailing: BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) => DropdownButton<ThemeMode>(
                value: state.themeMode,
                underline: const SizedBox.shrink(),
                style: theme.textTheme.bodyMedium,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                ],
                onChanged: (mode) {
                  if (mode != null) {
                    context.read<ThemeCubit>().setThemeMode(mode);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),

          BlocBuilder<SecurityCubit, SecurityState>(
            builder: (context, state) {
              return Column(
                children: [
                  _SettingsTile(
                    icon: Icons.lock_rounded,
                    title: 'App Lock',
                    subtitle: 'Require PIN on app launch',
                    trailing: Switch(
                      value: state.isAppLockEnabled,
                      onChanged: (_) =>
                          context.read<SecurityCubit>().toggleAppLock(),
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  _SettingsTile(
                    icon: Icons.fingerprint_rounded,
                    title: 'Biometric Login',
                    subtitle: 'Use Face ID or fingerprint',
                    trailing: Switch(
                      value: state.isBiometricEnabled,
                      onChanged: state.isAppLockEnabled
                          ? (_) =>
                                context.read<SecurityCubit>().toggleBiometric()
                          : null, // Disable if App Lock is off
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppTheme.spacing12),

          // About section
          Text('About', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppTheme.spacing12),

          const _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'RemitFlow',
            subtitle: 'Version 1.0.0',
          ),
          const SizedBox(height: AppTheme.spacing12),

          // Logout Button
          ElevatedButton.icon(
            onPressed: () {
              context.read<AuthCubit>().logout();
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withValues(alpha: 0.1),
              foregroundColor: AppColors.error,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing32),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (trailing != null) trailing! else const SizedBox.shrink(),
        ],
      ),
    );
  }
}
