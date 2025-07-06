import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                final isDark = themeState.themeMode == ThemeMode.dark;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isDark ? 'Dark Mode' : 'Light Mode',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Switch(
                      value: isDark,
                      onChanged: (_) {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
