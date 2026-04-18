import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SafeArea(
      key: const ValueKey('more'),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'More',
            style: t.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.library_books_outlined),
            title: Text('Learning library'),
          ),
          const ListTile(
            leading: Icon(Icons.science_outlined),
            title: Text('Labs'),
          ),
          const ListTile(
            leading: Icon(Icons.face_retouching_natural),
            title: Text('Appearance & routines'),
          ),
          const ListTile(
            leading: Icon(Icons.shield_outlined),
            title: Text('Privacy & vault'),
          ),
          const ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Settings'),
          ),
        ],
      ),
    );
  }
}
