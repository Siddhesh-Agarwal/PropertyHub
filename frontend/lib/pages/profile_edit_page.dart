import 'package:flutter/material.dart';
import '/services/user_service.dart';
import '/services/auth_services.dart';
import '/services/constants.dart';
import '/ui/button.dart';
import '/ui/date_input.dart';
import '/ui/dropdown.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qatarIdController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;

  String? _errorMessage;
  UserMode? get _userMode => authService.value.userMode;
  UserService userService = UserService();
  String? get email => authService.value.user!.email;
  static const genderOptions = ["Male", "Female", "Other"];

  Future<void> _prefillUserData() async {
    try {
      final data = await userService.getUser(email: email!);
      if (data == null) {
        if (!mounted) return;
        setState(() => _errorMessage = 'Error fetching user data');
        Navigator.pop(context);
        return;
      }
      setState(() {
        _nameController.text = data['displayName'] ?? '';
        _phoneController.text = data['phoneNumber'] ?? '';
        _qatarIdController.text = data['qatarId'] ?? '';
        _selectedDate = data['dateOfBirth']?.toDate();
        _selectedGender = data['gender'];
      });
    } catch (e) {
      setState(() => _errorMessage = 'Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    _prefillUserData();
  }

  void _initializeData() {
    if (_userMode == null) {
      authService.value.signOut();
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      setState(() => _errorMessage = 'Please select your date of birth');
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      await userService.updateUserInfo(
        displayName: _nameController.text.trim(),
        email: email!,
        phoneNumber: _phoneController.text.trim(),
        dateOfBirth: _selectedDate!,
        gender: _selectedGender!,
        qatarId: _qatarIdController.text.trim(),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Error saving profile: ${e.toString()}');
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 24),
              const Text(
                'Complete Your Profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'We need a few more details to personalize your experience',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  final phoneRegex = RegExp(r'^[0-9]{8}$');
                  if (!phoneRegex.hasMatch(value.trim())) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _qatarIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Qatar ID',
                  prefixIcon: const Icon(Icons.credit_card_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().length != 11) {
                    return 'Enter a Valid Qatar ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Dropdown(
                items: genderOptions,
                label: "Gender",
                selectedIndex:
                    _selectedGender == null
                        ? 0
                        : genderOptions.indexOf(_selectedGender!),
                onChanged: (String value) {
                  setState(() => _selectedGender = value);
                },
              ),
              const SizedBox(height: 4),
              DateInput(
                onDateSelected: (val) => setState(() => _selectedDate = val),
                label: "Date of Birth",
                placeholder: "Select your date of birth",
                selectedDate: _selectedDate,
              ),
              const SizedBox(height: 8),
              if (_selectedDate != null)
                Text(
                  'Age: ~${DateTime.now().difference(_selectedDate!).inDays ~/ 365} years',
                  style: const TextStyle(color: Colors.grey),
                ),
              const SizedBox(height: 32),
              OutlineButton(onPressed: _submitForm, label: 'Save Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
