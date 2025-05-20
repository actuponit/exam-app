import 'package:exam_app/core/di/injection.dart';
import 'package:exam_app/features/auth/data/repositories/auth_repository.dart';
import 'package:exam_app/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:exam_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
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
    return BlocProvider(
      create: (context) =>
          ProfileCubit(authRepository: getIt<AuthRepository>())..loadProfile(),
      child: Builder(builder: (context) {
        return Container(
          padding:
              const EdgeInsets.only(top: 50, bottom: 20, left: 10, right: 10),
          decoration: const BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(
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
                      border: Border.all(color: Colors.white, width: 2),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.firstName ?? 'Guest User',
                    style: titleStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.email ?? 'guest@example.com',
                    style: bodyStyle.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
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
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? primaryColor,
        size: 24,
      ),
      title: Text(
        title,
        style: titleStyle.copyWith(
          fontSize: 16,
          color: textColor ?? textDark,
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
