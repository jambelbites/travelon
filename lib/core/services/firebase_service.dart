// lib/core/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_wishlist/models/place.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '157216180253-h3d8kb0f2a7d3enoknu5id46745k906f.apps.googleusercontent.com', // Web client ID
  );

  // Get the current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Register with email and password
  Future<User?> registerWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await _addUserToFirestore(
          userId: userCredential.user!.uid,
          name: name,
          email: email,
        );
      }
      return userCredential.user;
    } catch (e) {
      debugPrint("Error during registration: $e");
      rethrow; // Rethrow to handle in the UI
    }
  }

  Future<void> _addUserToFirestore({
    required String userId,
    required String name,
    required String email,
    String? photoUrl, // Add this parameter
  }) async {
    CollectionReference users = _firestore.collection('users');
    try {
      await users.doc(userId).set({
        'id': users.doc().id,
        'uid': userId,
        'name': name,
        'email': email,
        'photoUrl': photoUrl, // Add this field
        'created_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      debugPrint("Error adding user to Firestore: $e");
      rethrow;
    }
  }

  // Login with email and password
  Future<User?> loginWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      debugPrint("Error during login: $e");
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('Google Sign In was cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      // Get user's Google profile photo URL
      final String? photoUrl = googleUser.photoUrl;
      debugPrint('Google profile photo URL: $photoUrl');

      // Add or update user in Firestore with photo URL
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _addUserToFirestore(
          userId: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? '',
          email: userCredential.user!.email ?? '',
          photoUrl: photoUrl, // Add photo URL
        );
      } else {
        // Update existing user's photo URL
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({
              'photoUrl': photoUrl,
              'updated_at': FieldValue.serverTimestamp(),
            });
      }

      return userCredential.user;
    } catch (e) {
      if (e.toString().contains('People API has not been used')) {
        debugPrint('Please enable People API in Google Cloud Console');
        // You might want to show a more user-friendly error message
        throw Exception(
          'Google Sign In configuration incomplete. Please try again later.',
        );
      }
      debugPrint('Error signing in with Google: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Fetch user places from Firestore
  Future<List<Place>> getUserPlaces() async {
    final userId = currentUser?.uid;
    if (userId == null) {
      debugPrint("Cannot fetch places: No user logged in");
      return [];
    }

    try {
      debugPrint("Fetching places for user: $userId");
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('places')
              .where('isVisited', isEqualTo: false)
              .get(); // Remove the orderBy temporarily

      debugPrint("Firestore snapshot docs: ${snapshot.docs.length}");

      final places =
          snapshot.docs.map((doc) {
            final place = Place.fromFirestore(doc);
            debugPrint("Parsed place: ${place.name}");
            return place;
          }).toList();

      // Sort locally instead
      places.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return places;
    } catch (e) {
      debugPrint("Error fetching user places: $e");
      return [];
    }
  }

  // Add a new place to the user's wishlist
  Future<bool> addPlaceToUser(
    String name,
    String description,
    String imageUrl,
  ) async {
    final userId = currentUser?.uid;
    if (userId == null) {
      debugPrint("Cannot add place: No user logged in");
      return false;
    }

    try {
      final placeData = {
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'isVisited': false,
        'createdAt':
            Timestamp.now(), // Change this from FieldValue.serverTimestamp()
        'updatedAt': Timestamp.now(), // Add this field
      };

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('places')
          .add(placeData);

      debugPrint("Successfully added place: $name with ID: ${docRef.id}");
      return true;
    } catch (e) {
      debugPrint("Error adding place: $e");
      return false;
    }
  }

  // Update an existing place in the user's wishlist
  Future<bool> updatePlace(
    String placeId,
    String name,
    String description,
    String imageUrl, [
    bool? isVisited, // Optional parameter
  ]) async {
    final userId = currentUser?.uid;
    if (userId == null) return false;

    try {
      debugPrint(
        "Updating place: $placeId, isVisited: $isVisited",
      ); // Add debug print

      final updates = {
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add isVisited to updates if provided
      if (isVisited != null) {
        updates['isVisited'] = isVisited;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('places')
          .doc(placeId)
          .update(updates);

      debugPrint("Place updated successfully"); // Add debug print
      return true;
    } catch (e) {
      debugPrint("Error updating place: $e");
      return false;
    }
  }

  // Delete a place from the user's wishlist
  Future<bool> deletePlace(String placeId) async {
    final userId = currentUser?.uid;
    if (userId == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('places')
          .doc(placeId)
          .delete();
      return true;
    } catch (e) {
      debugPrint("Error deleting place: $e");
      return false;
    }
  }

  // Add method to get visited places
  Future<List<Place>> getVisitedPlaces() async {
    final userId = currentUser?.uid;
    if (userId == null) {
      debugPrint("Cannot fetch places: No user logged in");
      return [];
    }

    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('places')
              .where('isVisited', isEqualTo: true)
              // Temporarily remove ordering until index is created
              // .orderBy('updatedAt', descending: true)
              .get();

      final places =
          snapshot.docs.map((doc) {
            final place = Place.fromFirestore(doc);
            debugPrint("Visited place: ${place.name}"); // Add debug print
            return place;
          }).toList();

      debugPrint("Found ${places.length} visited places"); // Add debug print
      return places;
    } catch (e) {
      debugPrint("Error fetching visited places: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final userId = currentUser?.uid;
    if (userId == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      return data;
    } catch (e) {
      debugPrint("Error getting user data: $e");
      return null;
    }
  }

  Future<String> uploadProfileImage(File imageFile) async {
    final userId = currentUser?.uid;
    if (userId == null) throw Exception('No user logged in');

    try {
      debugPrint("Starting profile image upload for user: $userId");

      // Ensure the file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Generate a unique filename
      final String fileName =
          'profile_$userId\_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Create reference to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();
      final profileImagesRef = storageRef.child('profile_images/$fileName');

      // Create metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'userId': userId},
      );

      // Upload file
      final uploadTask = profileImagesRef.putFile(imageFile, metadata);

      // Monitor progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        debugPrint('Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      // Wait for upload to complete
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user profile
      await _firestore.collection('users').doc(userId).update({
        'photoUrl': downloadUrl,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e, stackTrace) {
      debugPrint('Error uploading profile image: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      // Reauthenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);
    } catch (e) {
      debugPrint("Error changing password: $e");
      throw Exception('Failed to change password');
    }
  }

  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete user account
      await user.delete();

      // Sign out
      await signOut();
    } catch (e) {
      debugPrint("Error deleting account: $e");
      throw Exception('Failed to delete account');
    }
  }
}
