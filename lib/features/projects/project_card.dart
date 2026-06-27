import 'package:flutter/material.dart';
import '../../core/models/project.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/supa_card.dart';
import '../../widgets/supa_badge.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    if (status.toUpperCase() == 'ACTIVE_HEALTHY') {
      return AppColors.statusActive;
    } else if (status.toUpperCase() == 'COMING_UP') {
      return AppColors.statusPaused;
    } else {
      return AppColors.statusInactive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SupaCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                SupaBadge(
                  text: project.status.replaceAll('_', ' '),
                  color: _getStatusColor(project.status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  project.ref,
                  style: AppTheme.codeStyle.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                Text(
                  project.region,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              project.organizationId, // Replace with org details if available via API
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

