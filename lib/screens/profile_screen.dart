import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final String name, email;
  const ProfileScreen({super.key, required this.name, required this.email});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, email;
  bool saving = false;
  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.name);
    email = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok = await prefs.setStringList('todo_profile', [
        name.text.trim(),
        email.text.trim(),
      ]);
      if (!ok) throw StateError('Save failed');
      if (mounted) {
        Navigator.pop(context, [name.text.trim(), email.text.trim()]);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save profile. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Your profile')),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 42,
              child: Icon(Icons.person, size: 48),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: name,
            maxLength: 50,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter your name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email (optional)',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                v != null &&
                    v.trim().isNotEmpty &&
                    !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())
                ? 'Enter a valid email'
                : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: saving ? null : save,
            child: Text(saving ? 'Saving...' : 'Save profile'),
          ),
          const SizedBox(height: 12),
          const Text('Your profile stays on this device.'),
        ],
      ),
    ),
  );
}
