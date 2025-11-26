enum UserRole { owner, sitter }

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.owner:
        return 'Pet Owner';
      case UserRole.sitter:
        return 'Pet Sitter';
    }
  }
}
