import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/address.dart';
import '../../data/services/firestore_service.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to add address")),
      );
      return;
    }

    final address = Address(
      id: '',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      line1: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: "N/A",
      postalCode: _pincodeController.text.trim(),
      line2: '',
      isDefault: false,
    );

    await _firestoreService.addAddress(userId: userId, address: address);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Address added successfully")),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("Add Address"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 👤 NAME
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Enter full name" : null,
              ),

              const SizedBox(height: 15),

              // 📞 PHONE
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.length < 10 ? "Enter valid phone number" : null,
              ),

              const SizedBox(height: 15),

              // 🏠 ADDRESS
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Address",
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Enter address" : null,
              ),

              const SizedBox(height: 15),

              // 🌆 CITY
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: "City",
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Enter city" : null,
              ),

              const SizedBox(height: 15),

              // 📮 PINCODE
              TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Pincode",
                  prefixIcon: Icon(Icons.markunread_mailbox),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.length < 6 ? "Enter valid pincode" : null,
              ),

              const SizedBox(height: 25),

              // 💾 SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save Address"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveAddress,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
