import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_manager_pro/core/constants/utils/notification_util.dart';
import 'package:todo_manager_pro/state/task_provider.dart';
import 'package:todo_manager_pro/state/label_provider.dart';
import 'package:todo_manager_pro/routes/app_routes.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationUtil.initialize();
  tz.initializeTimeZones();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userPin = prefs.getString('userPin');
  runApp(TodoManagerPro(userPin: userPin));
}

class TodoManagerPro extends StatelessWidget {
  final String? userPin;

  TodoManagerPro({required this.userPin});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => LabelProvider()),
      ],
      child: MaterialApp(
        title: 'Todo Manager Pro',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute:
            userPin == null ? AppRoutes.setUpPin : AppRoutes.verifyPin,
        routes: AppRoutes.routes,
      ),
    );
  }
}
