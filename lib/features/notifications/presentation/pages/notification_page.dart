import 'package:exam_app/core/di/injection.dart';
import 'package:exam_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:exam_app/features/notifications/presentation/widgets/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<NotificationBloc>()..add(GetNotificationsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return const Center(child: Text('No notifications found'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NotificationBloc>().add(GetNotificationsEvent());
                },
                child: ListView.builder(
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) {
                    return NotificationItem(
                      notification: state.notifications[index],
                    );
                  },
                ),
              );
            } else if (state is NotificationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<NotificationBloc>()
                            .add(GetNotificationsEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
