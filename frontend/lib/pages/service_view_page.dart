import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/auth_services.dart';
import '/services/constants.dart';
import '/services/db_service.dart';
import '/ui/error.dart';
import '/ui/loading.dart';
import '/ui/service_request_card.dart';
import '/ui/snackbar.dart';

class ViewServiceRequestPage extends StatefulWidget {
  const ViewServiceRequestPage({super.key});

  @override
  State<ViewServiceRequestPage> createState() => _ViewServiceRequestPageState();
}

class _ViewServiceRequestPageState extends State<ViewServiceRequestPage> {
  late Stream<QuerySnapshot> _serviceRequestsStream;
  UserMode? userMode;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    setState(() {});
    try {
      final mode = authService.value.userMode;

      if (mode == null) {
        authService.value.signOut();
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      late Stream<QuerySnapshot> stream;
      if (mode == UserMode.user) {
        // fetch by user ID
        stream =
            db
                .collection('service_requests')
                .where('userId', isEqualTo: authService.value.user!.email)
                .orderBy('date', descending: false)
                .snapshots();
      } else {
        // fetch upcoming
        stream =
            db
                .collection('service_requests')
                .where('date', isGreaterThanOrEqualTo: DateTime.now())
                .orderBy('date', descending: false)
                .snapshots();
      }
      setState(() {
        userMode = mode;
        _serviceRequestsStream = stream;
      });
    } catch (e) {
      if (!mounted) return;
      errorSnack(context, e.toString());
    }
  }

  String parseDateString(Timestamp dateString) {
    DateTime date = dateString.toDate();
    String formattedDate = date.toLocal().toString().split(' ')[0];
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Requests'),
        actions: [
          if (userMode == UserMode.user)
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/service/request');
              },
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _initializeData();
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: _serviceRequestsStream,
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot,
          ) {
            if (snapshot.hasError) {
              return ErrorView(
                error: snapshot.error.toString(),
                onRetry: () => setState(() {}),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return loading();
            }

            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No service requests found.'));
            }

            return ListView(
              children:
                  snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return ServiceRequestCard(
                      data: data,
                      formattedDate: parseDateString(data['date']),
                      onTap: () => _showServiceRequestDetails(context, data),
                    );
                  }).toList(),
            );
          },
        ),
      ),
    );
  }

  void _showServiceRequestDetails(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Service Request Details'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Service Type: ${data['serviceType'] ?? 'N/A'}'),
                Text('Date: ${parseDateString(data['date'])}'),
                Text('Notes: ${data['notes'] ?? 'N/A'}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
