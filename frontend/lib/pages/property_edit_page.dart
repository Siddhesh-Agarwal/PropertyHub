import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '/services/auth_services.dart';
import '/services/constants.dart';
import '/services/db_service.dart';
import '/services/storage_service.dart';
import '/ui/button.dart';
import '/ui/dropdown.dart';
import '/ui/file_input.dart';
import '/ui/loading.dart';
import '/ui/snackbar.dart';

class EditPropertyPage extends StatefulWidget {
  const EditPropertyPage({super.key});

  @override
  State<EditPropertyPage> createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends State<EditPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _sizeController = TextEditingController();
  UserMode? get _userMode => authService.value.userMode;
  bool _loading = false;
  // get propertyId from Navigator Arguement
  String get propertyId => ModalRoute.of(context)!.settings.arguments as String;

  // Declare the variable (without value)
  String _ownershipType = 'Owned';
  String _propertyType = 'Apartment';
  String _furnishingType = 'Furnished';
  String _usageType = 'Residential';
  String _availability = 'Available';
  PlatformFile? _propertyImage;

  void getValues() async {
    setState(() {
      _loading = true;
    });

    try {
      final property = await db.collection('properties').doc(propertyId).get();
      if (!property.exists) {
        if (!mounted) return;
        errorSnack(context, 'Property not found');
        Navigator.pop(context);
        return;
      }
      final data = property.data();
      if (data == null) {
        if (!mounted) return;
        errorSnack(context, 'Error fetching property data');
        Navigator.pop(context);
        return;
      }

      setState(() {
        _ownershipType = data['ownershipType'];
        _propertyType = data['propertyType'];
        _furnishingType = data['furnishingType'];
        _usageType = data['usageType'];
        _availability = data['available'] ? 'Available' : 'Unavailable';
        _loading = false;
      });
      _addressController.text = data['address'];
      _sizeController.text = data['size'].toString();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      errorSnack(context, 'Error loading property: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (_userMode != UserMode.admin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return;
    }
    getValues();
  }

  // Options for each property characteristic
  final List<String> _ownershipOptions = ['Owned', 'Rented', 'Managed'];
  final List<String> _propertyOptions = ['Villa', 'Apartment', 'Shop'];
  final List<String> _furnishingOptions = ['Furnished', 'Unfurnished'];
  final List<String> _usageOptions = ['Residential', 'Commercial'];
  final List<String> _availabilityOptions = ['Available', 'Unavailable'];

  @override
  void dispose() {
    _addressController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      String? imageUrl;
      if (_propertyImage != null) {
        imageUrl = await uploadFile(_propertyImage!.path!);
      }

      await db.collection('properties').doc(propertyId).update({
        'ownershipType': _ownershipType,
        'propertyType': _propertyType,
        'furnishingType': _furnishingType,
        'usageType': _usageType,
        'size': double.parse(_sizeController.text),
        'address': _addressController.text,
        'available': _availability == 'Unavailable',
        'imageUrl': imageUrl,
      });
      if (!mounted) return;
      successSnack(context, 'Property updated successfully');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      errorSnack(context, 'Failed to update property: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Property Details')),
      body:
          _loading
              ? loading()
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Property Details",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      FileInputButton(
                        label: "Upload Property Image",
                        subLabel: "PNG, JPG, JPEG",
                        fileType: FileType.image,
                        onFileSelected: (PlatformFile file) {
                          setState(() {
                            _propertyImage = file;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Dropdown(
                        items: _ownershipOptions,
                        label: 'Ownership Type',
                        selectedIndex: _ownershipOptions.indexOf(
                          _ownershipType,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _ownershipType = value;
                          });
                        },
                      ),
                      // Property type dropdown
                      Dropdown(
                        items: _propertyOptions,
                        label: 'Property Type',
                        selectedIndex: _propertyOptions.indexOf(_propertyType),
                        onChanged: (value) {
                          setState(() {
                            _propertyType = value;
                          });
                        },
                      ),
                      // Furnishing type dropdown
                      Dropdown(
                        items: _furnishingOptions,
                        label: 'Furnishing Type',
                        selectedIndex: _furnishingOptions.indexOf(
                          _furnishingType,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _furnishingType = value;
                          });
                        },
                      ),
                      Dropdown(
                        items: _usageOptions,
                        label: 'Usage Type',
                        selectedIndex: _usageOptions.indexOf(_usageType),
                        onChanged: (value) {
                          setState(() {
                            _usageType = value;
                          });
                        },
                      ),
                      TextFormField(
                        controller: _sizeController,
                        decoration: const InputDecoration(
                          labelText: 'Property Size (sqm)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the property size';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Property Address',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the property address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Dropdown(
                        items: _availabilityOptions,
                        label: "Availability",
                        selectedIndex: _availabilityOptions.indexOf(
                          _availability,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _availability = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      OutlineButton(
                        onPressed: _submitForm,
                        label: 'Update Details',
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
