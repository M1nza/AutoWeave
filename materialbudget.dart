import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserBudgetPage extends StatefulWidget {

  const UserBudgetPage({Key? key}) : super(key: key);


  @override
  _UserBudgetPageState createState() => _UserBudgetPageState();
}

class _UserBudgetPageState extends State<UserBudgetPage> {
  final TextEditingController designNameController = TextEditingController();
  bool isLoading = false;
  List<dynamic> budgets = [];
  List<dynamic> Details = [];
  String? materialName;
  List<dynamic> filteredBudgets = [];
_UserBudgetPageState()
{
  fetchBudgets();
}
  // Fetch budgets from API
  Future<void> fetchBudgets() async {
    // setState(() {
    //   isLoading = true;
    // });
print("okkkkkkkkkkkkkkk");
    try {
      String url = (await SharedPreferences.getInstance()).getString('url') ?? '';
      final response = await http.post(
        Uri.parse(url + "user_budget"),
        // No design_name sent in the body now
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          setState(()

          {
            Details=data["data"];
            // for (int i = 0; i < Details.length; i++) {
            //
            // }// Assuming the budgets data is under 'data' key
            // filteredBudgets = List.from(Details); // Initialize filtered list
          });
        } else {
          showSnackBar('Failed to fetch data!', Colors.red);
        }
      } else {
        showSnackBar('Server error. Please try again later!', Colors.red);
      }
    } catch (error) {
      showSnackBar('Error: $error', Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
Future<void> searchBudgets() async {
    // setState(() {
    //   isLoading = true;
    // });
print("okkkkkkkkkkkkkkk");
    try {
      String url = (await SharedPreferences.getInstance()).getString('url') ?? '';
      final response = await http.post(
        Uri.parse(url + "user_budget_search"),body: {
          "s":designNameController.text
      }
        // No design_name sent in the body now
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          setState(()

          {
            Details=data["data"];
            // for (int i = 0; i < Details.length; i++) {
            //
            // }// Assuming the budgets data is under 'data' key
            // filteredBudgets = List.from(Details); // Initialize filtered list
          });
        } else {
          showSnackBar('Failed to fetch data!', Colors.red);
        }
      } else {
        showSnackBar('Server error. Please try again later!', Colors.red);
      }
    } catch (error) {
      showSnackBar('Error: $error', Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
Future<void> bookingfn(String mid,String did) async {
    // setState(() {
    //   isLoading = true;
    // });
print("okkkkkkkkkkkkkkk");
    try {
      String url = (await SharedPreferences.getInstance()).getString('url') ?? '';
      String lid = (await SharedPreferences.getInstance()).getString('lid') ?? '';
      final response = await http.post(
        Uri.parse(url + "user_booking"),body: {
          "lid":lid,"did":did,"mid":mid
      }
        // No design_name sent in the body now
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['task'] == 'valid') {
          setState(()

          {
            showSnackBar('Booked Successfully !', Colors.green);
          });
        } else {
          showSnackBar('Failed to fetch data!', Colors.red);
        }
      } else {
        showSnackBar('Server error. Please try again later!', Colors.red);
      }
    } catch (error) {
      showSnackBar('Error: $error', Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Filter budgets based on search query
  void filterBudgets(String query) {
    setState(() {
      filteredBudgets = budgets.where((budget) {
        return budget['mname'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Show SnackBar message
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
        // title: const Text(
        //   'User Budget',
        //   style: TextStyle(fontWeight: FontWeight.bold),
        // ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              const Color(0xFF500E10), // Dark Cherry Red
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
        Center(
          child:
          // SingleChildScrollView(
          //   padding: const EdgeInsets.all(16.0),
          //   child:
            Card(
              color: Colors.black.withOpacity(0.7),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white, width: 1.0),

              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child:

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Enter Design Name',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: designNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Design Name',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: 'Enter Design Name',
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF500E10), // Dark Cherry Red
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.grey),

                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                        searchBudgets();
                      },
                      child: isLoading
                          ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                          : const Text(
                        'Fetch Budgets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (materialName != null)
                      Text(
                        'Material: $materialName',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Search Bar to filter results

                    Expanded(
                      child: ListView.builder(
                        itemCount: Details.length,
                        itemBuilder: (context, index) {
                          final budget = Details[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            color: Colors.black.withOpacity(0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.white, width: 1.0),
                            ),
                            child: ListTile(
                              title: Text(
                                'Material: ${budget['mname']}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Design: ${budget['design']}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),Text(
                                    'Expert: ${budget['expert']}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    'Amount: ${budget['amount']}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                              trailing:
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF500E10), // Dark Cherry Red
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: Colors.grey),
                                  ),
                                ),
                                onPressed:  () {

                                  bookingfn(budget['id'].toString(),budget['eid'].toString());

                                },
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                                    : const Text(
                                  'Book',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // ), //scroll view =======
        ),
      ),
    );
  }
}
