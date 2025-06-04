import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;

  File? _profileImage;
  XFile? _pickedImageXFile;
  Uint8List? _imageBytes;

  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _pickedImageXFile = pickedFile;
            _imageBytes = bytes;
            _profileImage = null;
          });
        } else {
          setState(() {
            _profileImage = File(pickedFile.path);
            _pickedImageXFile = null;
            _imageBytes = null;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your date of birth')));
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your gender')));
      return;
    }

    if (_profileImage == null && _pickedImageXFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a profile image')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String profileImagePath = '';
    if (kIsWeb && _pickedImageXFile != null) {
      profileImagePath = _pickedImageXFile!.name;
    } else if (_profileImage != null) {
      profileImagePath = _profileImage!.path.split('/').last;
    }

    bool success = await register(
      firstName: _firstNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      address: _addressController.text.trim(),
      dateOfBirth: _selectedDate!,
      gender: _selectedGender!,
      profileImagePath: profileImagePath,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed, please try again')),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'First name is required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'Select Date of Birth'
                          : 'DOB: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedGender = val),
                decoration: const InputDecoration(labelText: 'Gender'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Gender is required' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  (_profileImage == null && _imageBytes == null)
                      ? const Text('No image selected')
                      : kIsWeb
                          ? Image.memory(_imageBytes!, width: 80, height: 80)
                          : Image.file(_profileImage!, width: 80, height: 80),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Select Profile Image'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      child: const Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> register({
  required String firstName,
  required String phone,
  required String email,
  required String password,
  required String address,
  required DateTime dateOfBirth,
  required String gender,
  required String profileImagePath,
}) async {
  try {
    var uri = Uri.parse('https://ib.jamalmoallart.com/api/v2/register');

    var request = http.MultipartRequest('POST', uri);

    request.fields['first_name'] = firstName;
    request.fields['last_name'] = profileImagePath;
    request.fields['phone'] = phone;
    request.fields['email'] = email;
    request.fields['password'] = password;

    String combinedAddress =
        '$address | DOB: ${dateOfBirth.toIso8601String()} | Gender: $gender';
    request.fields['address'] = combinedAddress;

    var response = await request.send();

    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Registration success: $respStr');
      return true;
    } else {
      print('Registration failed: ${response.statusCode}, $respStr');
      String errorMessage = 'Registration failed, please try again';
      try {
        final jsonResp = jsonDecode(respStr);
        if (jsonResp['message'] != null) {
          errorMessage = jsonResp['message'];
        } else if (jsonResp['error'] != null) {
          errorMessage = jsonResp['error'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  } catch (e) {
    print('Error during registration: $e');
    return false;
  }
}
