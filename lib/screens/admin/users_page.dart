// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'user_details_page.dart';
import '../../data/models/app_user.dart';
import '../../data/services/firestore_service.dart';
import '../../data/models/user_role.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key}); // NOT const

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String _search = '';
  String _roleFilter = 'All';
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Users Management"),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                hintText: "Search users by name or email",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🏷 FILTER CHIPS
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  "All",
                  selected: _roleFilter == 'All' && _statusFilter == 'All',
                  onTap: () => setState(() {
                    _roleFilter = 'All';
                    _statusFilter = 'All';
                  }),
                ),
                _FilterChip(
                  "Admin",
                  selected: _roleFilter == 'Admin',
                  onTap: () => setState(() => _roleFilter = 'Admin'),
                ),
                _FilterChip(
                  "Farmer",
                  selected: _roleFilter == 'Farmer',
                  onTap: () => setState(() => _roleFilter = 'Farmer'),
                ),
                _FilterChip(
                  "Customer",
                  selected: _roleFilter == 'Customer',
                  onTap: () => setState(() => _roleFilter = 'Customer'),
                ),
                _FilterChip(
                  "Active",
                  selected: _statusFilter == 'Active',
                  onTap: () => setState(() => _statusFilter = 'Active'),
                ),
                _FilterChip(
                  "Blocked",
                  selected: _statusFilter == 'Blocked',
                  onTap: () => setState(() => _statusFilter = 'Blocked'),
                ),
                _FilterChip(
                  "Pending",
                  selected: _statusFilter == 'Pending',
                  onTap: () => setState(() => _statusFilter = 'Pending'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 👥 USERS LIST
          Expanded(
            child: StreamBuilder<List<AppUser>>(
              stream: _firestoreService.streamUsers(
                search: _search,
                role: _roleFilter == 'All' ? null : _roleFilter,
                status: _statusFilter == 'All' ? null : _statusFilter,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data ?? [];
                if (users.isEmpty) {
                  return const Center(child: Text("No users found"));
                }
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return _userCard(context, users[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 👤 USER CARD
  Widget _userCard(BuildContext context, AppUser user) {
    final roleLabel = _roleLabel(user.role);
    final statusLabel = _statusLabel(user);
    final roleColor = _roleColor(roleLabel);
    final statusColor = _statusColor(statusLabel);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.15),
          child: Icon(Icons.person, color: roleColor),
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(user.email),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _badge(roleLabel, roleColor),
            const SizedBox(height: 4),
            _badge(statusLabel, statusColor, small: true),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserDetailsPage(user: user)),
          );
        },
      ),
    );
  }

  // 🏷 BADGE
  Widget _badge(String text, Color color, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
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

  // 🎨 ROLE COLOR
  Color _roleColor(String role) {
    switch (role) {
      case "Admin":
        return Colors.red;
      case "Farmer":
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  // 🎨 STATUS COLOR
  Color _statusColor(String status) {
    switch (status) {
      case "Active":
        return Colors.green;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}

// 🏷 FILTER CHIP
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(this.label, {required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.blueGrey.withOpacity(0.15),
        selectedColor: Colors.blueGrey.withOpacity(0.25),
        labelStyle: const TextStyle(color: Colors.blueGrey),
      ),
    );
  }
}
