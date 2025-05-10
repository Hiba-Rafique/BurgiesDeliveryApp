import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/adminpage.dart';
import 'package:flutter_application_1/pages/homepage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final url = Uri.parse('https://eliuwjh1sfjv.share.zrok.io/api/signup');

    final payload = {
      'firstName': _firstNameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passwordCtrl.text.trim(),
    };

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));

      setState(() => _isSubmitting = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Fetch the role after successful signup
        final roleUrl = Uri.parse('https://eliuwjh1sfjv.share.zrok.io/api/getrole?firstname=${_firstNameCtrl.text.trim()}&lastname=${_lastNameCtrl.text.trim()}');
        final roleResponse = await http.get(roleUrl);
        final responseData = jsonDecode(roleResponse.body);
if (responseData.containsKey('role')) {
  String userRole = responseData['role'].toString().trim().toLowerCase();

  if (userRole != 'customer' && userRole != 'admin') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unexpected role assigned. Please contact support.')),
    );
    return;
  }


          
          var box = Hive.box('userSession');
          await box.put('userLoggedIn', true);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup successful!')),
          );

          await box.put('userFirstName', _firstNameCtrl.text.trim());
await box.put('userLastName', _lastNameCtrl.text.trim());
await box.put('userEmail', _emailCtrl.text.trim());
await box.put('userPhone', _phoneCtrl.text.trim());
await box.put('userRole', userRole);


          // Navigate based on role
          if (userRole == 'admin') {
            // Navigate to AdminPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminPage()),
            );
          } else {
            // Navigate to HomePage for customers
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch user role')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black,
              ),
              width: 700,
              height: 700,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/burgieslogo.png',
                      width: 155,
                      height: 200,
                    ),
                    buildTextField(
                      'First Name',
                      _firstNameCtrl,
                      Icons.person,
                      'Enter first name',
                    ),
                    const SizedBox(height: 10),
                    buildTextField(
                      'Last Name',
                      _lastNameCtrl,
                      Icons.person_outline,
                      'Enter last name',
                    ),
                    const SizedBox(height: 10),
                    buildTextField(
                      'Phone Number',
                      _phoneCtrl,
                      Icons.phone,
                      'Enter phone number',
                      isPhone: true,
                    ),
                    const SizedBox(height: 10),
                    buildTextField(
                      'Email',
                      _emailCtrl,
                      Icons.email,
                      'Please enter your email',
                      isEmail: true,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 270,
                      child: Material(
                        color: Colors.transparent,
                        child: TextFormField(
                          style: const TextStyle(color: Colors.amberAccent),
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.amberAccent),
                            prefixIcon: const Icon(Icons.lock, color: Colors.amber),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.yellow),
                            ),
                            focusedBorder: const OutlineInputBorder(
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 230,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    String validatorText, {
    bool isPhone = false,
    bool isEmail = false,
  }) {
    return SizedBox(
      width: 270,
      child: TextFormField(
        style: const TextStyle(color: Colors.amberAccent),
        controller: controller,
        keyboardType: isPhone
            ? TextInputType.phone
            : isEmail
                ? TextInputType.emailAddress
                : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.amberAccent),
          prefixIcon: Icon(icon, color: Colors.amber),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.yellow),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.yellow, width: 2),
          ),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return validatorText;
          if (isPhone && !RegExp(r'^\d{10,15}$').hasMatch(val)) {
            return 'Enter a valid number';
          }
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
            return 'Enter a valid email';
          }
          return null;
        },
      ),
    );
  }
}
