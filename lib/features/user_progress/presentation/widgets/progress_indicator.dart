import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProgressIndicatorCard extends StatelessWidget {
  final String title;
  final double value;
  final double maxValue;
  final Color color;
  final String? iconPath;

  const ProgressIndicatorCard({
    super.key,
    required this.title,
    required this.value,
    required this.maxValue,
    required this.color,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (iconPath != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: iconPath!.endsWith('.svg')
                        ? SvgPicture.asset(
                            iconPath!,
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              color,
                              BlendMode.srcIn,
                            ),
                          )
                        : Image.asset(
                            iconPath!,
                            width: 24,
                            height: 24,
                            color: color,
                          ),
                  ),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${value.toInt()}/${maxValue.toInt()}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: color.withOpacity(0.2),
              color: color,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${(percentage * 100).toStringAsFixed(1)}% completado',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                if (percentage >= 1.0)
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Completado',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CircularProgressIndicatorWithLabel extends StatelessWidget {
  final double value;
  final double maxValue;
  final Color color;
  final String label;
  final double size;

  const CircularProgressIndicatorWithLabel({
    super.key,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.label,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = value / maxValue;
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: percentage,
                strokeWidth: 8,
                backgroundColor: color.withOpacity(0.2),
                color: color,
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class LevelProgressIndicator extends StatelessWidget {
  final int currentLevel;
  final int currentXP;
  final int xpToNextLevel;
  final double height;

  const LevelProgressIndicator({
    super.key,
    required this.currentLevel,
    required this.currentXP,
    required this.xpToNextLevel,
    this.height = 20,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = currentXP / xpToNextLevel;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Nivel $currentLevel',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '$currentXP/$xpToNextLevel XP',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  width: constraints.maxWidth * percentage,
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                );
              },
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}