import 'package:flutter/material.dart';
import 'farmer_details_page.dart';
import '../../data/models/app_user.dart';
import '../../data/services/firestore_service.dart';

class FarmersPage extends StatefulWidget {
  const FarmersPage({super.key}); // NOT const

  @override
  State<FarmersPage> createState() => _FarmersPageState();
}

class _FarmersPageState extends State<FarmersPage> {
  String _search = "";
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Farmers"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _search = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search farmers...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 👨‍🌾 FARMERS LIST
          Expanded(
            child: StreamBuilder<List<AppUser>>(
              stream: _firestoreService.streamFarmers(search: _search),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final farmers = snapshot.data ?? [];
                if (farmers.isEmpty) {
                  return const Center(
                    child: Text(
                      "No farmers found",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: farmers.length,
                  itemBuilder: (context, index) {
                    return _farmerCard(context, farmers[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 👨‍🌾 FARMER CARD
  Widget _farmerCard(BuildContext context, AppUser farmer) {
    final status = _statusLabel(farmer);
    Color statusColor;
    switch (status) {
      case "Approved":
        statusColor = Colors.green;
        break;
      case "Pending":
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: const Icon(Icons.agriculture, color: Colors.green),
        ),
        title: Text(
          farmer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Email: ${farmer.email}"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(
                status,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: statusColor,
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FarmerDetailsPage(farmer: farmer),
            ),
          );
        },
      ),
    );
  }

  String _statusLabel(AppUser farmer) {
    if (farmer.isBlocked) {
      return "Blocked";
    }
    if (farmer.isApproved) {
      return "Approved";
    }
    return "Pending";
  }
}
