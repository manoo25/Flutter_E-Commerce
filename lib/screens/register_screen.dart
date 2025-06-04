import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return;
    }

    if (_profileImage == null && _pickedImageXFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await registerUser(
      firstName: _firstNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      address: _addressController.text.trim(),
      dateOfBirth: _selectedDate!,
      gender: _selectedGender!,
      profileImageFile: _profileImage,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful!')));
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
            ),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : _imageBytes != null
                                  ? MemoryImage(_imageBytes!)
                                  : null,
                              backgroundColor: Colors.grey[300],
                              child:
                                  _profileImage == null && _imageBytes == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.pink,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Material(
                                color: Colors.pink,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: _pickImage,
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'First name is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email required';
                            final emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailRegex.hasMatch(v))
                              return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Phone number is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (v) => v != null && v.length >= 6
                              ? null
                              : 'Password must be at least 6 chars',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              ),
                            ),
                          ),
                          validator: (v) => v == _passwordController.text
                              ? null
                              : 'Passwords do not match',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Address is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: Colors.white.withOpacity(0.9),
                          title: Text(
                            _selectedDate == null
                                ? 'Select Date of Birth'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          ),
                          trailing: const Icon(
                            Icons.calendar_today,
                            color: Colors.pink,
                          ),
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          hint: const Text('Select Gender'),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                          ),
                          items: ['Male', 'Female']
                              .map(
                                (g) =>
                                    DropdownMenuItem(value: g, child: Text(g)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedGender = val),
                          validator: (v) =>
                              v == null ? 'Gender is required' : null,
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.pink,
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "I don't have an account? ",
                              style: TextStyle(color: Colors.pink),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed('/login');
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
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
      ),
    );
  }
}

Future<bool> registerUser({
  required String firstName,
  required String phone,
  required String email,
  required String password,
  required String address,
  required DateTime dateOfBirth,
  required String gender,
  required File? profileImageFile,
}) async {
  try {
    var uri = Uri.parse('https://ib.jamalmoallart.com/api/v2/register');
    var request = http.MultipartRequest('POST', uri);

    request.fields['first_name'] = firstName;
    request.fields['last_name'] = 'image';
    request.fields['phone'] = phone;
    request.fields['email'] = email;
    request.fields['password'] = password;

    request.fields['address'] =
        '$address | DOB: ${dateOfBirth.toIso8601String()} | Gender: $gender';

    if (profileImageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('photo', profileImageFile.path),
      );
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Success: $responseBody');
      return true;
    } else {
      print('Failed: $responseBody');
      return false;
    }
  } catch (e) {
    print('Error: $e');
    return false;
  }
}
