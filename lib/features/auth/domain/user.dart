// Domain layer entity for User

class User {
  final String uid;
  final String? email;
  final String? name;
  final String role; // e.g., 'customer', 'vendor'
  final String? profilePicUrl;
  final String languagePreference; // e.g., 'en', 'ar'

  User({
    required this.uid,
    this.email,
    this.name,
    required this.role,
    this.profilePicUrl,
    this.languagePreference = 'en', // Default language
  });

  // Add methods like copyWith, toJson, fromJson if needed later for Firestore
}

