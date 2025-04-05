// lib/app/data/models/invoice_model.dart
import 'medication_model.dart';

class Invoice {
  final int? id;
  final String title;
  final String customerName;
  final DateTime dateCreated;
  final double totalAmount;
  final String status;
  final String? notes;
  final List<InvoiceItem> items;

  Invoice({
    this.id,
    required this.title,
    required this.customerName,
    required this.dateCreated,
    required this.totalAmount,
    required this.status,
    this.notes,
    required this.items,
  });

  // Statuts possibles pour une facture
  static const String STATUS_PENDING = 'pending';
  static const String STATUS_PAID = 'paid';
  static const String STATUS_CANCELLED = 'cancelled';

  // Convertir depuis JSON/Map
  factory Invoice.fromJson(Map<String, dynamic> json,
      {List<InvoiceItem>? invoiceItems}) {
    return Invoice(
      id: json['id'],
      title: json['title'] ?? '',
      customerName: json['customer_name'] ?? '',
      dateCreated: json['date_created'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['date_created'])
          : DateTime.now(),
      totalAmount: json['total_amount'] != null
          ? double.tryParse(json['total_amount'].toString()) ?? 0.0
          : 0.0,
      status: json['status'] ?? STATUS_PENDING,
      notes: json['notes'],
      items: invoiceItems ?? [],
    );
  }

  // Convertir en JSON/Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'customer_name': customerName,
      'date_created': dateCreated.millisecondsSinceEpoch,
      'total_amount': totalAmount,
      'status': status,
      'notes': notes,
    };
  }

  // Calculer le montant total
  static double calculateTotal(List<InvoiceItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Créer une copie avec des attributs modifiés
  Invoice copyWith({
    int? id,
    String? title,
    String? customerName,
    DateTime? dateCreated,
    double? totalAmount,
    String? status,
    String? notes,
    List<InvoiceItem>? items,
  }) {
    return Invoice(
      id: id ?? this.id,
      title: title ?? this.title,
      customerName: customerName ?? this.customerName,
      dateCreated: dateCreated ?? this.dateCreated,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      items: items ?? this.items,
    );
  }
}

class InvoiceItem {
  final int? id;
  final int? invoiceId;
  final int medicationId;
  final Medication? medication;
  final int quantity;
  final double pricePerUnit;
  final double totalPrice;

  InvoiceItem({
    this.id,
    this.invoiceId,
    required this.medicationId,
    this.medication,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalPrice,
  });

  // Convertir depuis JSON/Map
  factory InvoiceItem.fromJson(Map<String, dynamic> json,
      {Medication? medicationData}) {
    final quantity = json['quantity'] ?? 1;
    final pricePerUnit = json['price_per_unit'] != null
        ? double.tryParse(json['price_per_unit'].toString()) ?? 0.0
        : 0.0;
    final totalPrice = json['total_price'] != null
        ? double.tryParse(json['total_price'].toString()) ?? 0.0
        : quantity * pricePerUnit;

    return InvoiceItem(
      id: json['id'],
      invoiceId: json['invoice_id'],
      medicationId: json['medication_id'],
      medication: medicationData,
      quantity: quantity,
      pricePerUnit: pricePerUnit,
      totalPrice: totalPrice,
    );
  }

  // Convertir en JSON/Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'medication_id': medicationId,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
      'total_price': totalPrice,
    };
  }

  // Créer une copie avec des attributs modifiés
  InvoiceItem copyWith({
    int? id,
    int? invoiceId,
    int? medicationId,
    Medication? medication,
    int? quantity,
    double? pricePerUnit,
    double? totalPrice,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      medicationId: medicationId ?? this.medicationId,
      medication: medication ?? this.medication,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  // Créer un InvoiceItem à partir d'un médicament
  factory InvoiceItem.fromMedication(Medication medication,
      {int quantity = 1}) {
    return InvoiceItem(
      medicationId: medication.id,
      medication: medication,
      quantity: quantity,
      pricePerUnit: medication.currentPrice,
      totalPrice: medication.currentPrice * quantity,
    );
  }
}
