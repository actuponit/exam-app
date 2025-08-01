import 'package:exam_app/core/presentation/utils/dialog_utils.dart';
import 'package:exam_app/core/presentation/widgets/app_snackbar.dart';
import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/features/exams/presentation/bloc/recent_exam_bloc/recent_exam_cubit.dart';
import 'package:exam_app/features/exams/presentation/bloc/recent_exam_bloc/recent_exam_state.dart';
import 'package:exam_app/features/payment/presentation/bloc/subscription_bloc.dart';
import 'package:exam_app/features/payment/presentation/widgets/status_banner.dart';
import 'package:exam_app/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:exam_app/features/quiz/presentation/bloc/question_bloc.dart';
import 'package:exam_app/features/quiz/presentation/bloc/question_event.dart';
import 'package:exam_app/features/quiz/presentation/bloc/question_state.dart';
import 'package:exam_app/features/quiz/presentation/bloc/subject_bloc/subject_bloc.dart';
import 'package:exam_app/features/quiz/presentation/screens/subject_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/presentation/widgets/app_drawer.dart';
import '../../../../core/theme.dart';
// import '../../../../core/theme_cubit.dart';

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
    context.read<QuestionBloc>().add(const FetchQuestions());
    context.read<ProfileCubit>().loadProfile();
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
                  icon: const Icon(Icons.share),
                  onPressed: () async {
                    final uri = Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.ethioexam.app');
                    final params = ShareParams(uri: uri);
                    await SharePlus.instance.share(params);
                  },
                ),
                // Theme toggle button removed from here. Now in Settings.
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
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontSize: 28,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Practice for your upcoming exams',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 40),
                    _buildStatusBanner(context),
                    // _buildQuickActions(context),
                    const SizedBox(height: 40),
                    Text(
                      'Recent Exam',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onBackground,
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
                  Theme.of(context).colorScheme.onBackground,
                ),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading your study materials...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we prepare your dashboard',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.7),
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
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                        ),
                        TextSpan(
                          text: 'We couldn\'t load your dashboard content',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.7),
                                  ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Try Again',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
    return BlocBuilder<RecentExamCubit, RecentExamState>(
      builder: (context, state) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state is RecentExamLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state is RecentExamLoaded && state.recentExam != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.history_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Continue Learning',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pick up where you left off',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground
                                            .withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .shadowColor
                                  .withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.book_rounded,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    state.recentExam!.region != null
                                        ? "${state.recentExam!.subject.name} (${state.recentExam!.region})"
                                        : state.recentExam!.subject.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Year ${state.recentExam!.year}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                            ),
                                      ),
                                    ],
                                  ),
                                  if (state.recentExam!.chapter != null) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.menu_book_rounded,
                                          size: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            state.recentExam!.chapter!.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontSize: 15,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onBackground
                                                      .withOpacity(0.7),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            DialogUtils.showModeSelectionDialog(
                              context,
                              year: state.recentExam!.year.toString(),
                              subjectId: state.recentExam!.subject.id,
                              chapterId:
                                  state.recentExam!.chapter?.id, // optional
                              region: state.recentExam!.region,
                              onCancel: () {
                                // Handle cancel if needed
                              },
                            );
                          },
                          icon: Icon(Icons.play_arrow_rounded,
                              color: Colors.white),
                          label: Text('Continue Learning',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'No recent exams',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                    subtitle: Text(
                      'Start practicing to see your recent exams here',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.7),
                            fontSize: 14,
                          ),
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        context.push('/subjects');
                      },
                      child: Text(
                        'Start Now',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Checking subscription status...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: Theme.of(context).colorScheme.primary,
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
    super.key,
    required this.onPressed,
    required this.child,
    required this.tooltip,
    required this.gradient,
  });

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
