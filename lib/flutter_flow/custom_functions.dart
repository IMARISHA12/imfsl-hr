import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';

DateTime? startOfToday() {
  DateTime startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 0, 0, 0);
  }
}

DateTime? endOfToday() {
  DateTime endOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }
}

bool? isLate() {
  bool isLate() {
    final now = DateTime.now();

    // Muda wa kuanza kazi: 07:45 (Saa 1 asubuhi)
    final workStartHour = 8;
    final workStartMinute = 0;

    // Muda wa msamaha (grace period): dakika 15
    final gracePeriodMinutes = 15;

    // Tengeneza deadline ya kuingia (08:00)
    final deadline = DateTime(
      now.year,
      now.month,
      now.day,
      workStartHour,
      workStartMinute + gracePeriodMinutes,
    );

    // Kama saa sasa imepita deadline, amechelewa
    return now.isAfter(deadline);
  }
}

bool? isValidCompanyEmail(String? email) {
  bool isValidCompanyEmail(String email) {
    return email.toLowerCase().endsWith('@imarishamaisha.co.tz');
  }
}

DateTime? extractDobFromNida(String? nidaNumber) {
  DateTime? extractDobFromNida(String nidaNumber) {
    // Remove any dashes or spaces
    String cleanNida = nidaNumber.replaceAll(RegExp(r'[-\s]'), '');

    // Check if we have at least 8 digits
    if (cleanNida.length < 8) {
      return null;
    }

    // Extract first 8 characters (YYYYMMDD)
    String dateStr = cleanNida.substring(0, 8);

    try {
      int year = int.parse(dateStr.substring(0, 4));
      int month = int.parse(dateStr.substring(4, 6));
      int day = int.parse(dateStr.substring(6, 8));

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }
}

String? calculatePunctualityRate(
  int? totalDays,
  int? lateDays,
) {
  // Avoid division by zero
  if (totalDays == null || totalDays == 0) {
    return "0%";
  }

// Handle null lateDays
  int late = lateDays ?? 0;

// Calculate punctuality rate
  double rate = ((totalDays - late) / totalDays) * 100;

// Round to nearest integer and return with %
  return "${rate.round()}%";
}

String? toUTCDisplay(DateTime? dateTime) {
  if (dateTime == null) return '00:00';
  final localTime = dateTime.toLocal();
  final hour = localTime.hour.toString().padLeft(2, '0');
  final minute = localTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
