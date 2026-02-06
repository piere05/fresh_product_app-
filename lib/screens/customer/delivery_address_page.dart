// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_address_page.dart';
import '../../data/models/address.dart';
import '../../data/services/firestore_service.dart';

class DeliveryAddressPage extends StatelessWidget {
  const DeliveryAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Delivery Address"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: _buildAddressList(context, firestoreService),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_location_alt),
                label: const Text("Add New Address"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddAddressPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList(
    BuildContext context,
    FirestoreService firestoreService,
  ) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text("Please login to manage addresses"));
    }

    return StreamBuilder<List<Address>>(
      stream: firestoreService.streamAddresses(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final addresses = snapshot.data ?? [];
        if (addresses.isEmpty) {
          return const Center(child: Text("No address saved yet"));
        }
        return ListView.builder(
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            return _addressCard(
              context: context,
              firestoreService: firestoreService,
              userId: userId,
              address: addresses[index],
            );
          },
        );
      },
    );
  }

  // 📦 ADDRESS CARD
  Widget _addressCard({
    required BuildContext context,
    required FirestoreService firestoreService,
    required String userId,
    required Address address,
  }) {
    final isDefault = address.isDefault;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(
          Icons.location_on,
          color: isDefault ? Colors.green : Colors.indigo,
        ),
        title: Row(
          children: [
            Text(
              address.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Default",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(address.formatted),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == "default") {
              await firestoreService.setDefaultAddress(
                userId: userId,
                addressId: address.id,
              );
            }
            if (value == "delete") {
              await firestoreService.deleteAddress(
                userId: userId,
                addressId: address.id,
              );
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: "default", child: Text("Set Default")),
            PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}
