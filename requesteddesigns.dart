import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';
import 'make_payment.dart';

class RequestedDesignsPage extends StatefulWidget {
  @override
  _RequestedDesignsPageState createState() => _RequestedDesignsPageState();
}

class _RequestedDesignsPageState extends State<RequestedDesignsPage> {
  List<dynamic> requestedDesigns = [];
  bool isLoading = false;
  String urlimg = "";

  @override
  void initState() {
    super.initState();
    fetchRequestedDesigns();
  }

  Future<void> fetchRequestedDesigns() async {
    final sh = await SharedPreferences.getInstance();
    String url = sh.getString("url") ?? "";
    urlimg = sh.getString("url") ?? "";
    String lid = sh.getString("lid") ?? "";
    final response = await http.post(
      Uri.parse(url + "viewuser_requests"),
      body: {'lid': lid},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'ok') {
        setState(() {
          requestedDesigns = data['data'];
        });
      } else {
        throw Exception('Failed to load requests');
      }
    } else {
      throw Exception('Failed to communicate with the server');
    }
  }

  Future<void> deleteRequestedDesign(String designId) async {
    final sh = await SharedPreferences.getInstance();
    String url = sh.getString("url") ?? "";

    try {
      final response = await http.post(
        Uri.parse(url + "request_delete"),
        body: {'design_id': designId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          // setState(() {
          //   requestedDesigns.removeWhere((design) => design['id'] == designId);
          // });
          showSnackBar("Design deleted successfully", Colors.green);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RequestedDesignsPage()),
          );

        } else {
          showSnackBar("Failed to delete design", Colors.red);
        }
      } else {
        showSnackBar("Server error, try again later", Colors.red);
      }
    } catch (e) {
      showSnackBar("An error occurred: $e", Colors.red);
    }
  }

  Future<void> viewDesignInfo(String designId) async {
    final sh = await SharedPreferences.getInstance();
    String url = sh.getString("url") ?? "";

    try {
      final response = await http.post(
        Uri.parse(url + "view_design_info"),
        body: {'design_id': designId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          // Here, you're fetching the materials data and showing it in a dialog
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Design Info"),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Looping through the list of materials and displaying them
                    for (var material in data['data'])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Material: ${material['MATERIALS']}\n'
                              'Amount: ${material['amount']}\n'
                              'Details: ${material['details']}\n'
                              'Date: ${material['date']}\n',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
        } else {
          showSnackBar("Failed to fetch design info", Colors.red);
        }
      } else {
        showSnackBar("Server error, try again later", Colors.red);
      }
    } catch (e) {
      showSnackBar("An error occurred: $e", Colors.red);
    }
  }


  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requested Designs'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF500E10)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: requestedDesigns.isEmpty
            ? const Center(
          child: Text('No Design available'),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: requestedDesigns.length,
          itemBuilder: (context, index) {
            final budget = requestedDesigns[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.grey, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${budget['id']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        urlimg + budget['design'],
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF500E10),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 48,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${budget['Date']}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'Status:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          budget['Status'],
                          style: TextStyle(
                            color: budget['Status'] == 'accepted'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF500E10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          onPressed: () async {

                            final sh = await SharedPreferences.getInstance();
                            sh.setString("oid", budget["id"].toString());
                            sh.setString("amt", budget["amount"].toString());

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserPaymentScreenPage()),
                            );
                          },
                          child: isLoading
                              ? const CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          )
                              : const Text(
                            'Pay Now',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF500E10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          onPressed: () async {
                            deleteRequestedDesign(budget['id'].toString());
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF500E10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          onPressed: () {
                            viewDesignInfo(budget['designid'].toString());
                          },
                          child: const Text(
                            'View Info',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
