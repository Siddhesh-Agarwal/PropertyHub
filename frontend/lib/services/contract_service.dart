import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import './db_service.dart';
import './storage_service.dart';

class ContractService {
  // Upload contract with optimized structure
  Future<String> uploadContract({
    required String customerId,
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
    required PlatformFile contractFile,
  }) async {
    // Step 1: Validate property availability
    await _validatePropertyAvailability(propertyId, startDate, endDate);

    // Step 2: Upload file to Firebase Storage
    String contractFileUrl = await _uploadFileToStorage(contractFile);

    // Step 3: Use batch write for atomic operations
    WriteBatch batch = db.batch();

    // Create contract document with customer-optimized structure
    DocumentReference contractRef = db.collection('contracts').doc();
    batch.set(contractRef, {
      'customerId': customerId,
      'propertyId': propertyId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'contractFileUrl': contractFileUrl,
      'fileName': contractFile.name,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': 'admin_uid',
    });

    // Create customer-specific contract document for fast queries
    DocumentReference customerContractRef = db
        .collection('customers')
        .doc(customerId)
        .collection('contracts')
        .doc(contractRef.id);

    batch.set(customerContractRef, {
      'contractId': contractRef.id,
      'propertyId': propertyId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'contractFileUrl': contractFileUrl,
      'fileName': contractFile.name,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update property with current contract
    DocumentReference propertyRef = db.collection('properties').doc(propertyId);
    batch.update(propertyRef, {
      'currentContractId': contractRef.id,
      'currentCustomerId': customerId,
    });

    await batch.commit();
    return contractRef.id;
  }

  // Validate property availability - optimized query
  Future<void> _validatePropertyAvailability(
    String propertyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // First check if property has current active contract
    DocumentSnapshot propertyDoc =
        await db.collection('properties').doc(propertyId).get();

    if (propertyDoc.exists) {
      var propertyData = propertyDoc.data() as Map<String, dynamic>;
      String? currentContractId = propertyData['currentContractId'];

      if (currentContractId != null) {
        // Check if current contract overlaps
        DocumentSnapshot currentContract =
            await db.collection('contracts').doc(currentContractId).get();

        if (currentContract.exists) {
          var contractData = currentContract.data() as Map<String, dynamic>;
          DateTime existingStart =
              (contractData['startDate'] as Timestamp).toDate();
          DateTime existingEnd =
              (contractData['endDate'] as Timestamp).toDate();

          if (startDate.isBefore(existingEnd) &&
              endDate.isAfter(existingStart)) {
            throw Exception(
              'Property already has an active contract during this period',
            );
          }
        }
      }
    }
  }

  // Upload file to Firebase Storage with organized structure
  Future<String> _uploadFileToStorage(PlatformFile file) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    Reference storageRef = storage.ref().child('contracts/$fileName');

    UploadTask uploadTask;

    if (file.bytes != null) {
      uploadTask = storageRef.putData(file.bytes!);
    } else if (file.path != null) {
      uploadTask = storageRef.putFile(File(file.path!));
    } else {
      throw Exception('No file data available');
    }

    TaskSnapshot snapshot = await uploadTask;

    // Add small delay/retry for getDownloadURL as it can sometimes fail with object-not-found
    // immediately after upload due to eventual consistency
    for (int i = 0; i < 3; i++) {
      try {
        return await snapshot.ref.getDownloadURL();
      } catch (e) {
        if (i == 2) rethrow;
        await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
      }
    }
    throw Exception("Failed to get download URL");
  }

  // OPTIMIZED: Get customer contracts - single query, no filtering
  Future<List<Map<String, dynamic>>> getCustomerContracts(
    String customerId,
  ) async {
    QuerySnapshot snapshot =
        await db
            .collection('customers')
            .doc(customerId)
            .collection('contracts')
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  // OPTIMIZED: Get active customer contracts only
  Future<List<Map<String, dynamic>>> getActiveCustomerContracts(
    String customerId,
  ) async {
    QuerySnapshot snapshot =
        await db
            .collection('customers')
            .doc(customerId)
            .collection('contracts')
            .where('status', isEqualTo: 'active')
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  // Get property active contract
  Future<Map<String, dynamic>?> getPropertyActiveContract(
    String propertyId,
  ) async {
    DocumentSnapshot propertyDoc =
        await db.collection('properties').doc(propertyId).get();

    if (!propertyDoc.exists) return null;

    var propertyData = propertyDoc.data() as Map<String, dynamic>;
    String? currentContractId = propertyData['currentContractId'];

    if (currentContractId == null) return null;

    DocumentSnapshot contractDoc =
        await db.collection('contracts').doc(currentContractId).get();

    if (!contractDoc.exists) return null;

    return {
      'id': contractDoc.id,
      ...contractDoc.data() as Map<String, dynamic>,
    };
  }

  // Terminate contract with batch updates
  Future<void> terminateContract(String contractId) async {
    DocumentSnapshot contractDoc =
        await db.collection('contracts').doc(contractId).get();

    if (!contractDoc.exists) {
      throw Exception('Contract not found');
    }

    var contractData = contractDoc.data() as Map<String, dynamic>;
    String propertyId = contractData['propertyId'];
    String customerId = contractData['customerId'];

    WriteBatch batch = db.batch();

    // Update main contract
    batch.update(contractDoc.reference, {
      'status': 'terminated',
      'terminatedAt': FieldValue.serverTimestamp(),
    });

    // Update customer contract copy
    batch.update(
      db
          .collection('customers')
          .doc(customerId)
          .collection('contracts')
          .doc(contractId),
      {'status': 'terminated', 'terminatedAt': FieldValue.serverTimestamp()},
    );

    // Clear property's current contract
    batch.update(db.collection('properties').doc(propertyId), {
      'currentContractId': null,
      'currentCustomerId': null,
    });

    await batch.commit();
  }

  // Auto-expire contracts with optimized batch processing
  Future<void> expireOldContracts() async {
    DateTime now = DateTime.now();

    QuerySnapshot expiredContracts =
        await db
            .collection('contracts')
            .where('status', isEqualTo: 'active')
            .where('endDate', isLessThan: Timestamp.fromDate(now))
            .get();

    // Process in batches of 500 (Firestore limit)
    List<List<DocumentSnapshot>> batches = [];
    for (int i = 0; i < expiredContracts.docs.length; i += 500) {
      batches.add(
        expiredContracts.docs.sublist(
          i,
          i + 500 > expiredContracts.docs.length
              ? expiredContracts.docs.length
              : i + 500,
        ),
      );
    }

    for (var batch in batches) {
      WriteBatch writeBatch = db.batch();

      for (var doc in batch) {
        var data = doc.data() as Map<String, dynamic>;
        String propertyId = data['propertyId'];
        String customerId = data['customerId'];

        // Update main contract
        writeBatch.update(doc.reference, {
          'status': 'expired',
          'expiredAt': FieldValue.serverTimestamp(),
        });

        // Update customer contract copy
        writeBatch.update(
          db
              .collection('customers')
              .doc(customerId)
              .collection('contracts')
              .doc(doc.id),
          {'status': 'expired', 'expiredAt': FieldValue.serverTimestamp()},
        );

        // Clear property's current contract
        writeBatch.update(db.collection('properties').doc(propertyId), {
          'currentContractId': null,
          'currentCustomerId': null,
        });
      }

      await writeBatch.commit();
    }
  }

  // Real-time listener for customer contracts
  Stream<List<Map<String, dynamic>>> streamCustomerContracts(
    String customerId,
  ) {
    return db
        .collection('customers')
        .doc(customerId)
        .collection('contracts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => {'id': doc.id, ...doc.data()})
                  .toList(),
        );
  }
}
