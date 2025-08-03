import 'package:flutter/material.dart';

class DrugInfo {
  final String name;
  final String? category;
  final String? activeIngredient;
  final List<String> contraindications;
  final int riskLevel; // 1-5 seviye

  DrugInfo({
    required this.name,
    this.category,
    this.activeIngredient,
    this.contraindications = const [],
    this.riskLevel = 1,
  });
}

class InteractionResult {
  final List<DrugInfo> drugs;
  final int overallRisk; // 1-5 seviye
  final String riskLevel; // Düşük, Orta, Yüksek, Kritik
  final String summary;
  final String detailedAnalysis;
  final List<InteractionPair> interactions;
  final List<String> recommendations;
  final DateTime analyzedAt;
  final bool aiGenerated;

  InteractionResult({
    required this.drugs,
    required this.overallRisk,
    required this.riskLevel,
    required this.summary,
    required this.detailedAnalysis,
    required this.interactions,
    required this.recommendations,
    required this.analyzedAt,
    this.aiGenerated = true,
  });

  Color get riskColor {
    switch (overallRisk) {
      case 1:
        return const Color(0xFF4CAF50); // Yeşil - Güvenli
      case 2:
        return const Color(0xFF8BC34A); // Açık yeşil - Düşük risk
      case 3:
        return const Color(0xFFFF9800); // Turuncu - Orta risk
      case 4:
        return const Color(0xFFFF5722); // Kırmızı-turuncu - Yüksek risk
      case 5:
        return const Color(0xFFF44336); // Kırmızı - Kritik
      default:
        return const Color(0xFF9E9E9E); // Gri - Bilinmiyor
    }
  }

  IconData get riskIcon {
    switch (overallRisk) {
      case 1:
        return Icons.check_circle;
      case 2:
        return Icons.info;
      case 3:
        return Icons.warning;
      case 4:
        return Icons.error;
      case 5:
        return Icons.dangerous;
      default:
        return Icons.help;
    }
  }
}

class InteractionPair {
  final DrugInfo drug1;
  final DrugInfo drug2;
  final int severity; // 1-5
  final String description;
  final String mechanism;
  final List<String> symptoms;
  final String recommendation;

  InteractionPair({
    required this.drug1,
    required this.drug2,
    required this.severity,
    required this.description,
    required this.mechanism,
    required this.symptoms,
    required this.recommendation,
  });

  Color get severityColor {
    switch (severity) {
      case 1:
        return const Color(0xFF4CAF50);
      case 2:
        return const Color(0xFF8BC34A);
      case 3:
        return const Color(0xFFFF9800);
      case 4:
        return const Color(0xFFFF5722);
      case 5:
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String get severityText {
    switch (severity) {
      case 1:
        return 'Minimal';
      case 2:
        return 'Düşük';
      case 3:
        return 'Orta';
      case 4:
        return 'Yüksek';
      case 5:
        return 'Kritik';
      default:
        return 'Bilinmiyor';
    }
  }
}
