// lib/app/modules/invoice_edit/views/invoice_edit_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../components/loader.dart';
import '../../../components/search_bar.dart';
import '../controller/invoice_edit_controller.dart';

class InvoiceEditView extends GetView<InvoiceEditController> {
  const InvoiceEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing.value
            ? 'تعديل الفاتورة'
            : 'إنشاء فاتورة جديدة'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Loader(message: 'جاري التحميل...');
        }

        return Column(
          children: [
            // Informations de la facture
            _buildInvoiceInfo(context),

            // Barre de recherche pour ajouter des médicaments
            Padding(
              padding: EdgeInsets.all(16.r),
              child: AppSearchBar(
                controller: controller.searchController,
                onChanged: controller.updateSearchQuery,
                hintText: 'البحث عن دواء لإضافته...',
                autoFocus: false,
                showFilterButton: false,
              ),
            ),

            // Liste des résultats de recherche ou des médicaments sélectionnés
            Expanded(
              child: controller.searchQuery.isEmpty
                  ? _buildSelectedMedicationsList(context)
                  : _buildSearchResultsList(context),
            ),

            // Total et bouton de création
            _buildBottomBar(context),
          ],
        );
      }),
    );
  }

  // Informations de la facture (titre, client, notes)
  Widget _buildInvoiceInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de la facture
          TextField(
            controller: controller.titleController,
            decoration: InputDecoration(
              labelText: 'عنوان الفاتورة*',
              hintText: 'أدخل عنوان الفاتورة',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Nom du client
          TextField(
            controller: controller.customerNameController,
            decoration: InputDecoration(
              labelText: 'اسم العميل*',
              hintText: 'أدخل اسم العميل',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Notes
          TextField(
            controller: controller.notesController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'ملاحظات',
              hintText: 'أي ملاحظات إضافية',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Liste des médicaments sélectionnés
  Widget _buildSelectedMedicationsList(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
      decimalDigits: 2,
    );

    if (controller.selectedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart,
              size: 64.r,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'لم تقم بإضافة أية أدوية بعد',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 8.h),
            Text(
              'استخدم شريط البحث لإضافة أدوية للفاتورة',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: controller.selectedItems.length,
      itemBuilder: (context, index) {
        final item = controller.selectedItems[index];

        return Card(
          margin: EdgeInsets.only(bottom: 12.r),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            // Suite de lib/app/modules/invoice_edit/views/invoice_edit_view.dart

            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Détails du médicament
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.medication?.tradeName ?? 'دواء غير معروف',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (item.medication?.scientificName != null)
                            Text(
                              item.medication!.scientificName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          SizedBox(height: 4.h),
                          Text(
                            'سعر الوحدة: ${currencyFormatter.format(item.pricePerUnit)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),

                    // Contrôles de quantité
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (item.quantity > 1) {
                              controller.updateMedicationQuantity(
                                item.medicationId,
                                item.quantity - 1,
                              );
                            } else {
                              controller.removeMedication(item.medicationId);
                            }
                          },
                        ),
                        Container(
                          width: 40.w,
                          alignment: Alignment.center,
                          child: Text(
                            '${item.quantity}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            controller.updateMedicationQuantity(
                              item.medicationId,
                              item.quantity + 1,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Prix total pour cet article
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'الإجمالي: ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      currencyFormatter.format(item.totalPrice),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                // Bouton de suppression
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        controller.removeMedication(item.medicationId),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'إزالة',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Liste des résultats de recherche
  Widget _buildSearchResultsList(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (controller.isSearching.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.searchResults.isEmpty) {
        return const Center(
          child: Text('لم يتم العثور على نتائج'),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final medication = controller.searchResults[index];

          return Card(
            margin: EdgeInsets.only(bottom: 12.r),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: InkWell(
              onTap: () => controller.addMedication(medication),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication.tradeName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            medication.scientificName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${medication.currentPrice.toStringAsFixed(2)} ج.م',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle,
                          color: theme.colorScheme.primary),
                      onPressed: () => controller.addMedication(medication),
                      tooltip: 'إضافة إلى الفاتورة',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  // Barre inférieure avec le total et le bouton de création
  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Total
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإجمالي',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  controller.formatCurrency(controller.currentTotal.value),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Bouton de création/mise à jour
          ElevatedButton.icon(
            onPressed:
                controller.isProcessing.value ? null : controller.saveInvoice,
            icon: Icon(controller.isEditing.value ? Icons.update : Icons.save),
            label: Text(controller.isEditing.value
                ? 'تحديث الفاتورة'
                : 'إنشاء الفاتورة'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }
}
