import 'package:flutter/material.dart';
import '../../core/utils/validators.dart';
import '../../services/people_api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordObscured = true;

  void _handleSignup() async {
    final cleanName = _nameController.text.trim();
    final cleanEmail = _emailController.text.trim();
    final cleanMobile = _mobileController.text.trim();
    final cleanUsername = _usernameController.text.trim();
    final cleanPassword = _passwordController.text.trim();

    if (cleanName.isEmpty || !Validators.isLettersWithSpaces(cleanName)) {
      _showErrorToast('Full Name must contain only letters and spaces.');
      return;
    }
    if (!Validators.isValidEmail(cleanEmail)) {
      _showErrorToast('Provide a valid email address with a domain extension.');
      return;
    }
    if (!Validators.isMobileNumber(cleanMobile)) {
      _showErrorToast('Mobile number must be exactly 10 digits long.');
      return;
    }
    if (cleanUsername.isEmpty) {
      _showErrorToast('Username field cannot be blank.');
      return;
    }
    if (!Validators.isMinLength(cleanPassword, 6)) {
      _showErrorToast('Password security threshold must be >= 6 chars.');
      return;
    }

    setState(() => _isLoading = true);
    Map<String, String> signupData = {
      'name': cleanName,
      'emailAddress': cleanEmail,
      'mobileNumber': cleanMobile,
      'username': cleanUsername,
      'password': cleanPassword,
    };

    bool success = await PeopleApiService.signup(signupData);
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup successful! Please log in.')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      _showErrorToast('Signup failed. Please try again.');
    }
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign-up')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter your name';
                    if (!Validators.isLettersWithSpaces(val)) {
                      return 'Only letters are allowed (no numbers or special characters)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Email link path is required';
                    if (!Validators.isValidEmail(val)) {
                      return 'Provide a valid email address (e.g., name@domain.com)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Mobile number is required';
                    if (!Validators.isMobileNumber(val)) {
                      return 'Mobile number must be exactly 10 digits long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Username field cannot be blank' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscured = !_isPasswordObscured;
                        });
                      },
                    ),
                  ),
                  validator: (val) =>
                      val == null || !Validators.isMinLength(val, 6) ? 'Password security threshold must be >= 6 chars' : null,
                ),
                const SizedBox(height: 25),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.amber)
                    : ElevatedButton(
                        onPressed: _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
