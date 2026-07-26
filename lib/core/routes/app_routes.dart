import 'package:flutter/material.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/registration_screen.dart';
import '../../features/dashboard/screens/driver_dashboard_screen.dart';
import '../../features/dashboard/screens/parent_dashboard_screen.dart';
import '../../features/attendance/screens/qr_scanner_screen.dart';
import '../../features/payments/screens/parent_payment_screen.dart';
import '../../features/payments/screens/driver_earnings_screen.dart';

import '../../features/connections/screens/all_drivers_screen.dart';
import '../../features/connections/screens/connect_driver_screen.dart';
import '../../features/connections/screens/connection_requests_screen.dart';
import '../../features/chat/screens/chat_list_screen.dart';
import '../../features/leave/screens/apply_leave_screen.dart';
import '../../features/leave/screens/leave_management_screen.dart';
import '../../features/complaints/screens/complaints_list_screen.dart';
import '../../features/reports/screens/reports_screen.dart';

import '../../features/dashboard/screens/edit_child_screen.dart';
import '../../features/dashboard/screens/driver_account_settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String driverDashboard = '/driverDashboard';
  static const String parentDashboard = '/parentDashboard';
  static const String qrScanner = '/qrScanner';
  static const String parentPayment = '/parentPayment';
  static const String driverEarnings = '/driverEarnings';
  static const String allDrivers = '/allDrivers';
  static const String connectDriver = '/connectDriver';
  static const String connectionRequests = '/connectionRequests';
  static const String chatList = '/chatList';
  static const String applyLeave = '/applyLeave';
  static const String leaveManagement = '/leaveManagement';
  static const String complaintsList = '/complaintsList';
  static const String reports = '/reports';
  static const String editChild = '/editChild';
  static const String driverAccountSettings = '/driverAccountSettings';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      welcome: (context) => const WelcomeScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegistrationScreen(),
      driverDashboard: (context) => const DriverDashboardScreen(),
      parentDashboard: (context) => const ParentDashboardScreen(),
      qrScanner: (context) => const QRScannerScreen(),
      parentPayment: (context) => const ParentPaymentScreen(),
      driverEarnings: (context) => const DriverEarningsScreen(),
      allDrivers: (context) => const AllDriversScreen(),
      connectDriver: (context) => const ConnectDriverScreen(),
      connectionRequests: (context) => const ConnectionRequestsScreen(),
      chatList: (context) => const ChatListScreen(),
      applyLeave: (context) => const ApplyLeaveScreen(),
      leaveManagement: (context) => const LeaveManagementScreen(),
      complaintsList: (context) => const ComplaintsListScreen(),
      reports: (context) => const ReportsScreen(),
      editChild: (context) => const EditChildScreen(),
      driverAccountSettings: (context) => const DriverAccountSettingsScreen(),
    };
  }
}
