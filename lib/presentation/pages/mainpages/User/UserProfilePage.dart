import 'package:flutter/material.dart';
import 'package:suiviexpress_app/data/models/user.dart';
import 'package:suiviexpress_app/data/services/user_service.dart';
import 'package:suiviexpress_app/data/services/token_storage.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Get stored userId from token
      final userId = await TokenStorage.getuserId();
      final user = await _userService.getUserById(userId!);
      setState(() {
        _user = user;
        _usernameController = TextEditingController(text: user.username);
        _firstNameController = TextEditingController(text: user.firstName);
        _lastNameController = TextEditingController(text: user.lastName);
        _emailController = TextEditingController(text: user.email);
        _phoneController = TextEditingController(text: user.phone ?? '');
        _addressController = TextEditingController(text: user.address ?? '');
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile: $e")),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedUser = User(
          id: _user!.id,
          username: _usernameController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          password: _user!.password,
          profileImageUrl: _user!.profileImageUrl,
          role: _user!.role,
          enabled: _user!.enabled,
          locked: _user!.locked,
          createdAt: _user!.createdAt,
          updatedAt: DateTime.now(),
          lastLogin: _user!.lastLogin,
          deviceToken: _user!.deviceToken,
        );
        final user = await _userService.updateUser(_user!.id.toString(), updatedUser);
        setState(() => _user = user);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: $e")),
        );
      }
    }
  }

  void _cancelChanges() {
    if (_user != null) {
      setState(() {
        _usernameController.text = _user!.username;
        _firstNameController.text = _user!.firstName;
        _lastNameController.text = _user!.lastName;
        _emailController.text = _user!.email;
        _phoneController.text = _user!.phone ?? '';
        _addressController.text = _user!.address ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile",   style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.indigo,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.indigo.shade50,
                    backgroundImage: _user!.profileImageUrl != null &&
                            _user!.profileImageUrl!.isNotEmpty
                        ? NetworkImage(_user!.profileImageUrl!)
                        : null,
                    child: _user!.profileImageUrl == null ||
                            _user!.profileImageUrl!.isEmpty
                        ? const Icon(Icons.person, size: 60, color: Colors.indigo)
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                              labelText: "Username", prefixIcon: Icon(Icons.person)),
                          validator: (value) =>
                              value == null || value.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                              labelText: "First Name", prefixIcon: Icon(Icons.badge)),
                          validator: (value) =>
                              value == null || value.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                              labelText: "Last Name", prefixIcon: Icon(Icons.badge)),
                          validator: (value) =>
                              value == null || value.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                              labelText: "Email", prefixIcon: Icon(Icons.email)),
                          validator: (value) =>
                              value == null || value.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                              labelText: "Phone", prefixIcon: Icon(Icons.phone)),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                              labelText: "Address", prefixIcon: Icon(Icons.home)),
                        ),
                        const SizedBox(height: 24),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _cancelChanges,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.indigo,
                                ),
                                child: const Text("Cancel"),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _updateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                ),
                                child: const Text("Update",   style: TextStyle(color: Colors.white),),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
