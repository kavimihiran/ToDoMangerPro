import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_manager_pro/core/constants/app_colors.dart';
import 'package:todo_manager_pro/core/constants/utils/screen_size.dart';
import 'package:todo_manager_pro/routes/app_routes.dart';

class SetUpPinScreen extends StatefulWidget {
  @override
  _SetUpPinScreenState createState() => _SetUpPinScreenState();
}

class _SetUpPinScreenState extends State<SetUpPinScreen> {
  final List<TextEditingController> _pinControllers =
      List.generate(4, (index) => TextEditingController());
  final List<TextEditingController> _confirmPinControllers =
      List.generate(4, (index) => TextEditingController());
  String _errorMessage = '';

  Future<void> _savePin() async {
    String pin = _pinControllers.map((controller) => controller.text).join();
    String confirmPin =
        _confirmPinControllers.map((controller) => controller.text).join();

    if (pin == confirmPin) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userPin', pin);
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.home, (route) => false);
    } else {
      setState(() {
        _errorMessage = 'PINs do not match!';
      });
    }
  }

  Widget _buildPinInputField(List<TextEditingController> controllers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 224, 222, 222),
            borderRadius: BorderRadius.circular(8.0),
          ),
          margin: const EdgeInsets.all(12.0),
          width: 50,
          child: TextField(
            controller: controllers[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            obscureText: true,
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (value) {
              if (value.length == 1 && index < 3) {
                FocusScope.of(context).nextFocus();
              }
              if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
            },
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenSize
    ScreenSize.init(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 254, 254),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: ScreenSize.screenWidth,
                height: ScreenSize.screenHeight * 0.5,
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35.0),
                    bottomRight: Radius.circular(35.0),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: ScreenSize.screenHeight * 0.35,
                    ),
                    const Text(
                      'SET UP PIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Enter PIN',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _buildPinInputField(_pinControllers),
              const SizedBox(height: 20),
              const Text(
                'Confirm PIN',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _buildPinInputField(_confirmPinControllers),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: _savePin,
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Save PIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
