class DrugAnalysisCard {
  final String title;
  final String content;
  final String icon;
  final String color;
  final int priority;

  DrugAnalysisCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
    required this.priority,
  });

  factory DrugAnalysisCard.fromJson(Map<String, dynamic> json) {
    return DrugAnalysisCard(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      icon: json['icon'] ?? 'info',
      color: json['color'] ?? '#4A90A4',
      priority: json['priority'] ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'icon': icon,
      'color': color,
      'priority': priority,
    };
  }
}

class EnhancedDrugAnalysis {
  final String drugName;
  final List<DrugAnalysisCard> cards;
  final DateTime createdAt;

  EnhancedDrugAnalysis({
    required this.drugName,
    required this.cards,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory EnhancedDrugAnalysis.fromJson(Map<String, dynamic> json) {
    return EnhancedDrugAnalysis(
      drugName: json['drugName'] ?? '',
      cards: (json['cards'] as List?)
          ?.map((cardJson) => DrugAnalysisCard.fromJson(cardJson))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drugName': drugName,
      'cards': cards.map((card) => card.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Get cards sorted by priority
  List<DrugAnalysisCard> get sortedCards {
    final sortedList = List<DrugAnalysisCard>.from(cards);
    sortedList.sort((a, b) => a.priority.compareTo(b.priority));
    return sortedList;
  }
}
