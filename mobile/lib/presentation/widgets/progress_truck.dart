import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../core/theme/app_theme.dart';

/// Progress indicator styled as a truck filling bar.
///
/// 0–70%: green (#16A34A), 70–99%: yellow (#FACC15), 100%: green neon.
class ProgressTruck extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  final String collected;
  final String target;
  final String? countdownText;
  final String unit;

  const ProgressTruck({
    super.key,
    required this.progress,
    required this.collected,
    required this.target,
    this.countdownText,
    this.unit = 'kg',
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final color = clampedProgress >= 1.0
        ? AppTheme.primary
        : clampedProgress >= 0.7
            ? AppTheme.warning
            : AppTheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, color: AppTheme.primary, size: 22),
              const Gap(8),
              Expanded(
                child: Text(
                  'Progress',
                  style: AppTheme.titleMedium,
                ),
              ),
              Text(
                '${(clampedProgress * 100).toStringAsFixed(0)}%',
                style: AppTheme.titleMedium.copyWith(color: color),
              ),
            ],
          ),
          const Gap(12),
          LinearPercentIndicator(
            lineHeight: 24,
            percent: clampedProgress,
            center: Text(
              '${(clampedProgress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            backgroundColor: AppTheme.border,
            progressColor: color,
            barRadius: const Radius.circular(12),
            padding: EdgeInsets.zero,
            animation: true,
            animateFromLastPercent: true,
          ),
          const Gap(8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Terkumpul $collected dari Target $target $unit',
                  style: AppTheme.bodySmall,
                ),
              ),
              if (countdownText != null)
                Text(
                  countdownText!,
                  style: AppTheme.labelMedium.copyWith(
                    color: countdownText!.contains('Sisa 0') ? AppTheme.error : AppTheme.textPrimary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
