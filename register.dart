import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(32, 63, 129, 1.0),
        ),
      ),
      home: const RegMain(),
    );
  }
}

class RegMain extends StatefulWidget {
  const RegMain({super.key});

  @override
  State<RegMain> createState() => _RegMainState();
}

class _RegMainState extends State<RegMain> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Register",
          style: TextStyle(
            fontFamily: 'RobotoSlab',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Gradient background
      Container(
      decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
        Colors.black,
        Color(0xFF500E10), // Dark cherry red
        ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      ),
    ),
      ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white, // White border color
                  width: 0.50,         // Border width
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Create Your Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(nameController, "Full Name", Icons.person, "Name is required."),
                      const SizedBox(height: 15),
                      _buildTextField(emailController, "Email", Icons.email, "Valid email is required."),
                      const SizedBox(height: 15),
                      _buildPhoneField(phoneController),
                      const SizedBox(height: 15),
                      _buildTextField(usernameController, "Username", Icons.account_circle, "Username is required."),
                      const SizedBox(height: 15),
                      _buildPasswordField(passwordController),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: const Color(0xFF3B0B0E), // Darkest cherry red
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _sendData();
                          }
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Ensures text is white
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildTextField(TextEditingController controller, String label, IconData icon, String errorText) {
  //   return TextFormField(
  //     controller: controller,
  //     style: const TextStyle(color: Colors.white),
  //     decoration: InputDecoration(
  //       labelText: label,
  //       labelStyle: const TextStyle(color: Colors.white70),
  //       prefixIcon: Icon(icon, color: Colors.white70),
  //       filled: true,
  //       fillColor: Colors.black.withOpacity(0.4),
  //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(15),
  //         borderSide: const BorderSide(color: Colors.white30),
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(15),
  //         borderSide: const BorderSide(color: Colors.white),
  //       ),
  //     ),
  //     validator: (value) => value == null || value.isEmpty ? errorText : null,
  //   );
  // }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String errorText) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.black.withOpacity(0.4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      validator: (value) {
        if (label == "Email") {
          if (value == null || value.isEmpty) return 'Enter Valid Email';
          if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$").hasMatch(value)) return 'Enter valid email';
        } else {
          return value == null || value.isEmpty ? errorText : null;
        }
        return null;
      },
    );
  }




  Widget _buildPhoneField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Phone Number",
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.phone, color: Colors.white70),
        filled: true,
        fillColor: Colors.black.withOpacity(0.4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Phone number is required.";
        if (!RegExp(r'^\d{10}$').hasMatch(value)) return "Enter a valid 10-digit phone number.";
        return null;
      },
    );
  }

  Widget _buildPasswordField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      validator: (value) => value == null || value.length < 8 ? "Password must be at least 8 characters." : null,
    );
  }

  Future<void> _sendData() async {
    try {
      String url = (await SharedPreferences.getInstance()).getString('url') ?? '';
      var response = await http.post(
        Uri.parse(url+'Androidregistration'),
        body: {
          'name': nameController.text,
          'email': emailController.text,
          'phno': phoneController.text,
          'uname': usernameController.text,
          'password': passwordController.text,
        },
      );
      var responseData = json.decode(response.body);
      if (responseData['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Registration successful.", toastLength: Toast.LENGTH_SHORT);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
      } else {
        Fluttertoast.showToast(msg: "Registration failed.", toastLength: Toast.LENGTH_SHORT);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e", toastLength: Toast.LENGTH_SHORT);
    }
  }
}
