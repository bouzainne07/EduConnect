import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/students/presentation/students_list_screen.dart';
import '../features/students/presentation/student_detail_screen.dart';
import '../features/students/presentation/student_form_screen.dart';
import '../features/teachers/presentation/teachers_list_screen.dart';
import '../features/classes/presentation/classes_list_screen.dart';
import '../features/parents/presentation/parents_list_screen.dart';
import '../features/classes/presentation/subjects_list_screen.dart';
import '../features/schedules/presentation/schedule_calendar_screen.dart';
import '../features/grades/presentation/grades_list_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authValue = authState.valueOrNull;

      // Encore en chargement → reste sur splash
      if (authState.isLoading || authValue == null) {
        return state.matchedLocation == '/splash' ? null : '/splash';
      }

      final isAuthenticated = authValue.isAuthenticated;
      final location = state.matchedLocation;
      final onAuthScreen = location == '/login' || location == '/splash';

      if (!isAuthenticated && !onAuthScreen) return '/login';
      if (!isAuthenticated && location == '/splash') return '/login';
      if (isAuthenticated && onAuthScreen) {
        return _dashboardRoute(authValue.role);
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      // Dashboard par rôle
      GoRoute(
        path: '/dashboard/admin',
        builder: (_, __) => const DashboardScreen(role: 'ADMIN'),
      ),
      GoRoute(
        path: '/dashboard/directeur',
        builder: (_, __) => const DashboardScreen(role: 'DIRECTEUR'),
      ),
      GoRoute(
        path: '/dashboard/enseignant',
        builder: (_, __) => const DashboardScreen(role: 'ENSEIGNANT'),
      ),
      GoRoute(
        path: '/dashboard/eleve',
        builder: (_, __) => const DashboardScreen(role: 'ELEVE'),
      ),
      GoRoute(
        path: '/dashboard/parent',
        builder: (_, __) => const DashboardScreen(role: 'PARENT'),
      ),
      GoRoute(
        path: '/dashboard/surveillant',
        builder: (_, __) => const DashboardScreen(role: 'SURVEILLANT'),
      ),
      // Élèves
      GoRoute(
        path: '/students',
        builder: (_, __) => const StudentsListScreen(),
      ),
      GoRoute(
        path: '/students/:id',
        builder: (_, state) => StudentDetailScreen(
          studentId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/students/new',
        builder: (_, __) => const StudentFormScreen(),
      ),
      // Enseignants
      GoRoute(
        path: '/teachers',
        builder: (_, __) => const TeachersListScreen(),
      ),
      // Classes
      GoRoute(
        path: '/classes',
        builder: (_, __) => const ClassesListScreen(),
      ),
      // Parents
      GoRoute(
        path: '/parents',
        builder: (_, __) => const ParentsListScreen(),
      ),
      // Matières
      GoRoute(
        path: '/subjects',
        builder: (_, __) => const SubjectsListScreen(),
      ),
      // Emploi du temps
      GoRoute(
        path: '/schedule',
        builder: (_, __) => const ScheduleCalendarScreen(),
      ),
      // Notes & Bulletin
      GoRoute(
        path: '/grades',
        builder: (_, __) => const GradesListScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page introuvable : ${state.uri}')),
    ),
  );
});

String _dashboardRoute(String? role) {
  switch (role?.toUpperCase()) {
    case 'ADMIN':
      return '/dashboard/admin';
    case 'DIRECTEUR':
      return '/dashboard/directeur';
    case 'ENSEIGNANT':
      return '/dashboard/enseignant';
    case 'ELEVE':
      return '/dashboard/eleve';
    case 'PARENT':
      return '/dashboard/parent';
    case 'SURVEILLANT':
      return '/dashboard/surveillant';
    default:
      return '/login';
  }
}
