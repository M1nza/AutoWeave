import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PromptPage extends StatefulWidget {
  @override
  _PromptPageState createState() => _PromptPageState();
}

class _PromptPageState extends State<PromptPage> {
  final TextEditingController _promptController = TextEditingController();
  bool isSubmitting = false;

  Future<void> userAddDesign(String prompt, int loginId) async {
    setState(() {
      isSubmitting = true;
    });

    try {
      // Get base URL from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String url = prefs.getString('url') ?? '';
      String lid = prefs.getString('lid') ?? '';

      // Send API request
      final response = await http.post(
        Uri.parse(url + "user_adddesign"),
        body: {
          'prompt': prompt,
          'lid': lid,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['task'] == 'valid') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Prompt submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _promptController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit prompt!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('Server error');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Styled text box
                  TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      hintText: 'Enter your prompt here...',
                      hintStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF500E10), width: 2),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  // Submit button
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                      final prompt = _promptController.text.trim();
                      if (prompt.isNotEmpty) {
                        userAddDesign(prompt, 1); // Replace `1` with dynamic loginId
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a prompt!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF500E10), // Button background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isSubmitting
                        ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : Text(
                      'Submit',
                      style: TextStyle(color: Colors.white), // White text color
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PromptPage(),
  ));
}
