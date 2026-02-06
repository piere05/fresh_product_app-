enum UserRole { admin, farmer, customer }

UserRole userRoleFromString(String value) {
  switch (value) {
    case 'admin':
      return UserRole.admin;
    case 'farmer':
      return UserRole.farmer;
    default:
      return UserRole.customer;
  }
}

String userRoleToString(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'admin';
    case UserRole.farmer:
      return 'farmer';
    case UserRole.customer:
      return 'customer';
  }
}
