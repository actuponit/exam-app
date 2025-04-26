import 'package:exam_app/core/presentation/widgets/app_snackbar.dart';
import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/features/payment/presentation/bloc/subscription_bloc.dart';
import 'package:exam_app/features/payment/presentation/widgets/status_banner.dart';
import 'package:exam_app/features/quiz/presentation/screens/subject_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/app_drawer.dart';
import '../../../../core/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Start periodic status checking when screen loads
    context.read<SubscriptionBloc>().add(const CheckSubscriptionStatus());
  }

  @override
  void dispose() {
    // Stop periodic status checking when screen is disposed
    context.read<SubscriptionBloc>().add(const StopPeriodicStatusCheck());
    super.dispose();
  }

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
              const SizedBox(
                height: 40,
              ),
                const SubjectSelectionScreen(),
              ],
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
    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listenWhen: (previous, current) =>
          !(previous is SubscriptionStatusLoaded &&
              current is SubscriptionStatusLoaded &&
              previous.status == SubscriptionStatus.pending &&
              current.status == SubscriptionStatus.pending),
      listener: (context, state) {
        if (state is SubscriptionError) {
          AppSnackBar.error(
            context: context,
            message: state.message,
            actionLabel: 'Retry',
            onActionPressed: () {
              context
                  .read<SubscriptionBloc>()
                  .add(const CheckSubscriptionStatus());
            },
          );
        } else if (state is SubscriptionStatusLoaded &&
            state.status == SubscriptionStatus.approved &&
            state.subscription.wasNotApproved) {
          AppSnackBar.success(
            context: context,
            message: 'Your subscription is active!',
          );
        } else if (state is SubscriptionStatusLoaded &&
            state.status == SubscriptionStatus.pending) {
          context.read<SubscriptionBloc>().add(
              const StartPeriodicStatusCheck(interval: Duration(seconds: 5)));
        }
      },
      builder: (context, state) {
        if (state is SubscriptionLoading) {
          return _buildLoadingBanner();
        } else if (state is SubscriptionStatusLoaded) {
          if (state.status == SubscriptionStatus.pending) {
            return StatusBanner(
              subscription: state.subscription,
              onCheckStatus: () {
                context
                    .read<SubscriptionBloc>()
                    .add(const CheckSubscriptionStatus());
              },
            );
          } else if (state.status == SubscriptionStatus.denied) {
            return StatusBanner(
              subscription: state.subscription,
              onResubmit: () {
                context.push(RoutePaths.transactionVerification);
              },
            );
          } else if (state.status == SubscriptionStatus.approved) {
            // Don't show banner for approved status
            return const SizedBox.shrink();
          }
        }
        // Default banner for initial state
        return const StatusBanner();
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
