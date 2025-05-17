import 'package:chef_app/features/user_management/domain/user.dart';

abstract class UserRepository {
  Stream<AppUser?> getUser(String uid);
  Future<void> createUser(AppUser user);
  Future<void> updateUser(AppUser user);
  // Add other methods as needed, e.g., find users by role/location
}

