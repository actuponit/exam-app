import 'package:exam_app/core/di/injection.dart';
import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/features/payment/presentation/cubit/subscription_status_cubit.dart';
import 'package:exam_app/features/payment/presentation/widgets/status_banner.dart';
import 'package:exam_app/features/payment/presentation/widgets/status_snack_bar.dart';
import 'package:exam_app/features/quiz/presentation/screens/subject_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/app_drawer.dart';
import '../../../../core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SubscriptionStatusCubit>()..checkStatus(),
      child: Scaffold(
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
                _buildStatusBanner(context),
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
      ),
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
  
  Widget _buildStatusBanner(BuildContext context) {
    return BlocConsumer<SubscriptionStatusCubit, SubscriptionStatusState>(
      listener: (context, state) {
        if (state is SubscriptionStatusError) {
          StatusSnackBar.showSnackBar(
            context,
            StatusSnackBar.error(
              context: context,
              message: 'Failed to check subscription status: ${state.message}',
              actionLabel: 'Retry',
              onActionPressed: () {
                context.read<SubscriptionStatusCubit>().checkStatus();
              },
            ),
          );
        } else if (state is SubscriptionStatusApproved) {
          StatusSnackBar.showSnackBar(
            context,
            StatusSnackBar.success(
              context: context,
              message: 'Your subscription is active!',
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is SubscriptionStatusLoading) {
          return _buildLoadingBanner();
        } else if (state is SubscriptionStatusPending) {
          return StatusBanner(
            subscription: state.subscription,
            onCheckStatus: () {
              context.read<SubscriptionStatusCubit>().checkStatus();
            },
          );
        } else if (state is SubscriptionStatusDenied) {
          return StatusBanner(
            subscription: state.subscription,
            onResubmit: () {
              context.push(RoutePaths.transactionVerification);
            },
          );
        } else if (state is SubscriptionStatusApproved) {
          // Don't show banner for approved status
          return const SizedBox.shrink();
        } else {
          // Default banner for initial state
          return StatusBanner();
        }
      },
    );
  }
  
  Widget _buildLoadingBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Checking subscription status...',
                  style: titleStyle.copyWith(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
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