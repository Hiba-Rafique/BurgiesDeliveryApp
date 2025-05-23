import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/adminpage.dart';
import 'package:flutter_application_1/pages/homepage.dart';
import 'package:flutter_application_1/pages/signuppage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    final loginData = {
      'email': email,
      'password': password,
    };

    final url = Uri.parse('https://eliuwjh1sfjv.share.zrok.io/api/login'); 

    try {
      final response = await http.post(
        url,
        body: jsonEncode(loginData),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      setState(() => _isSubmitting = false);

      if (response.statusCode == 200) {
        final userDetailsUrl = Uri.parse('https://eliuwjh1sfjv.share.zrok.io/api/api/get-user-details?email=$email');

        final userDetailsResponse = await http.get(userDetailsUrl).timeout(const Duration(seconds: 8));

        if (userDetailsResponse.statusCode == 200) {
          var userDetails = jsonDecode(userDetailsResponse.body);

          var box = await Hive.openBox('userSession');
          await box.put('userLoggedIn', true);
          await box.put('userDetails', userDetails);

          await box.put('userFirstName', userDetails['firstName']);
          await box.put('userLastName', userDetails['lastName']);
          await box.put('userEmail', userDetails['email']);
          await box.put('userRole', userDetails['role']);
          await box.put('userPhone', userDetails['phoneNum']);
          await box.put('userAddress', userDetails['address']);

          // Added customerId saving here:
          await box.put('customerId', userDetails['id']); // Change key if needed

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful!')),
          );

          String role = userDetails['role'];
          print('User role: $role');

          if (role == 'ADMIN') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ Failed to fetch user details: ${userDetailsResponse.statusCode}\n${userDetailsResponse.body}',
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Login failed: ${response.statusCode}\n${response.body}',
            ),
          ),
        );
      }
    } on http.ClientException catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Client error: $e')),
      );
    } on TimeoutException {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Request timed out')),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Unexpected error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[600],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                ),
                width: 700,
                height: 500,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/burgieslogo.png',
                        width: 155,
                        height: 200,
                      ),
                      SizedBox(height: 17),
                      SizedBox(
                        width: 270,
                        child: Material(
                          color: Colors.transparent,
                          child: TextFormField(
                            style: TextStyle(color: Colors.amberAccent),
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(color: Colors.amberAccent),
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.amberAccent),
                              prefixIcon: Icon(Icons.email, color: Colors.amber),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.yellow),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.yellow, width: 2),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Please enter your email';
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(val)) return 'Enter a valid email';
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 270,
                        child: Material(
                          color: Colors.transparent,
                          child: TextFormField(
                            style: TextStyle(color: Colors.amberAccent),
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.amberAccent),
                              prefixIcon: Icon(Icons.lock, color: Colors.amber),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.yellow),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.yellow, width: 2),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.amber,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Please enter your password';
                              if (val.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: 230,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                )
                              : Text('Log In', style: TextStyle(fontSize: 16, color: Colors.black)),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignUpPage()),
                              );
                            },
                            child: Text('Sign Up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
