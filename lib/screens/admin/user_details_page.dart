import 'package:flutter/material.dart';
import '../../data/models/app_user.dart';
import '../../data/services/firestore_service.dart';
import '../../data/models/user_role.dart';

class UserDetailsPage extends StatelessWidget {
  UserDetailsPage({super.key, required this.user}); // NOT const

  final AppUser user;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel(user);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("User Details"),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 👤 USER PROFILE CARD
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.person, size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Divider(height: 30),

                    _infoRow(Icons.phone, "Phone", user.phone ?? 'N/A'),
                    _infoRow(Icons.badge, "Role", _roleLabel(user.role)),
                    _infoRow(Icons.verified_user, "Status", statusLabel),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ⚙️ ADMIN ACTIONS
            _sectionTitle("Admin Actions"),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text("Change Role"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _showSnack(
                      context,
                      "Role change coming soon",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.lock_reset),
                    label: const Text("Reset Password"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () =>
                        _showSnack(context, "Password reset coming soon"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 🚫 BLOCK USER (DANGER)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(user.isBlocked ? Icons.lock_open : Icons.block),
                label: Text(user.isBlocked ? "Unblock User" : "Block User"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: user.isBlocked ? Colors.green : Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _confirmBlock(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SECTION TITLE
  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // INFO ROW
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // SNACKBAR
  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // BLOCK CONFIRMATION
  void _confirmBlock(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(user.isBlocked ? "Unblock User" : "Block User"),
        content: Text(
          user.isBlocked
              ? "This user will regain access. Continue?"
              : "This user will no longer be able to access the system.\n\nAre you sure?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isBlocked ? Colors.green : Colors.red,
            ),
            onPressed: () async {
              await _firestoreService.updateUserStatus(
                userId: user.id,
                isApproved: user.isApproved,
                isBlocked: !user.isBlocked,
              );
              if (!context.mounted) {
                return;
              }
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(user.isBlocked ? "Unblock" : "Block"),
          ),
        ],
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return "Admin";
      case UserRole.farmer:
        return "Farmer";
      case UserRole.customer:
        return "Customer";
    }
  }

  String _statusLabel(AppUser user) {
    if (user.isBlocked) {
      return "Blocked";
    }
    if (!user.isApproved) {
      return "Pending";
    }
    return "Active";
  }
}
