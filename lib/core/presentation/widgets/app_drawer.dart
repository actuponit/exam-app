import 'dart:ui';

import 'package:exam_app/core/di/injection.dart';
import 'package:exam_app/features/auth/data/repositories/auth_repository.dart';
import 'package:exam_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:exam_app/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:exam_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Drawer(
      child: Container(
        color: colorScheme.surface,
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildNavigationItems(context),
            const Spacer(),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      return Container(
        padding:
            const EdgeInsets.only(top: 50, bottom: 20, left: 10, right: 10),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(cardRadius),
            bottomRight: Radius.circular(cardRadius),
          ),
        ),
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.onPrimary, width: 2),
                    color: colorScheme.onPrimary.withOpacity(0.2),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  state.firstName ?? 'Guest User',
                  style: titleStyle.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.email ?? 'guest@example.com',
                  style: bodyStyle.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  Widget _buildNavigationItems(BuildContext context) {
    return Column(
      children: [
        _DrawerListTile(
          icon: Icons.person_outline,
          title: 'Profile',
          onTap: () => context.push('/profile'),
        ),
        _DrawerListTile(
          icon: Icons.school_outlined,
          title: 'Practice Exams',
          onTap: () => context.push('/subjects'),
        ),
        _DrawerListTile(
          icon: Icons.help_outline,
          title: 'FAQ',
          onTap: () => context.push('/faq'),
        ),
        _DrawerListTile(
          icon: Icons.contact_support_outlined,
          title: 'Contact Us',
          onTap: () => context.push('/contact'),
        ),
        _DrawerListTile(
          icon: Icons.info_outline,
          title: 'About Us',
          onTap: () => context.push('/about'),
        ),
        _DrawerListTile(
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: () => context.push('/settings'),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 8),
          BlocProvider(
            create: (context) => AuthBloc(getIt<AuthRepository>()),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state.logoutStatus == LoadingStatus.loaded) {
                  // Navigate to welcome/login screen after successful logout
                  context.go('/welcome');
                } else if (state.hasLogoutError) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.logoutError),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return _DrawerListTile(
                  icon: Icons.logout,
                  title: state.isLogoutLoading ? 'Logging out...' : 'Logout',
                  textColor: Colors.red.shade700,
                  iconColor: Colors.red.shade700,
                  onTap: state.isLogoutLoading
                      ? () {}
                      : () {
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder: (dialogContext) => BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: AlertDialog(
                                title: const Text('Logout'),
                                content: const Text(
                                    'Are you sure you want to logout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                      context
                                          .read<AuthBloc>()
                                          .add(LogoutUser());
                                    },
                                    child: Text(
                                      'Logout',
                                      style:
                                          TextStyle(color: Colors.red.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Version 1.0.0',
            style: bodyStyle.copyWith(
              color: textLight,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _DrawerListTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: titleStyle.copyWith(
          fontSize: 16,
          color: textColor ?? colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 8,
      ),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
