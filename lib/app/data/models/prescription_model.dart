// lib/app/data/models/prescription_model.dart
import 'medication_model.dart';

class Prescription {
  final int? id;
  final String title;
  final String customerName;
  final DateTime dateCreated;
  final String status;
  final String? notes;
  final List<PrescriptionItem> items;

  Prescription({
    this.id,
    required this.title,
    required this.customerName,
    required this.dateCreated,
    required this.status,
    this.notes,
    required this.items,
  });

  // Statuts possibles pour une ordonnance
  static const String STATUS_ACTIVE = 'active';
  static const String STATUS_COMPLETED = 'completed';
  static const String STATUS_CANCELLED = 'cancelled';

  // Convertir depuis JSON/Map
  factory Prescription.fromJson(Map<String, dynamic> json,
      {List<PrescriptionItem>? prescriptionItems}) {
    return Prescription(
      id: json['id'],
      title: json['title'] ?? '',
      customerName: json['customer_name'] ?? '',
      dateCreated: json['date_created'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['date_created'])
          : DateTime.now(),
      status: json['status'] ?? STATUS_ACTIVE,
      notes: json['notes'],
      items: prescriptionItems ?? [],
    );
  }

  // Convertir en JSON/Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'customer_name': customerName,
      'date_created': dateCreated.millisecondsSinceEpoch,
      'status': status,
      'notes': notes,
    };
  }

  // Créer une copie avec des attributs modifiés
  Prescription copyWith({
    int? id,
    String? title,
    String? customerName,
    DateTime? dateCreated,
    String? status,
    String? notes,
    List<PrescriptionItem>? items,
  }) {
    return Prescription(
      id: id ?? this.id,
      title: title ?? this.title,
      customerName: customerName ?? this.customerName,
      dateCreated: dateCreated ?? this.dateCreated,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      items: items ?? this.items,
    );
  }
}

class PrescriptionItem {
  final int? id;
  final int? prescriptionId;
  final int medicationId;
  final Medication? medication;
  final String? dosage;
  final String? duration;
  final String? instructions;
  final int quantity;

  PrescriptionItem({
    this.id,
    this.prescriptionId,
    required this.medicationId,
    this.medication,
    this.dosage,
    this.duration,
    this.instructions,
    this.quantity = 1,
  });

  // Convertir depuis JSON/Map
  factory PrescriptionItem.fromJson(Map<String, dynamic> json,
      {Medication? medicationData}) {
    return PrescriptionItem(
      id: json['id'],
      prescriptionId: json['prescription_id'],
      medicationId: json['medication_id'],
      medication: medicationData,
      dosage: json['dosage'],
      duration: json['duration'],
      instructions: json['instructions'],
      quantity: json['quantity'] ?? 1,
    );
  }

  // Convertir en JSON/Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescription_id': prescriptionId,
      'medication_id': medicationId,
      'dosage': dosage,
      'duration': duration,
      'instructions': instructions,
      'quantity': quantity,
    };
  }

  // Créer une copie avec des attributs modifiés
  PrescriptionItem copyWith({
    int? id,
    int? prescriptionId,
    int? medicationId,
    Medication? medication,
    String? dosage,
    String? duration,
    String? instructions,
    int? quantity,
  }) {
    return PrescriptionItem(
      id: id ?? this.id,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      medicationId: medicationId ?? this.medicationId,
      medication: medication ?? this.medication,
      dosage: dosage ?? this.dosage,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
      quantity: quantity ?? this.quantity,
    );
  }
}
