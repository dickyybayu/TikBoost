class MetricData {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final String icon;
  
  const MetricData({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
  });
}

class AIRecommendation {
  final String title;
  final String description;
  final String actionText;
  final VoidCallback? onAction;
  
  const AIRecommendation({
    required this.title,
    required this.description,
    required this.actionText,
    this.onAction,
  });
}

typedef VoidCallback = void Function();
