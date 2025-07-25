// lib/widgets/progress_card.dart
import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final double monthlyTarget;
  final double totalCollected;
  final double remainingAmount;
  final double progressPercentage;
  final Animation<double> progressAnimation;
  final VoidCallback onEditTarget;

  const ProgressCard({
    super.key,
    required this.monthlyTarget,
    required this.totalCollected,
    required this.remainingAmount,
    required this.progressPercentage,
    required this.progressAnimation,
    required this.onEditTarget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Overview',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: onEditTarget,
                  icon: Icon(Icons.edit_rounded, color: colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress Circle
            AnimatedBuilder(
              animation: progressAnimation,
              builder: (context, child) {
                return SizedBox(
                  height: 120,
                  width: 120,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        color: colorScheme.surfaceVariant,
                      ),
                      CircularProgressIndicator(
                        value: progressPercentage * progressAnimation.value,
                        strokeWidth: 8,
                        color: progressPercentage >= 1.0
                            ? Colors.green
                            : colorScheme.primary,
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(progressPercentage * 100).toInt()}%',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            Text(
                              'Complete',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '🎯 Target',
                    '${monthlyTarget.toStringAsFixed(0)} PKR',
                    colorScheme.primary,
                    theme,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '✅ Collected',
                    '${totalCollected.toStringAsFixed(0)} PKR',
                    Colors.green,
                    theme,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '📉 Remaining',
                    '${remainingAmount.toStringAsFixed(0)} PKR',
                    remainingAmount <= 0 ? Colors.green : Colors.orange,
                    theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
