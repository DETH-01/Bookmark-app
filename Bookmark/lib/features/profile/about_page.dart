import 'package:flutter/material.dart';

import '../../core/team.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_logo.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('เกี่ยวกับผู้จัดทำ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          const Center(child: AppLogo(size: 84)),
          const SizedBox(height: 16),
          Text(TeamConfig.teamName,
              textAlign: TextAlign.center, style: t.headlineSmall),
          const SizedBox(height: 4),
          const Text('ผู้จัดทำโปรเจคBookmark',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 24),
          for (final m in TeamConfig.members)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.amber.withValues(alpha: 0.18),
                      backgroundImage:
                          m.photo == null ? null : AssetImage(m.photo!),
                      onBackgroundImageError:
                          m.photo == null ? null : (_, __) {},
                      child: m.photo != null
                          ? null
                          : Text(
                              m.name.isEmpty
                                  ? '?'
                                  : String.fromCharCode(m.name.runes.first),
                              style: t.titleMedium
                                  ?.copyWith(color: AppColors.amber),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: t.titleSmall),
                          const SizedBox(height: 2),
                          Text(m.studentId,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(m.role,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}