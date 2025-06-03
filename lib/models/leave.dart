

import 'package:flutter/material.dart';

class Leave {
  final String id;
  final String employeeId;
  final String employeeName;
  final String type; // "Maladie", "Maternité", "Annuel"
  final DateTime startDate;
  final DateTime endDate;
  final String status; // "En attente", "Approuvé", "Rejeté"
  final String? medicalCertificatePath; // Pour congé maladie/maternité
  final String? reason; // Raison du congé
  final DateTime requestDate;
  final int duration; // Durée en jours
  final double salaryPercentage; // Pourcentage du salaire (100%, 50%, etc.)

  Leave({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.status = "En attente",
    this.medicalCertificatePath,
    this.reason,
    required this.requestDate,
    required this.duration,
    this.salaryPercentage = 100.0,
  });

  // Calculer les jours de congé
  int get daysCount {
    return endDate.difference(startDate).inDays + 1;
  }

  // Vérifier si le congé est actif
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate.add(const Duration(days: 1)));
  }

  // Obtenir la couleur selon le statut
  Color get statusColor {
    switch (status) {
      case "Approuvé":
        return Colors.green;
      case "Rejeté":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // Obtenir l'icône selon le type
  IconData get typeIcon {
    switch (type) {
      case "Maladie":
        return Icons.local_hospital;
      case "Maternité":
        return Icons.child_care;
      default:
        return Icons.beach_access;
    }
  }

  // Vérifier si un certificat médical est requis
  bool get requiresMedicalCertificate {
    return type == "Maladie" || type == "Maternité";
  }

  // Calculer le pourcentage de salaire selon les règles algériennes
  static double calculateSalaryPercentage(String type, int durationInMonths) {
    switch (type) {
      case "Maladie":
        if (durationInMonths <= 3) {
          return 100.0;
        } else if (durationInMonths <= 6) {
          return 50.0;
        } else {
          return 0.0;
        }
      case "Maternité":
        return 100.0; // 14 semaines à 100%
      case "Annuel":
        return 100.0;
      default:
        return 100.0;
    }
  }

  // Convertir en Map pour la persistance
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'type': type,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'medicalCertificatePath': medicalCertificatePath,
      'reason': reason,
      'requestDate': requestDate.toIso8601String(),
      'duration': duration,
      'salaryPercentage': salaryPercentage,
    };
  }

  // Créer depuis Map
  factory Leave.fromMap(Map<String, dynamic> map) {
    return Leave(
      id: map['id'],
      employeeId: map['employeeId'],
      employeeName: map['employeeName'],
      type: map['type'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      status: map['status'] ?? "En attente",
      medicalCertificatePath: map['medicalCertificatePath'],
      reason: map['reason'],
      requestDate: DateTime.parse(map['requestDate']),
      duration: map['duration'],
      salaryPercentage: map['salaryPercentage']?.toDouble() ?? 100.0,
    );
  }

  // Copier avec modifications
  Leave copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? medicalCertificatePath,
    String? reason,
    DateTime? requestDate,
    int? duration,
    double? salaryPercentage,
  }) {
    return Leave(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      medicalCertificatePath: medicalCertificatePath ?? this.medicalCertificatePath,
      reason: reason ?? this.reason,
      requestDate: requestDate ?? this.requestDate,
      duration: duration ?? this.duration,
      salaryPercentage: salaryPercentage ?? this.salaryPercentage,
    );
  }
}