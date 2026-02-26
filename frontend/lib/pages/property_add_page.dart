import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/db_service.dart';
import '/services/storage_service.dart';
import '/ui/button.dart';
import '/ui/dropdown.dart';
import '/ui/file_input.dart';
import '/ui/snackbar.dart';
import '/utils/property.dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _sizeController = TextEditingController();

  String _ownershipType = 'Owned';
  String _propertyType = 'Apartment';
  String _furnishingType = 'Furnished';
  String _usageType = 'Residential';
  PlatformFile? _propertyImage;

  @override
  void dispose() {
    _addressController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? fileUrl;
        if (_propertyImage != null) {
          fileUrl = await uploadFile(_propertyImage!.path!);
        }
        // Add to Firestore
        await db.collection('properties').add({
          'ownershipType': _ownershipType,
          'propertyType': _propertyType,
          'furnishingType': _furnishingType,
          'usageType': _usageType,
          'size': double.parse(_sizeController.text),
          'address': _addressController.text,
          'createdAt': FieldValue.serverTimestamp(),
          'available': true,
          'imageUrl': fileUrl,
        });

        if (!mounted) return;
        successSnack(context, "Property added successfully");
      } catch (e) {
        errorSnack(context, "Error adding property. Try again.");
      }

      // Optional: Navigate back or to a details page
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Property')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Input
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

              const SizedBox(height: 24),

              // Property ownership type dropdown
              Dropdown(
                label: 'Ownership Type',
                items: ownershipOptions,
                onChanged: (value) {
                  setState(() {
                    _ownershipType = value;
                  });
                },
              ),

              // Property type dropdown
              Dropdown(
                label: 'Property Type',
                items: propertyOptions,
                onChanged: (value) {
                  setState(() {
                    _propertyType = value;
                  });
                },
              ),

              // Furnishing type dropdown
              Dropdown(
                label: 'Furnishing Type',
                items: furnishingOptions,
                onChanged: (value) {
                  setState(() {
                    _furnishingType = value;
                  });
                },
              ),

              // Usage type dropdown
              Dropdown(
                label: 'Usage Type',
                items: usageOptions,
                onChanged: (value) {
                  setState(() {
                    _usageType = value;
                  });
                },
              ),

              // Property size field
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  controller: _sizeController,
                  decoration: const InputDecoration(
                    labelText: 'Property Size (sq. ft.)',
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
              ),

              // Property address field
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: TextFormField(
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
              ),

              // Submit button
              OutlineButton(onPressed: _submitForm, label: 'Add Property'),
            ],
          ),
        ),
      ),
    );
  }
}
