import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/services/auth_services.dart';
import '/services/constants.dart';
import '/services/db_service.dart';
import '/ui/button.dart';
import '/ui/dropdown.dart';
import '/ui/loading.dart';
import '/ui/snackbar.dart';

class RequestServicePage extends StatefulWidget {
  const RequestServicePage({super.key});

  @override
  State<RequestServicePage> createState() => _RequestServicePageState();
}

class _RequestServicePageState extends State<RequestServicePage> {
  String? _selectedService;
  DateTime? _selectedDate;
  bool _loading = true;

  final TextEditingController _notesController = TextEditingController();
  final List<String> _serviceTypes = [
    "Moving",
    "Carpentery",
    "Plumbing",
    "Electrical",
    "Pest",
  ];

  get email => authService.value.user!.email;
  UserMode? userMode;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
    _notesController.dispose();
  }

  void _initializeData() {
    final mode = authService.value.userMode;
    if (mode == null) {
      authService.value.signOut();
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    setState(() {
      userMode = mode;
      _loading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
    if (picked == null) {
      setState(() {
        _selectedDate = null;
      });
    }
  }

  Future<void> _requestService() async {
    if (_selectedService == null) {
      errorSnack(context, 'Please select a service type');
    } else if (_selectedDate == null) {
      errorSnack(context, 'Please select a date');
    } else {
      db.collection('service_requests').add({
        'serviceType': _selectedService,
        'date': _selectedDate,
        'notes': _notesController.text,
        'userId': email,
      });
      successSnack(context, 'Request Submitted Successfully!');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userMode != UserMode.user) {
      Navigator.pop(context);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Request Service')),
      body:
          _loading
              ? loading()
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Dropdown(
                      items: _serviceTypes,
                      label: "Select Service Type",
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedService = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              _selectedDate == null
                                  ? 'Select Date'
                                  : _selectedDate!.toLocal().toString().split(
                                    ' ',
                                  )[0],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      inputFormatters: [LengthLimitingTextInputFormatter(200)],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: OutlineButton(
                        onPressed: _requestService,
                        label: 'Submit Request',
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
