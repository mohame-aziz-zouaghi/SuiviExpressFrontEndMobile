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
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  User? _user;
  bool _loading = true;
  bool _showConfirmPassword = false;
  bool _isModified = false;
  bool _formValid = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

Future<void> _loadUserProfile() async {
  try {
    final userId = await TokenStorage.getuserId();
    if (userId == null) throw Exception("No user ID found");

    final user = await _userService.getUserById(userId);
    if (user == null) throw Exception("User not found");

    setState(() {
      _user = user;
      _usernameController = TextEditingController(text: user.username);
      _firstNameController = TextEditingController(text: user.firstName);
      _lastNameController = TextEditingController(text: user.lastName);
      _emailController = TextEditingController(text: user.email);
      _phoneController = TextEditingController(text: user.phone ?? '');
      _addressController = TextEditingController(text: user.address ?? '');
      _passwordController = TextEditingController();
      _confirmPasswordController = TextEditingController();
      _loading = false;

      _addChangeListeners();
    });
  } catch (e) {
    // Clear stored token & redirect to login
    await TokenStorage.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session expired or user not found. Please login again.")),
      );
    }
  }
}


  void _addChangeListeners() {
    final controllers = [
      _usernameController,
      _firstNameController,
      _lastNameController,
      _emailController,
      _phoneController,
      _addressController,
      _passwordController,
      _confirmPasswordController,
    ];
    for (var controller in controllers) {
      controller.addListener(() {
        setState(() {
          _isModified = _hasChanges();
          _showConfirmPassword = _passwordController.text.isNotEmpty;
          _formValid = _formKey.currentState?.validate() ?? false;
        });
      });
    }
  }

  bool _hasChanges() {
    return _usernameController.text != _user!.username ||
        _firstNameController.text != _user!.firstName ||
        _lastNameController.text != _user!.lastName ||
        _emailController.text != _user!.email ||
        _phoneController.text != (_user!.phone ?? '') ||
        _addressController.text != (_user!.address ?? '') ||
        _passwordController.text.isNotEmpty;
  }

  bool get _canUpdate =>
      _isModified &&
      (_formKey.currentState?.validate() ?? false) &&
      (!_showConfirmPassword ||
          _confirmPasswordController.text == _passwordController.text);

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final updatedUser = User(
        id: _user!.id,
        username: _usernameController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : _user!.password,
        profileImageUrl: _user!.profileImageUrl,
        role: _user!.role,
        enabled: _user!.enabled,
        locked: _user!.locked,
        createdAt: _user!.createdAt,
        updatedAt: DateTime.now(),
        lastLogin: _user!.lastLogin,
        deviceToken: _user!.deviceToken,
      );

      final user =
          await _userService.updateUser(_user!.id.toString(), updatedUser);
      setState(() {
        _user = user;
        _passwordController.clear();
        _confirmPasswordController.clear();
        _showConfirmPassword = false;
        _isModified = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
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
        _passwordController.clear();
        _confirmPasswordController.clear();
        _showConfirmPassword = false;
        _isModified = false;
      });
    }
  }

  // 🔒 Logout confirmation
  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await TokenStorage.clear(); // remove all saved tokens
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login'); // your login route
      }
    }
  }

  // 🗑️ Delete Account confirmation
  Future<void> _confirmDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
            "Are you sure you want to permanently delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _userService.deleteUser(_user!.id.toString());
        await TokenStorage.clear();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login'); // or login page
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deleted successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete account: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          _usernameController,
                          "Username",
                          Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Username is required";
                            }
                            if (value.length < 5) {
                              return "At least 5 characters required";
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          _firstNameController,
                          "First Name",
                          Icons.badge,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "First name is required";
                            }
                            if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                              return "Only letters allowed";
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          _lastNameController,
                          "Last Name",
                          Icons.badge_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Last name is required";
                            }
                            if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                              return "Only letters allowed";
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          _emailController,
                          "Email",
                          Icons.email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email is required";
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          _phoneController,
                          "Phone",
                          Icons.phone,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                !RegExp(r'^\d{8,15}$').hasMatch(value)) {
                              return "Enter a valid phone number";
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          _addressController,
                          "Address",
                          Icons.home,
                        ),
                        _buildTextField(
                          _passwordController,
                          "New Password",
                          Icons.lock,
                          obscureText: true,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (value.length < 8) {
                                return "Min 8 characters";
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                return "Include an uppercase letter";
                              }
                              if (!RegExp(r'[a-z]').hasMatch(value)) {
                                return "Include a lowercase letter";
                              }
                              if (!RegExp(r'[0-9]').hasMatch(value)) {
                                return "Include a number";
                              }
                              if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
                                return "Include a special character (!@#\$&*~)";
                              }
                            }
                            return null;
                          },
                        ),
                        if (_showConfirmPassword)
                          _buildTextField(
                            _confirmPasswordController,
                            "Confirm Password",
                            Icons.lock_outline,
                            obscureText: true,
                            validator: (value) {
                              if (_passwordController.text.isNotEmpty &&
                                  value != _passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isModified ? _cancelChanges : null,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.indigo,
                                ),
                                child: const Text("Cancel"),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _canUpdate ? _updateProfile : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  disabledBackgroundColor:
                                      Colors.grey.shade400,
                                ),
                                child: const Text("Update"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 10),

                  // 🔒 Logout button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: _confirmLogout,
                  ),
                  const SizedBox(height: 10),

                  // 🗑️ Delete account button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: const Text("Delete Account"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: _confirmDeleteAccount,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
