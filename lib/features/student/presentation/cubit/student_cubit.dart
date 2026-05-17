import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'student_state.dart';
import 'package:faculty_appointment/features/student/domain/usecases/get_upcoming_appointments_usecase.dart';
import 'package:faculty_appointment/features/student/domain/usecases/get_faculty_list_usecase.dart';
import 'package:faculty_appointment/features/student/domain/entities/upcoming_appointment_data.dart';
import 'package:faculty_appointment/features/student/domain/entities/faculty_data.dart';

class StudentCubit extends Cubit<StudentState> {
  final GetUpcomingAppointmentsUseCase _getUpcomingAppointments;
  final GetFacultyListUseCase _getFacultyList;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StudentCubit(this._getUpcomingAppointments, this._getFacultyList) : super(StudentInitial());

  void loadDashboard() async {
    emit(StudentLoading());
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        emit(StudentError('Not authenticated'));
        return;
      }

      final appointments = await _getUpcomingAppointments(userId);
      final facultyList = await _getFacultyList();

      int totalAppointments = 0;
      int pending = 0;
      int accepted = 0;
      int rejected = 0;

      final allSnapshots = await _firestore
          .collection('appointment_requests')
          .where('student_id', isEqualTo: userId)
          .get();

      for (var doc in allSnapshots.docs) {
        totalAppointments++;
        final status = doc.data()['status'] as String;
        if (status == 'pending') {
          pending++;
        } else if (status == 'accepted') {
          accepted++;
        } else if (status == 'rejected') {
          rejected++;
        }
      }

      emit(StudentLoaded(
        totalAppointments: totalAppointments,
        pending: pending,
        accepted: accepted,
        rejected: rejected,
      upcomingAppointments: appointments
          .map((a) => UpcomingAppointmentData(
                facultyName: a.facultyName,
                facultyInitials: a.facultyInitials,
                date: a.date,
                time: a.time,
                purpose: a.purpose,
                status: a.status,
              ))
          .toList(),
        facultyList: facultyList
          .map((f) => FacultyData(
                id: f.id,
                name: f.fullName,
                department: f.department,
                specialization: f.specialization,
                officeLocation: f.officeLocation,
              ))
          .toList(),
      ));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }
}
