class AvailabilityEntity {
  final String id;
  final String facultyId;
  final String day;
  final String startTime;
  final String endTime;
  final bool isActive;

  AvailabilityEntity({
    required this.id,
    required this.facultyId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory AvailabilityEntity.fromMap(Map<String, dynamic> map) {
    return AvailabilityEntity(
      id: map['id'] as String,
      facultyId: map['faculty_id'] as String,
      day: map['day'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      isActive: map['is_active'] as bool,
    );
  }
}
