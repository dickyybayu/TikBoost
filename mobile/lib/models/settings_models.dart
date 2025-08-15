import 'package:flutter/material.dart';

class SettingsItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDivider;
  
  const SettingsItem({
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.trailing,
    this.showDivider = true,
  });
}

class SettingsSection {
  final String title;
  final List<SettingsItem> items;
  
  const SettingsSection({
    required this.title,
    required this.items,
  });
}

enum NotificationFrequency { all, important, none }

class AppSettings {
  final bool darkMode;
  final bool pushNotifications;
  final NotificationFrequency notificationFrequency;
  final bool biometricAuth;
  final String language;
  final String currency;
  
  const AppSettings({
    this.darkMode = true,
    this.pushNotifications = true,
    this.notificationFrequency = NotificationFrequency.all,
    this.biometricAuth = false,
    this.language = 'English',
    this.currency = 'USD',
  });
  
  AppSettings copyWith({
    bool? darkMode,
    bool? pushNotifications,
    NotificationFrequency? notificationFrequency,
    bool? biometricAuth,
    String? language,
    String? currency,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      notificationFrequency: notificationFrequency ?? this.notificationFrequency,
      biometricAuth: biometricAuth ?? this.biometricAuth,
      language: language ?? this.language,
      currency: currency ?? this.currency,
    );
  }
}

typedef VoidCallback = void Function();
