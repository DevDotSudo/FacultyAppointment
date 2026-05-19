import 'package:cloud_firestore/cloud_firestore.dart';

class AvailabilityEntity {
  final String id;
  final String facultyId;
  final String day;
  final String startTime;
  final String endTime;
  final bool isActive;
  // New fields
  final DateTime? date;
  final String consultationType; // 'online' | 'face-to-face'
  final String locationOrLink;
  final int maxSlots;
  final int bookedSlots;

  AvailabilityEntity({
    required this.id,
    required this.facultyId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    this.date,
    this.consultationType = 'face-to-face',
    this.locationOrLink = '',
    this.maxSlots = 1,
    this.bookedSlots = 0,
  });

  int get remainingSlots => maxSlots - bookedSlots;
  bool get isFullyBooked => remainingSlots <= 0;

  factory AvailabilityEntity.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? date;
    final rawDate = map['date'];
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is String && rawDate.isNotEmpty) {
      date = DateTime.tryParse(rawDate);
    }

    return AvailabilityEntity(
      id: docId,
      facultyId: map['faculty_id'] as String? ?? '',
      day: map['day'] as String? ?? '',
      startTime: map['start_time'] as String? ?? '',
      endTime: map['end_time'] as String? ?? '',
      isActive: map['is_active'] as bool? ?? true,
      date: date,
      consultationType: map['consultation_type'] as String? ?? 'face-to-face',
      locationOrLink: map['location_or_link'] as String? ?? '',
      maxSlots: (map['max_slots'] as num?)?.toInt() ?? 1,
      bookedSlots: (map['booked_slots'] as num?)?.toInt() ?? 0,
    );
  }
}
