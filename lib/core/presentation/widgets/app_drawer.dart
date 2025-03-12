import 'package:flutter/material.dart';
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
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(cardRadius),
          bottomRight: Radius.circular(cardRadius),
        ),
      ),
      child: Column(
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
            'Guest User',
            style: titleStyle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'guest@example.com',
            style: bodyStyle.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
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
          _DrawerListTile(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              // TODO: Implement logout logic
              context.go('/login');
            },
            textColor: Colors.red,
            iconColor: Colors.red,
          ),
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