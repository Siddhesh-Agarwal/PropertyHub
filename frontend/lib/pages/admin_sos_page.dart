import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '/services/db_service.dart';
import '/ui/loading.dart';
import '/ui/error.dart';

class AdminSosPage extends StatelessWidget {
  const AdminSosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOS Requests')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream:
            db
                .collection('sos')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorView(error: snapshot.error.toString(), onRetry: () {});
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return loading();
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No SOS requests found.'));
          }

          return ListView.separated(
            itemCount: docs.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final timestamp =
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
              final formattedTime = DateFormat(
                'MMM d yyyy, hh:mm a',
              ).format(timestamp);
              final userName = data['name'] ?? 'Unknown User';
              final userEmail = data['email'] ?? 'No Email';
              final reason = data['title'] ?? 'Emergency';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.red.shade100,
                  radius: 30,
                  child: const Icon(Icons.sos, color: Colors.red, size: 30),
                ),
                title: Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$userName ($userEmail)',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
