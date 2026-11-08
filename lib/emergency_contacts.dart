import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  List<Map<String, String>> _contacts = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // 1. Fetch saved contacts from persistent storage disk
  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? serializedContacts = prefs.getString('nexora_trusted_contacts');
    if (serializedContacts != null) {
      setState(() {
        final List<dynamic> decoded = jsonDecode(serializedContacts);
        _contacts = decoded.map((item) => Map<String, String>.from(item)).toList();
      });
    }
  }

  // 2. Commit updated contacts list to persistent memory
  Future<void> _saveContactsToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String serialized = jsonEncode(_contacts);
    await prefs.setString('nexora_trusted_contacts', serialized);
  }

  void _addContact() {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both name and phone number.")),
      );
      return;
    }

    setState(() {
      _contacts.add({"name": name, "phone": phone});
      _nameController.clear();
      _phoneController.clear();
    });

    _saveContactsToDisk();
    Navigator.pop(context); // Close input modal panel sheet

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Guardian Contact Secured!"), backgroundColor: Colors.green),
    );
  }

  void _deleteContact(int index) {
    setState(() {
      _contacts.removeAt(index);
    });
    _saveContactsToDisk();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Contact Removed.")),
    );
  }

  // Opens a clean form field sheet overlay from the bottom
  void _showAddContactBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2D3748),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Register Trusted Guardian",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Guardian Name",
                hintStyle: const TextStyle(color: Colors.grey),
                fillColor: const Color(0xFF1B2533),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Mobile Number",
                hintStyle: const TextStyle(color: Colors.grey),
                fillColor: const Color(0xFF1B2533),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addContact,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text("Save Secure Contact", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2533),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Emergency Guardians", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _contacts.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 70, color: Colors.grey),
            SizedBox(height: 16),
            Text("No primary contacts configured yet.", style: TextStyle(color: Colors.grey, fontSize: 14)),
            Text("Add contacts who should receive emergency dispatches.", style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          return Card(
            color: const Color(0xFF2D3748),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(_contacts[index]['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(_contacts[index]['phone']!, style: const TextStyle(color: Colors.white60)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _deleteContact(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: _showAddContactBottomSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}