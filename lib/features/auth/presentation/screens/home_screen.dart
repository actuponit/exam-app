import 'package:exam_app/core/presentation/widgets/app_snackbar.dart';
import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/features/payment/presentation/bloc/subscription_bloc.dart';
import 'package:exam_app/features/payment/presentation/widgets/status_banner.dart';
import 'package:exam_app/features/quiz/presentation/bloc/question_bloc.dart';
import 'package:exam_app/features/quiz/presentation/bloc/question_event.dart';
import 'package:exam_app/features/quiz/presentation/bloc/question_state.dart';
import 'package:exam_app/features/quiz/presentation/bloc/subject_bloc/subject_bloc.dart';
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
    context.read<QuestionBloc>().add(FetchQuestions());
  }

  @override
  void dispose() {
    // Stop periodic status checking when screen is disposed
    context.read<SubscriptionBloc>().add(const StopPeriodicStatusCheck());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuestionBloc, QuestionState>(
      listener: (context, state) {
        if (state.status == QuestionStatus.success) {
          context.read<SubjectBloc>().add(LoadSubjects());
        }
      },
      builder: (context, state) {
        if (state.status == QuestionStatus.success) {
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
                    const SizedBox(
                      height: 24,
                    ),
                    const SubjectSelectionScreen(),
                  ],
                ),
              ),
            ),
            floatingActionButton: _buildRefetchButton(context),
          );
        } else if (state.status == QuestionStatus.loading) {
          return _buildLoadingScreen();
        } else {
          return _buildErrorScreen(() {
            context.read<QuestionBloc>().add(FetchQuestions());
          });
        }
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading your study materials...',
              style: titleStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we prepare your dashboard',
              style: bodyStyle.copyWith(
                color: textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(VoidCallback onRetry) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cardRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 20),
                  SelectableText.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Something went wrong\n',
                          style: titleStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: 'We couldn\'t load your dashboard content',
                          style: bodyStyle.copyWith(
                            color: textLight,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
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
          context.read<QuestionBloc>().add(const FetchQuestions(
                ensureBackend: true,
              ));
          AppSnackBar.success(
            context: context,
            message: 'Your subscription is active!',
          );
        } else if (state is SubscriptionStatusLoaded &&
            state.status == SubscriptionStatus.pending) {
          context
              .read<SubscriptionBloc>()
              .add(const StartPeriodicStatusCheck());
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

  Widget _buildRefetchButton(BuildContext context) {
    return FloatingActionButtonPulse(
      onPressed: () {
        context.read<QuestionBloc>().add(const FetchQuestions(
              ensureBackend: true,
            ));
      },
      tooltip: 'Refresh Exam Content',
      gradient: LinearGradient(
        colors: [
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor.withBlue(
              (Theme.of(context).primaryColor.blue + 30).clamp(0, 255)),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: const Icon(
        Icons.refresh_rounded,
        color: Colors.white,
      ),
    );
  }
}

class FloatingActionButtonPulse extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String tooltip;
  final LinearGradient gradient;

  const FloatingActionButtonPulse({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.tooltip,
    required this.gradient,
  }) : super(key: key);

  @override
  State<FloatingActionButtonPulse> createState() =>
      _FloatingActionButtonPulseState();
}

class _FloatingActionButtonPulseState extends State<FloatingActionButtonPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.gradient.colors.first.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: widget.onPressed,
              tooltip: widget.tooltip,
              elevation: 8,
              highlightElevation: 12,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.gradient,
                ),
                child: Center(
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
