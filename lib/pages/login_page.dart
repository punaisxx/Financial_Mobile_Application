import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; 
    final buttonWidth = screenWidth * 0.8; 

    return Scaffold(
      backgroundColor: const Color(0xFF9A7AF7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 48.0),
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 120,
                            width: 120,
                          ),
                        ),
                      ),

                      Expanded(flex: 1, child: SizedBox()),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: const Text(
                            'The easiest way to\nswap crypto',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      Expanded(flex: 1, child: SizedBox()),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Obx(() => SizedBox(
                              width: buttonWidth, 
                              height: 56, 
                              child: ElevatedButton.icon(
                                onPressed: authController.isLoading.value
                                    ? null
                                    : authController.signInWithGoogle,
                                icon: Image.asset(
                                  'assets/images/google.png',
                                  height: 24,
                                  width: 24,
                                ),
                                label: Text(
                                  authController.isLoading.value
                                      ? 'Signing in...'
                                      : 'Sign in with Google',
                                  style: TextStyle(fontSize: 18),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            )),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text.rich(
                          TextSpan(
                            text: 'By tapping continue, you agree to own\n',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
