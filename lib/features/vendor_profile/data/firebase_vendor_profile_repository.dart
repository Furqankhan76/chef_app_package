import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../domain/vendor.dart';
import '../domain/vendor_profile_repository.dart';

class FirebaseVendorProfileRepository implements VendorProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseVendorProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<Vendor> getVendorProfile(String uid) async {
    try {
      final doc = await _firestore.collection('vendors').doc(uid).get();
      if (!doc.exists) {
        throw Exception('Vendor profile not found');
      }
      return _vendorFromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get vendor profile: ${e.toString()}');
    }
  }

  @override
  Future<void> updateVendorProfile(Vendor vendor) async {
    try {
      await _firestore.collection('vendors').doc(vendor.uid).set(
        {
          'businessName': vendor.businessName,
          'description': vendor.description,
          'profilePhotos': vendor.profilePhotos,
          'sharableLink': vendor.sharableLink,
          'followerCount': vendor.followerCount, // Ensure this is managed correctly elsewhere
          'createdAt': vendor.createdAt, // Should ideally be set only once
          'updatedAt': FieldValue.serverTimestamp(), // Update timestamp on write
        },
        SetOptions(merge: true), // Use merge to avoid overwriting fields not included
      );
    } catch (e) {
      throw Exception('Failed to update vendor profile: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadProfilePhoto(String uid, String filePath) async {
    try {
      final file = File(filePath);
      final fileName = '${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg'; // Simple naming
      final ref = _storage.ref().child('vendor_profile_photos').child(fileName);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: ${e.toString()}');
    }
  }

  // Helper to convert Firestore doc to Vendor object
  Vendor _vendorFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vendor(
      uid: doc.id,
      businessName: data['businessName'] ?? '',
      description: data['description'] ?? '',
      profilePhotos: List<String>.from(data['profilePhotos'] ?? []),
      sharableLink: data['sharableLink'] ?? '',
      followerCount: data['followerCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

