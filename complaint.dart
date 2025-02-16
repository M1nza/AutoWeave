import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SubmitComplaintPage extends StatefulWidget {
  const SubmitComplaintPage({Key? key}) : super(key: key);

  @override
  _SubmitComplaintPageState createState() => _SubmitComplaintPageState();
}

class _SubmitComplaintPageState extends State<SubmitComplaintPage> {
  final TextEditingController _complaintController = TextEditingController();
  bool isSubmitting = false;
  List<Map<String, String>> complaints = []; // To store complaints and replies

  Future<void> submitComplaint(String complaint, int loginId) async {
    setState(() {
      isSubmitting = true;
    });

    try {
      String url = (await SharedPreferences.getInstance()).getString('url') ?? '';
      String loginId = (await SharedPreferences.getInstance()).getString('lid') ?? '';
      final response = await http.post(
        Uri.parse(url + "user_complaint"),
        body: {
          'complaint': complaint,
          'lid': loginId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['task'] == 'ok') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _complaintController.clear();
          // Update complaints list locally
          setState(() {
            complaints.add({'complaint': complaint, 'reply': 'Pending reply'});
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit complaint!'),
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
      appBar: AppBar(
        title: const Text(
          'Submit Complaint',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              const Color(0xFF500E10), // Dark cherry red
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  color: Colors.black.withOpacity(0.7),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Drop your complaints here!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _complaintController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Your Complaints',
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintText: 'Enter your Complaint here...',
                            hintStyle: const TextStyle(color: Colors.white38),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                          maxLines: 5, // Adjusted max lines
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () {
                              final complaint = _complaintController.text.trim();
                              if (complaint.isNotEmpty) {
                                submitComplaint(complaint, 1); // Replace 1 with actual login ID
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Complaint cannot be empty'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF500E10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isSubmitting
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              'Submit',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Display complaints and replies
                ...complaints.map((item) {
                  return Card(
                    color: Colors.black.withOpacity(0.5),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        item['complaint']!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Reply: ${item['reply']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
