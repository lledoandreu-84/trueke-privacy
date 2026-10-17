import 'package:flutter/material.dart';

@immutable
class SettingsModel {
  final String themeMode; // 'light', 'dark', 'system'
  final bool pushNotificationsEnabled;

  const SettingsModel({
    required this.themeMode,
    required this.pushNotificationsEnabled,
  });

  SettingsModel copyWith({String? themeMode, bool? pushNotificationsEnabled}) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode,
      'pushNotificationsEnabled': pushNotificationsEnabled,
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      themeMode: map['themeMode'] as String? ?? 'system',
      pushNotificationsEnabled:
          map['pushNotificationsEnabled'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsModel &&
        other.themeMode == themeMode &&
        other.pushNotificationsEnabled == pushNotificationsEnabled;
  }

  @override
  int get hashCode => themeMode.hashCode ^ pushNotificationsEnabled.hashCode;
}
