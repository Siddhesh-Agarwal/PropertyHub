import 'package:flutter/material.dart';
import '/services/contract_service.dart';

class PropertyContractPage extends StatefulWidget {
  const PropertyContractPage({super.key});

  @override
  State<PropertyContractPage> createState() => _PropertyContractPageState();
}

class _PropertyContractPageState extends State<PropertyContractPage> {
  // Variables
  Map<String, dynamic>? contract;

  // Constants
  String get propertyId => ModalRoute.of(context)!.settings.arguments as String;
  ContractService contractService = ContractService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> getStream() async {
    var temp = await contractService.getPropertyActiveContract(propertyId);
    setState(() {
      contract = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Property Contract")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Property Contract",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            (contract == null)
                ? Text("No contract found")
                : Column(children: [
            ],),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed:
            () => Navigator.pushNamed(
              context,
              '/properties/contract/edit',
              arguments: propertyId,
            ),
      ),
    );
  }
}
