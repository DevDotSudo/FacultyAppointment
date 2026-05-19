import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final String requiredRole;

  const RoleGuard({super.key, required this.child, required this.requiredRole});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final state = authCubit.state;

    if (state is AuthSuccess) {
      final userRole = state.user.role.name;
      if (userRole != requiredRole) {
        // Redirect to appropriate dashboard if wrong role
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final targetRoute = userRole == 'student'
              ? '/student/dashboard'
              : '/faculty/dashboard';
          context.go(targetRoute);
        });
        return const SizedBox.shrink();
      }
    }

    return child;
  }
}