import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/features/quiz/presentation/screens/subject_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/app_drawer.dart';
import '../../../../core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: displayStyle.copyWith(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back!',
                style: displayStyle.copyWith(
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Practice for your upcoming exams',
                style: bodyStyle.copyWith(
                  color: textLight,
                ),
              ),
              const SizedBox(height: 40),
              _buildPremiumBanner(context),
              // _buildQuickActions(context),
              const SizedBox(height: 40),
              Text(
                'Recent Exams',
                style: titleStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildRecentExams(context),
              const SizedBox(height: 40,),
              SubjectSelectionScreen(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionCard(
          icon: Icons.school_outlined,
          title: 'Practice',
          color: primaryColor,
          onTap: () => context.push('/subjects'),
        ),
        _ActionCard(
          icon: Icons.help_outline,
          title: 'FAQ',
          color: secondaryColor,
          onTap: () => context.push('/faq'),
        ),
        _ActionCard(
          icon: Icons.person_outline,
          title: 'Profile',
          color: accentColor,
          onTap: () => context.push('/profile'),
        ),
      ],
    );
  }

  Widget _buildRecentExams(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'No recent exams',
                style: titleStyle.copyWith(
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Start practicing to see your recent exams here',
                style: bodyStyle.copyWith(
                  color: textLight,
                  fontSize: 14,
                ),
              ),
              trailing: TextButton(
                onPressed: () => context.push('/subjects'),
                child: const Text('Start Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.9), primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlock Full Access',
                  style: titleStyle.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'These are sample questions. Pay now to access all questions and features!',
                  style: bodyStyle.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
              ),
            ),
            onPressed: () {
              // TODO: Implement payment flow
              context.push(RoutePaths.transactionVerification);
            },
            child: Text(
              'Pay Now',
              style: titleStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: titleStyle.copyWith(
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}