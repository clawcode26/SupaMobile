import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/analytics_providers.dart';
import '../core/theme/app_colors.dart';

class TimeRangeSelector extends ConsumerWidget {
  const TimeRangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(metricTimeRangeProvider);

    return Row(
      children: [
        _RangeChip(label: '1H', value: MetricTimeRange.hour, selected: selected, ref: ref),
        const SizedBox(width: 8),
        _RangeChip(label: '24H', value: MetricTimeRange.day, selected: selected, ref: ref),
        const SizedBox(width: 8),
        _RangeChip(label: '7D', value: MetricTimeRange.week, selected: selected, ref: ref),
        const SizedBox(width: 8),
        _RangeChip(label: '30D', value: MetricTimeRange.month, selected: selected, ref: ref),
      ],
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final MetricTimeRange value;
  final MetricTimeRange selected;
  final WidgetRef ref;

  const _RangeChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => ref.read(metricTimeRangeProvider.notifier).set(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.supaGreen.withOpacity(0.12) : AppColors.bgSurface,
          border: Border.all(
            color: isSelected ? AppColors.supaGreen : AppColors.borderDefault,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.supaGreen.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.supaGreen : AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
