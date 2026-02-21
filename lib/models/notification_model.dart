import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'event' | 'bet' | 'wallet' | 'system'
  final IconData icon;
  final Color iconColor;
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.icon,
    required this.iconColor,
    required this.createdAt,
    this.isRead = false,
  });
}
