// lib/app/modules/invoices/views/sales_reports_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../components/loader.dart';
import '../controller/invoices_controller.dart';

class SalesReportsView extends GetView<InvoicesController> {
  const SalesReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Charger les statistiques de vente au chargement de la vue
    controller.loadSalesStatistics();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقارير المبيعات'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Loader(message: 'جاري تحميل التقارير...');
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sélecteur de période
              _buildDateRangePicker(context),
              SizedBox(height: 24.h),

              // Carte de résumé total
              _buildTotalSalesCard(context),
              SizedBox(height: 24.h),

              // Graphique des ventes
              _buildSalesChart(context),
              SizedBox(height: 24.h),

              // Produits les plus vendus
              _buildTopSellingProducts(context),
            ],
          ),
        );
      }),
    );
  }

  // Sélecteur de période
  Widget _buildDateRangePicker(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('dd/MM/yyyy', 'ar');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الفترة الزمنية',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectStartDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'من',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                      ),
                      child: Text(
                        dateFormatter.format(controller.startDate.value),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectEndDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'إلى',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                      ),
                      child: Text(
                        dateFormatter.format(controller.endDate.value),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Périodes prédéfinies
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPresetDateButton(
                    context,
                    'اليوم',
                    DateTime.now(),
                    DateTime.now(),
                  ),
                  SizedBox(width: 8.w),
                  _buildPresetDateButton(
                    context,
                    'هذا الأسبوع',
                    DateTime.now()
                        .subtract(Duration(days: DateTime.now().weekday - 1)),
                    DateTime.now(),
                  ),
                  SizedBox(width: 8.w),
                  _buildPresetDateButton(
                    context,
                    'هذا الشهر',
                    DateTime(DateTime.now().year, DateTime.now().month, 1),
                    DateTime.now(),
                  ),
                  SizedBox(width: 8.w),
                  _buildPresetDateButton(
                    context,
                    'آخر 3 أشهر',
                    DateTime.now().subtract(const Duration(days: 90)),
                    DateTime.now(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bouton pour période prédéfinie
  Widget _buildPresetDateButton(
      BuildContext context, String label, DateTime start, DateTime end) {
    return OutlinedButton(
      onPressed: () {
        controller.updateReportPeriod(start, end);
      },
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.h),
      ),
      child: Text(label),
    );
  }

  // Sélectionner la date de début
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.startDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'SA'),
    );

    if (picked != null && picked != controller.startDate.value) {
      // S'assurer que la date de début est avant la date de fin
      if (picked.isAfter(controller.endDate.value)) {
        controller.updateReportPeriod(picked, picked);
      } else {
        controller.updateReportPeriod(picked, controller.endDate.value);
      }
    }
  }

  // Sélectionner la date de fin
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.endDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'SA'),
    );

    if (picked != null && picked != controller.endDate.value) {
      // S'assurer que la date de fin est après la date de début
      if (picked.isBefore(controller.startDate.value)) {
        controller.updateReportPeriod(picked, picked);
      } else {
        controller.updateReportPeriod(controller.startDate.value, picked);
      }
    }
  }

  // Carte de résumé des ventes
  Widget _buildTotalSalesCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إجمالي المبيعات',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              controller.formatCurrency(controller.totalSales.value),
              style: theme.textTheme.displayMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'للفترة من ${DateFormat('dd/MM/yyyy', 'ar').format(controller.startDate.value)} إلى ${DateFormat('dd/MM/yyyy', 'ar').format(controller.endDate.value)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Graphique des ventes
  Widget _buildSalesChart(BuildContext context) {
    final theme = Theme.of(context);
    final salesStats = controller.salesStats.value;

    // Vérifier si les données sont disponibles
    if (salesStats.isEmpty ||
        !salesStats.containsKey('labels') ||
        !salesStats.containsKey('total')) {
      return const SizedBox.shrink();
    }

    final labels = salesStats['labels'] as List;
    final totals = salesStats['total'] as List;

    // Vérifier s'il y a des données suffisantes
    if (labels.isEmpty || totals.isEmpty || labels.length != totals.length) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تحليل المبيعات',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),

            // Graphique à barres
            SizedBox(
              height: 250.h,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: totals.cast<double>().reduce((a, b) => a > b ? a : b) *
                      1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          controller.formatCurrency(totals[groupIndex]),
                          theme.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                          if (value < 0 || value >= labels.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              labels[value.toInt()],
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
                          // Afficher moins de chiffres sur l'axe Y pour éviter l'encombrement
                          if (value % (meta.max / 5).ceil() != 0) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: Text(
                              controller.formatCurrency(value),
                              style: theme.textTheme.bodySmall,
                            ),
                          );
                        },
                        reservedSize: 60,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.dividerColor,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: List.generate(
                    labels.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: totals[index],
                          color: theme.colorScheme.primary,
                          width: 18.w,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(4.r),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: totals
                                    .cast<double>()
                                    .reduce((a, b) => a > b ? a : b) *
                                1.2,
                            color: theme.dividerColor.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Produits les plus vendus
  Widget _buildTopSellingProducts(BuildContext context) {
    final theme = Theme.of(context);
    final topProducts = controller.topSellingMedications;

    if (topProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الأدوية الأكثر مبيعاً',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topProducts.length > 5 ? 5 : topProducts.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final product = topProducts[index];
                final totalQuantity = product['total_quantity'] as int;
                final totalSales = product['total_sales'] as double;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    product['trade_name'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['scientific_name'] as String),
                      SizedBox(height: 4.h),
                      Text(
                        'الكمية: $totalQuantity | الإجمالي: ${controller.formatCurrency(totalSales)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      Get.toNamed('/details/${product['id']}');
                    },
                    child: const Text('التفاصيل'),
                  ),
                );
              },
            ),

            // Bouton "Afficher plus"
            if (topProducts.length > 5)
              Center(
                child: TextButton(
                  onPressed: () {
                    // Afficher une vue détaillée de tous les produits
                    Get.toNamed('/invoices/top-products');
                  },
                  child: const Text('عرض المزيد'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
