import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '/services/auth_services.dart';
import '/services/contract_service.dart';
import '/services/storage_service.dart';
import '/ui/snackbar.dart';

class ContractPage extends StatefulWidget {
  const ContractPage({super.key});

  @override
  State<ContractPage> createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  String get email => authService.value.user!.email!;
  ContractService contractService = ContractService();
  final Set<String> _downloadingFiles = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Contracts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: contractService.streamCustomerContracts(email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text('No contracts found.'),
                ],
              ),
            );
          }

          final contracts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              final contract = contracts[index];
              return _buildContractCard(contract);
            },
          );
        },
      ),
    );
  }

  Widget _buildContractCard(Map<String, dynamic> contract) {
    final String fileName = contract['fileName'] ?? 'Unknown';
    final String fileUrl = contract['contractFileUrl'] ?? '';
    final String status = contract['status'] ?? 'unknown';

    // Handle dates safely
    DateTime? startDate, endDate;
    if (contract['startDate'] != null) {
      startDate = (contract['startDate'] as Timestamp).toDate();
    }
    if (contract['endDate'] != null) {
      endDate = (contract['endDate'] as Timestamp).toDate();
    }

    // Status color and icon
    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'expired':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'terminated':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (fileUrl.isNotEmpty) _buildDownloadButton(fileUrl, fileName),
              ],
            ),
            const SizedBox(height: 12),

            // Contract details
            _buildDetailRow(Icons.description, 'File Name', fileName),
            if (startDate != null)
              _buildDetailRow(
                Icons.play_arrow,
                'Start Date',
                DateFormat('dd MMM yyyy').format(startDate),
              ),
            if (endDate != null)
              _buildDetailRow(
                Icons.event,
                'End Date',
                DateFormat('dd MMM yyyy').format(endDate),
              ),

            // Property info if available
            if (contract['propertyId'] != null)
              _buildDetailRow(
                Icons.location_on,
                'Property ID',
                contract['propertyId'],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(String fileUrl, String fileName) {
    final isDownloading = _downloadingFiles.contains(fileName);

    return isDownloading
        ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
        : IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _downloadFile(fileUrl, fileName),
          tooltip: 'Download $fileName',
        );
  }

  Future<void> _downloadFile(String fileUrl, String fileName) async {
    if (fileUrl.isEmpty) {
      errorSnack(context, 'File URL is empty');
      return;
    }

    setState(() {
      _downloadingFiles.add(fileName);
    });

    try {
      await _performDownload(fileUrl, fileName);
    } catch (e) {
      if (!mounted) return;
      errorSnack(context, 'Error downloading file: $e');
    } finally {
      if (mounted) {
        setState(() {
          _downloadingFiles.remove(fileName);
        });
      }
    }
  }

  Future<void> _performDownload(String fileUrl, String fileName) async {
    try {
      // Use Firebase Storage reference directly (more efficient)
      final ref = storage.refFromURL(fileUrl);

      // Get Downloads directory for user accessibility
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          // Fallback to app documents directory
          downloadsDir = await getApplicationDocumentsDirectory();
        }
      } else {
        // iOS: use app documents directory
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      final String filePath = '${downloadsDir.path}/$fileName';
      final File file = File(filePath);

      // Download file using Firebase Storage
      await ref.writeToFile(file);

      if (!mounted) return;
      successSnack(context, 'Downloaded $fileName to Downloads folder');
    } catch (e) {
      throw 'Download failed: $e';
    }
  }
}
