import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/app_user.dart';
import '../../data/services/firestore_service.dart';

class FarmerProfilePage extends StatelessWidget {
  FarmerProfilePage({super.key});

  final FirestoreService _firestoreService = FirestoreService();

  // 🔐 Logout confirmation
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) {
                return;
              }
              Navigator.pop(context);
              Navigator.pop(context); // back to login
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 👤 PROFILE CARD
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: userId == null
                    ? const Text("Please login to view profile")
                    : StreamBuilder<AppUser?>(
                        stream: _firestoreService.streamUser(userId),
                        builder: (context, snapshot) {
                          final user = snapshot.data;
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (user == null) {
                            return const Text("Profile not found");
                          }
                          return Column(
                            children: [
                              const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.green,
                                child: Icon(
                                  Icons.agriculture,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                user.email,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 15),
                              _infoRow(
                                Icons.phone,
                                "Phone",
                                user.phone ?? 'N/A',
                              ),
                              _infoRow(
                                Icons.verified_user,
                                "Status",
                                user.isApproved ? "Approved" : "Pending",
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 25),

            // ⚙️ OPTIONS
            _optionTile(
              icon: Icons.edit,
              title: "Edit Profile",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Edit profile coming soon")),
                );
              },
            ),

            _optionTile(
              icon: Icons.lock,
              title: "Change Password",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Change password coming soon")),
                );
              },
            ),

            _optionTile(
              icon: Icons.help_outline,
              title: "Help & Support",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Support coming soon")),
                );
              },
            ),

            const Spacer(),

            // 🚪 LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () => _confirmLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ℹ️ INFO ROW
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ⚙️ OPTION TILE
  Widget _optionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
