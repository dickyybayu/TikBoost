class LiveSession {
  final String id;
  final String copywriting;
  final String host;
  final String time;
  final String bundle;
  final bool isAISuggestion;
  final DateTime? scheduledDate;

  LiveSession({
    required this.id,
    required this.copywriting,
    required this.host,
    required this.time,
    required this.bundle,
    this.isAISuggestion = false,
    this.scheduledDate,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'copywriting': copywriting,
      'host': host,
      'time': time,
      'bundle': bundle,
      'isAISuggestion': isAISuggestion,
      'scheduledDate': scheduledDate?.toIso8601String(),
    };
  }

  // Create from JSON
  factory LiveSession.fromJson(Map<String, dynamic> json) {
    return LiveSession(
      id: json['id'] ?? '',
      copywriting: json['copywriting'] ?? '',
      host: json['host'] ?? '',
      time: json['time'] ?? '',
      bundle: json['bundle'] ?? '',
      isAISuggestion: json['isAISuggestion'] ?? false,
      scheduledDate:
          json['scheduledDate'] != null
              ? DateTime.parse(json['scheduledDate'])
              : null,
    );
  }

  // Create a copy with modified fields
  LiveSession copyWith({
    String? id,
    String? copywriting,
    String? host,
    String? time,
    String? bundle,
    bool? isAISuggestion,
    DateTime? scheduledDate,
  }) {
    return LiveSession(
      id: id ?? this.id,
      copywriting: copywriting ?? this.copywriting,
      host: host ?? this.host,
      time: time ?? this.time,
      bundle: bundle ?? this.bundle,
      isAISuggestion: isAISuggestion ?? this.isAISuggestion,
      scheduledDate: scheduledDate ?? this.scheduledDate,
    );
  }
}
