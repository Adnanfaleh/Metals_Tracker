import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metals_tracker/presentation/providers/theme_provider.dart'; // 🌟 Import the new provider

// ConsumerWidget to read Riverpod state
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current theme to show it in the dropdown
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const _SectionHeader(title: 'Preferences'),

          // Theme Selector Dropdown
          ListTile(
            leading: const Icon(Icons.brightness_6, color: Colors.orange),
            title: const Text('App Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: currentTheme,
              underline:
                  const SizedBox(), // Removes the default line under the dropdown
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  // Tell Riverpod to change the theme!
                  ref.read(themeProvider.notifier).updateTheme(newMode);
                }
              },
              items: const [
                DropdownMenuItem(
                    value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
            ),
          ),

          const Divider(height: 32),

          const _SectionHeader(title: 'Data Management'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Wipe Local Data'),
            subtitle:
                const Text('Clear all cached transactions on this device'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Wipe functionality coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_sync, color: Colors.blue),
            title: const Text('Force Cloud Sync'),
            subtitle: const Text('Fetch latest transactions from Supabase'),
            onTap: () {},
          ),

          const Divider(height: 32),

          const _SectionHeader(title: 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Metals Tracker'),
            subtitle: Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
