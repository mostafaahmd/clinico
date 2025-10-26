// lib/features/progress/presentation/progress_page.dart
import 'package:clinico/core/theming/app_colors.dart';
import 'package:clinico/features/progress/providers/progress_providers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(last14MealsProvider);
    final adhSeries = ref.watch(medsAdherence7dSeriesProvider);
    final adhTotal = ref.watch(adherence7dProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Progress'),
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          ChartCard(
            title: 'Calories (14d)',
            child: SizedBox(
              height: 220,
              child: meals.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (points) => CaloriesBarChart(points: points),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ChartCard(
            title: 'Medicine Adherence (7d)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 180,
                  child: adhSeries.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (series) => AdherenceLineChart(series: series),
                  ),
                ),
                const SizedBox(height: 12),
                adhTotal.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (v) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${(v * 100).clamp(0, 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: v.clamp(0, 1),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: const Color(0xFFE9EEF9),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              _LegendDot(color: AppColors.primary, label: 'Taken'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFFE9EEF9), label: 'Missed'),
            ],
          )
        ],
      ),
    );
  }
}

class ChartCard extends StatelessWidget {
  const ChartCard({super.key, required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF9)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// ======== Calories Bar Chart (14d) =========
class CaloriesBarChart extends StatelessWidget {
  const CaloriesBarChart({super.key, required this.points});
  final List<DailyPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxY = (points
        .map((e) => e.value)
        .fold<int>(0, (a, b) => a > b ? a : b)).toDouble();
    final showEvery = points.length <= 14 ? 2 : 3;

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
              '${points[group.x.toInt()].label}\n',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: '${rod.toY.toInt()} cal',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) =>
              const FlLine(color: Color(0xFFE9EEF9), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: (maxY <= 0) ? 1 : (maxY / 4).ceilToDouble(),
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= points.length) return const SizedBox.shrink();
                if (i % showEvery != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(points[i].label,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF94A3B8))),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        maxY: (maxY == 0 ? 10 : maxY * 1.2),
        minY: 0,
        barGroups: List.generate(points.length, (i) {
          final v = points[i].value.toDouble();
          final y = v == 0 ? 0.5 : v; // ما يختفيش العمود لو 0
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: y,
                width: 12,
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.7)
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: (maxY == 0 ? 10 : maxY * 1.2),
                  color: const Color(0xFFF3F6FF),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// ======== Medicine Adherence Line (7d) =========
/// يرسم نسبة الالتزام لكل يوم (0..100%) بخط ناعم + منطقة ملوّنة
class AdherenceLineChart extends StatelessWidget {
  const AdherenceLineChart({super.key, required this.series});
  final List<DailyAdherence> series;

  @override
  Widget build(BuildContext context) {
    // نحول taken/expected إلى نسبة مئوية لكل نقطة
    final spots = <FlSpot>[];
    for (int i = 0; i < series.length; i++) {
      final e = series[i];
      final pct = e.expected == 0 ? 0.0 : (e.taken / e.expected) * 100.0;
      spots.add(FlSpot(i.toDouble(), pct.clamp(0, 100)));
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        backgroundColor: Colors.transparent,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) =>
              FlLine(color: const Color(0xFFE9EEF9), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: 25,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}%',
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= series.length) return const SizedBox.shrink();
                // اعرض كل يومين لتفادي الزحمة
                if (i.isOdd) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    series[i].label,
                    style:
                        const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((ts) {
                final i = ts.spotIndex;
                final p = series[i];
                final pct = ts.y.toStringAsFixed(0);
                return LineTooltipItem(
                  '${p.label}\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: 'Taken: ${p.taken}/${p.expected}\n',
                      style: const TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'Adherence: $pct%',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: AppColors.primary,
            dotData: FlDotData(
              show: true,
              getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                radius: 3,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppColors.primary,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.25),
                  AppColors.primary.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        // خط هدف 100%
        extraLinesData: ExtraLinesData(horizontalLines: [
          HorizontalLine(
            y: 100,
            color: const Color(0xFFD1D5DB),
            strokeWidth: 1,
            dashArray: [6, 4],
          ),
        ]),
      ),
    );
  }
}

       

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext c) => Row(children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Color(0xFF64748B))),
      ]);
}
