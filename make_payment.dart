import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'home.dart';

class UserPaymentScreenPage extends StatefulWidget {
  @override
  _UserPaymentScreenPageState createState() => _UserPaymentScreenPageState();
}

class _UserPaymentScreenPageState extends State<UserPaymentScreenPage> {
  late Razorpay _razorpay;
  final TextEditingController _amountController = TextEditingController();
  String amount_ = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _initializeData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _amountController.text = prefs.getString("amt") ?? '';
        amount_ = _amountController.text.split(".")[0];
      });
    } catch (e) {
      print("Error fetching SharedPreferences data: $e");
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String url = prefs.getString("url") ?? '';
      String reqid = prefs.getString("oid") ?? '';
      String lid = prefs.getString("lid") ?? '';

      var data = await http.post(
        Uri.parse(url + "uyyoon_payment"),
        body: {
          'reqid': reqid,
          'lid': lid,
          'amount':prefs.getString("amt") ?? ''
        },
      );

      var jsonData = json.decode(data.body);
      if (jsonData['status'] == 'ok') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External wallet selected: ${response.walletName}")),
    );
  }

  Future<void> _makePayment() async {
    if (_amountController.text.isEmpty) return;
    _openCheckout();
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_edrzdb8Gbx5U5M',
      'amount': int.parse(amount_) * 100,
      'name': 'Razorpay Demo',
      'description': 'Test Payment',
      'prefill': {'contact': '8590440219', 'email': 'Uyyon@gmail.com'},
      'external': {'wallets': ['paytm']},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening Razorpay checkout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment',
          style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
        ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Enter the Amount to Pay',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75, // 75% of screen width
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1), // Silver border
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter Amount',
                    hintStyle: TextStyle(color: Colors.white54), // Subtle hint color
                    border: InputBorder.none, // Remove default border
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: Icon(Icons.currency_rupee, color: Colors.white),
                  ),
                  enabled: false,
                ),
              ),
            ),

            SizedBox(height: 40),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7, // 70% of screen width
              child: ElevatedButton(
                onPressed: _amountController.text.isEmpty ? null : _makePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF500E10), // Button background color
                  padding: EdgeInsets.symmetric(vertical: 14), // Better height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey),
                ),
                child: Text(
                  'Pay Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
