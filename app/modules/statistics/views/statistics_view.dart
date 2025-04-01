// lib/app/modules/statistics/views/statistics_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/statistics_controller.dart';
import '../../../components/loader.dart';
import '../../../components/error_view.dart';

class StatisticsView extends GetView<StatisticsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إحصائيات الأدوية'),
        centerTitle: true,
        elevation: 0,
      ),
      body: controller.obx(
        (state) => _buildContent(context),
        onLoading: Loader(message: 'جاري تحميل الإحصائيات...'),
        onError: (error) => ErrorView(
          message: controller.errorMessage.value,
          onRetry: controller.refreshData,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadStatistics();
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Time period selector
            _buildTimePeriodSelector(context),

            // General stats
            _buildGeneralStats(context),

            // Most visited medications
            _buildMostVisitedMedications(context),

            // Most searched medications
            _buildMostSearchedMedications(context),

            // Top search terms
            _buildTopSearchTerms(context),

            // Price distribution chart
            _buildPriceDistributionChart(context),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePeriodSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPeriodButton(context, 0, 'الكل'),
          _buildPeriodButton(context, 1, 'هذا الشهر'),
          _buildPeriodButton(context, 2, 'هذا الأسبوع'),
          _buildPeriodButton(context, 3, 'اليوم'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(BuildContext context, int period, String label) {
    final theme = Theme.of(context);

    return Obx(() {
      final isSelected = controller.selectedPeriod.value == period;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: () => controller.changePeriod(period),
          child: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            foregroundColor:
                isSelected ? Colors.white : theme.colorScheme.onSurface,
            elevation: isSelected ? 2 : 0,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: theme.textTheme.bodyMedium,
          ),
        ),
      );
    });
  }

  Widget _buildGeneralStats(BuildContext context) {
    final theme = Theme.of(context);
    final stats = controller.generalStats.value;

    if (stats == null) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائيات عامة',
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                context,
                'إجمالي الأدوية',
                stats.totalMedications.toString(),
                Icons.medication,
                theme.colorScheme.primary,
              ),
              _buildStatCard(
                context,
                'إجمالي الزيارات',
                _formatNumber(stats.totalVisits),
                Icons.remove_red_eye,
                Colors.teal,
              ),
              _buildStatCard(
                context,
                'إجمالي عمليات البحث',
                _formatNumber(stats.totalSearches),
                Icons.search,
                Colors.orange,
              ),
              _buildStatCard(
                context,
                'متوسط السعر',
                '${stats.averagePrice.toStringAsFixed(2)} د.ك',
                Icons.price_change,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostVisitedMedications(BuildContext context) {
    final theme = Theme.of(context);
    final medications = controller.mostVisitedMedications;

    if (medications.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأدوية الأكثر زيارة',
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: medications.length > 5 ? 5 : medications.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final medication = medications[index];
                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    medication.tradeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(medication.scientificName),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_formatNumber(medication.visitCount ?? 0)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () => Get.toNamed('/details/${medication.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMostSearchedMedications(BuildContext context) {
    final theme = Theme.of(context);
    final medications = controller.mostSearchedMedications;

    if (medications.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأدوية الأكثر بحثاً',
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: medications.length > 5 ? 5 : medications.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final medication = medications[index];
                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    medication.tradeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(medication.scientificName),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Get.toNamed('/details/${medication.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSearchTerms(BuildContext context) {
    final theme = Theme.of(context);
    final searchTerms = controller.topSearchTerms;

    if (searchTerms.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'عبارات البحث الشائعة',
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: searchTerms.map((term) {
                  return Chip(
                    label: Text(term.searchTerm),
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    side: BorderSide(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                    onDeleted: null,
                    deleteIcon: Text(
                      '${term.searchCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    deleteButtonTooltipMessage: 'عدد عمليات البحث',
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDistributionChart(BuildContext context) {
    final theme = Theme.of(context);

    // For demo purposes, we'll create some mock data
    // In a real app, this would come from the API
    final priceRanges = [
      {'range': '0-10', 'count': 120},
      {'range': '10-20', 'count': 230},
      {'range': '20-30', 'count': 180},
      {'range': '30-40', 'count': 95},
      {'range': '40-50', 'count': 65},
      {'range': '50+', 'count': 40},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'توزيع أسعار الأدوية',
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 250,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipRoundedRadius: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${priceRanges[groupIndex]['count']} دواء',
                                theme.textTheme.bodyMedium!,
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    priceRanges[value.toInt()]['range']
                                        as String,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value % 50 != 0) return SizedBox();
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    value.toInt().toString(),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barGroups: List.generate(
                          priceRanges.length,
                          (index) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: priceRanges[index]['count'] as double,
                                color: theme.colorScheme.primary,
                                width: 20,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: 50,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: theme.dividerColor,
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'نطاق السعر (د.ك)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}
