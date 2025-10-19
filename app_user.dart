class AppUser {
  final String uid;
  final String email;
  final String displayName;
  /// 'admin' | 'employee' | 'team_leader' | 'supervisor'
  final String role;
  /// Shift/Department: 'Morning' | 'Evening' | 'Night'
  final String? department;
  /// Team identifier, e.g. 'Team-01' .. 'Team-12'
  final String? teamId;
  /// Extra admin privilege for selected supervisors
  final bool isCompanyAdmin;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.department,
    this.teamId,
    this.isCompanyAdmin = false,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) => AppUser(
        uid: uid,
        email: data['email'] ?? '',
        displayName: data['displayName'] ?? '',
        role: data['role'] ?? 'employee',
        department: data['department'],
        teamId: data['teamId'],
        isCompanyAdmin: data['isCompanyAdmin'] == true,
      );

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'role': role,
        if (department != null) 'department': department,
        if (teamId != null) 'teamId': teamId,
        if (isCompanyAdmin) 'isCompanyAdmin': true,
      };
}
