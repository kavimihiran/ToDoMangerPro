import 'package:flutter/material.dart';
import 'package:todo_manager_pro/presentation/screens/home_screen.dart';
import 'package:todo_manager_pro/presentation/screens/add_task_screen.dart';
import 'package:todo_manager_pro/presentation/screens/setuppin_screen.dart';
import 'package:todo_manager_pro/presentation/screens/verifypin_screen.dart';

class AppRoutes {
  static const home = '/';
  static const addTask = '/add-task';
  static const editTask = '/edit-task';
  static const setUpPin = '/set-up-pin';
  static const verifyPin = '/verify-pin';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => HomeScreen(),
      addTask: (context) => AddTaskScreen(),
      setUpPin: (context) => SetUpPinScreen(),
      verifyPin: (context) => VerifyPinScreen(),
    };
  }
}
