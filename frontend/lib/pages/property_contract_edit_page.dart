import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '/services/contract_service.dart';
import '/ui/date_input.dart';
import '/ui/file_input.dart';
import '/ui/snackbar.dart';
import '/utils/utils.dart';

class PropertyContractEditPage extends StatefulWidget {
  const PropertyContractEditPage({super.key});

  @override
  State<PropertyContractEditPage> createState() =>
      _PropertyContractEditPageState();
}

class _PropertyContractEditPageState extends State<PropertyContractEditPage> {
  // Variables
  final _customerEmailController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  PlatformFile? contractFile;

  // Constants
  final _formKey = GlobalKey<FormState>();
  String get propertyId => ModalRoute.of(context)!.settings.arguments as String;
  ContractService contractService = ContractService();

  Future<void> onSubmit() async {
    if (contractFile == null) {
      errorSnack(context, "Please select a contract file");
      return;
    }
    if (startDate == null || endDate == null) {
      errorSnack(context, "Please select start and end dates");
      return;
    }
    if (startDate!.isAfter(endDate!)) {
      errorSnack(context, "Start date cannot be after end date");
      return;
    }
    await contractService.uploadContract(
      customerId: _customerEmailController.text,
      propertyId: propertyId,
      startDate: startDate!,
      endDate: endDate!,
      contractFile: contractFile!,
    );
    if (!mounted) return;
    Navigator.pop(context);
    successSnack(context, "Contract uploaded successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Property Contract")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer email field
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  controller: _customerEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the customer email';
                    }
                    if (!isValidEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),

              DateInput(
                onDateSelected: (DateTime? date) {
                  if (date != null) return;
                  setState(() {
                    startDate = date!;
                  });
                },
                label: "Start Date",
                placeholder: "Choose start date",
              ),

              DateInput(
                onDateSelected: (DateTime? date) {
                  if (date != null) return;
                  setState(() {
                    endDate = date!;
                  });
                },
                label: "End Date",
                placeholder: "Choose end date",
              ),

              FileInputButton(
                label: "Upload Contract",
                subLabel: "PDF",
                fileType: FileType.custom,
                fileExtensions: ['pdf'],
                onFileSelected: (PlatformFile file) {
                  setState(() {
                    contractFile = file;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
