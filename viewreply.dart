import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ViewComplaintsPage extends StatefulWidget {
  const ViewComplaintsPage({Key? key}) : super(key: key);

  @override
  _ViewComplaintsPageState createState() => _ViewComplaintsPageState();
}

class _ViewComplaintsPageState extends State<ViewComplaintsPage> {
  bool isLoading = true;
  bool isSubmitting = false;
  List<Map<String, String>> complaints = [];
  String? errorMessage;
  TextEditingController _complaintController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadComplaints();
  }

  Future<void> loadComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedComplaints = prefs.getString('complaints');
    fetchComplaints();
    // if (cachedComplaints != null) {
    //   // If complaints are already cached, use them
    //   setState(() {
    //     complaints = List<Map<String, String>>.from(
    //         json.decode(cachedComplaints).map((item) =>
    //         Map<String, String>.from(item)
    //         )
    //     );
    //     isLoading = false;
    //   });
    // } else {
    //   // Otherwise, fetch complaints from the server
    //   fetchComplaints();
    // }
  }


  Future<void> fetchComplaints() async {
    try {
      String url = (await SharedPreferences.getInstance()).getString('url') ?? '';
      String loginId = (await SharedPreferences.getInstance()).getString('lid') ?? '';
      final response = await http.get(Uri.parse(url + "/get_user_complaints?lid=$loginId"));
      print(response);
      print('responseaaaa');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'ok') {
          setState(() {
            complaints = List<Map<String, String>>.from(
              data['complaints'].map((item) {
                // Ensure all values are strings
                return {
                  'complaint': item['complaint'].toString(),
                  'reply': item['reply'].toString(),
                  'date': item['date'].toString(),
                };
              }),
            );
            isLoading = false;

            // Save the complaints in SharedPreferences for future use
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('complaints', json.encode(complaints));
            });
          });
        }
        else {
          setState(() {
            errorMessage = 'Failed to fetch complaints.';
            isLoading = false;
          });
        }
      } else {
        throw Exception('Server error');
      }
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  // Submit a new complaint
  Future<void> submitComplaint(String complaint) async {
    setState(() {
      isSubmitting = true;
    });

    try {
      String url = (await SharedPreferences.getInstance()).getString('url') ?? '';
      String loginId = (await SharedPreferences.getInstance()).getString('lid') ?? '';
      final response = await http.post(
        Uri.parse(url + "submit_complaint"),
        body: {
          'lid': loginId,
          'complaint': complaint,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // if (data['task'] == 'ok') {
        //   setState(() {
        //     complaints.add({
        //       'complaint': complaint,
        //       'reply': 'Pending',
        //       'date': DateTime.now().toString(),
        //     });
        //     isSubmitting = false;
        //     _complaintController.clear();
        //     // Save updated complaints list to SharedPreferences
        //     SharedPreferences.getInstance().then((prefs) {
        //       prefs.setString('complaints', json.encode(complaints));
        //     });
        //   });
        // } else {
        //   setState(() {
        //     errorMessage = 'Failed to submit complaint.';
        //     isSubmitting = false;
        //   });
        // }
      } else {
        throw Exception('Server error');
      }
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Complaints',
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
              Color(0xFF500E10), // Dark cherry red
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : errorMessage != null
            ? Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        )
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.black.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.grey, width: 1.5),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Drop your complaint here!',
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
                          labelText: 'Your Complaint',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'Enter your complaint...',
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
                        maxLines: 5,
                      ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity, // Makes the button responsive and well-aligned
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () {
                        final complaint = _complaintController.text.trim();
                        if (complaint.isNotEmpty) {
                          submitComplaint(complaint);
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
                        padding: const EdgeInsets.symmetric(vertical: 18), // Slightly larger padding for a premium feel
                        backgroundColor: const Color(0xFF500E10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Slightly increased border radius for a modern touch
                        ),
                      ),
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Submit Complaint',
                        style: TextStyle(
                          fontSize: 18, // Slightly increased font size for better readability
                          fontWeight: FontWeight.w600, // Medium-bold weight for a premium feel
                          color: Colors.white, // Changed from grey to white for better contrast
                          letterSpacing: 0.5, // Adds a slight spacing for a refined look
                        ),
                      ),
                    ),
                  ),
                    ]
                ),
                ),
              ),
            ),
            // Display complaints and replies
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final complaint = complaints[index];
                  return Card(
                    color: Colors.black.withOpacity(0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Complaint:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            // complaint['reply'] ?? '',
                            complaint['complaint'] ?? '',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Reply:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            complaint['reply'] ?? 'Pending',
                            // 'Reply: ${complaint['complaint'] ?? ''}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Date: ${complaint['date'] ?? ''}',
                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
