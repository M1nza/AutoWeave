import 'package:autoweave/login.dart';
import 'package:flutter/material.dart';
import 'package:autoweave/payment.dart';
import 'package:autoweave/viewreply.dart';
import 'package:autoweave/feedback.dart';
import 'package:autoweave/materialbudget.dart';
import 'package:autoweave/requesteddesigns.dart';
import 'package:autoweave/password.dart';
import 'package:autoweave/adddesigns.dart';
import 'package:autoweave/viewdesigns.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "user";
  String email = "user";
  final TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setUrl();
  }

  // Function to load the username and email from SharedPreferences
  Future<void> _setUrl() async {
    final sh = await SharedPreferences.getInstance();
    setState(() {
      username = sh.getString("name") ?? "user"; // Default to "user" if null
      email = sh.getString("email") ?? "user"; // Default to "user" if null
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient with texture
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF500E10)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  title: const Text(
                    "User Home",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PlayfairDisplay',
                      color: Colors.black,
                      letterSpacing: 2.0,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () async {
                        // Clear session data using SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear(); // This clears all stored preferences (like session info)

                        // Navigate to the LoginPage and clear the backstack
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const Login()),
                              (route) => false, // This removes all previous routes from the navigation stack
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                    ),
                  ],
                  centerTitle: true,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Welcome User!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'PlayfairDisplay',
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'PlayfairDisplay',
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'PlayfairDisplay',
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          _buildFeatureCard(
                            title: "View Designs",
                            icon: Icons.architecture,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewDesignsPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildFeatureCard(
                            title: "Add Designs",
                            icon: Icons.add_box_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PromptPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildFeatureCard(
                            title: "Request Designs",
                            icon: Icons.request_quote,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RequestedDesignsPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildFeatureCard(
                            title: "Material & Budget",
                            icon: Icons.account_balance_wallet,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserBudgetPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildFeatureCard(
                            title: "Payment",
                            icon: Icons.credit_card,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PaymentHistoryPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildFeatureCard(
                            title: "Feedback",
                            icon: Icons.rate_review,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SubmitFeedbackPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildFeatureCard(
                            title: "Complaints",
                            icon: Icons.report_gmailerrorred,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ViewComplaintsPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildFeatureCard(
                            title: "Change Password",
                            icon: Icons.edit,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangePasswordScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF500E10), Color(0xFF7A1C20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          leading: Icon(
            icon,
            size: 34,
            color: Color(0xFFD2B48C), // Sandy brown color
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'PlayfairDisplay',
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white70,
            size: 20,
          ),
        ),
      ),
    );
  }
}
