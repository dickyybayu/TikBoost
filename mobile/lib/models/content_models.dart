import 'package:flutter/material.dart';

class ContentSuggestion {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  
  const ContentSuggestion({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

class LiveSession {
  final String id;
  final String title;
  final DateTime scheduledTime;
  final String description;
  final Color color;
  final SessionStatus status;
  
  const LiveSession({
    required this.id,
    required this.title,
    required this.scheduledTime,
    required this.description,
    required this.color,
    this.status = SessionStatus.scheduled,
  });
  
  String get formattedTime {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    
    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(scheduledTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow, ${_formatTime(scheduledTime)}';
    } else {
      return '${_formatDate(scheduledTime)}, ${_formatTime(scheduledTime)}';
    }
  }
  
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
  
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

enum SessionStatus { scheduled, live, completed, cancelled }

typedef VoidCallback = void Function();
