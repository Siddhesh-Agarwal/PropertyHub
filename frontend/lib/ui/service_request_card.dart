import 'package:flutter/material.dart';

class ServiceRequestCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String formattedDate;
  final VoidCallback onTap;

  const ServiceRequestCard({
    super.key,
    required this.data,
    required this.formattedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      borderOnForeground: true,
      elevation: 3,
      child: ListTile(
        title: Text('Service: ${data['serviceType'] ?? 'N/A'}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Service Type: ${data['serviceType'] ?? 'N/A'}'),
            Text('Date: $formattedDate'),
            Text('Notes: ${data['notes'] ?? 'N/A'}'),
          ],
        ),
        contentPadding: const EdgeInsets.all(16.0),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: onTap,
        ),
      ),
    );
  }
}
