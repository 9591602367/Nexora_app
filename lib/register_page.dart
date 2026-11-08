import 'package:flutter/material.dart';
import 'auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _guardianEmailController = TextEditingController();
  final _guardianPhoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _selectedRole = 'user';

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final guardianEmail = _guardianEmailController.text.trim();
    final guardianPhone = _guardianPhoneController.text.trim();

    if (name.isEmpty || email.isEmpty ||
        password.isEmpty || confirmPassword.isEmpty) {
      _showSnack("Please fill out all fields.", Colors.redAccent);
      return;
    }

    if (password != confirmPassword) {
      _showSnack("Passwords do not match!", Colors.redAccent);
      return;
    }

    if (password.length < 6) {
      _showSnack("Password must be at least 6 characters.", Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.registerUser(
      name: name,
      email: email,
      password: password,
      role: _selectedRole,
      guardianEmail: _selectedRole == 'user' ? guardianEmail : null,
      guardianPhone: _selectedRole == 'user' ? guardianPhone : null,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      _showSnack("Registration successful! Please log in.", Colors.green);
      Navigator.pop(context);
    } else {
      _showSnack(result['error'] ?? 'Registration failed.', Colors.redAccent);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _guardianEmailController.dispose();
    _guardianPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2533),
      appBar: AppBar(title: const Text("Create Account")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person_add_alt_1_rounded,
                  size: 70, color: Colors.blueAccent),
              const SizedBox(height: 12),
              const Text(
                "Join Nexora",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Full Name
              _buildField(
                  _nameController, "Full Name", Icons.person_outline),
              const SizedBox(height: 14),

              // Email
              _buildField(
                _emailController,
                "Email Address",
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon:
                  const Icon(Icons.lock_outline, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2D3748),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Confirm Password
              _buildField(
                _confirmPasswordController,
                "Confirm Password",
                Icons.lock_reset_rounded,
                obscure: true,
              ),
              const SizedBox(height: 20),

              // Role Selection
              const Text("Register as:",
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _roleChip('user', 'User', Icons.person),
                  const SizedBox(width: 10),
                  _roleChip('guardian', 'Guardian', Icons.shield_outlined),
                  const SizedBox(width: 10),
                  _roleChip(
                      'admin', 'Admin', Icons.admin_panel_settings),
                ],
              ),
              const SizedBox(height: 14),

              // Guardian fields — only for user role
              if (_selectedRole == 'user') ...[
                _buildField(
                  _guardianEmailController,
                  "Guardian's Email (optional)",
                  Icons.contact_mail_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                _buildField(
                  _guardianPhoneController,
                  "Guardian's Phone Number (optional)",
                  Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                const Text(
                  "SOS alerts will be sent to this number.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 14),
              ],

              const SizedBox(height: 10),

              // Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Text(
                  "Register",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller,
      String hint,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        bool obscure = false,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF2D3748),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _roleChip(String value, String label, IconData icon) {
    final bool selected = _selectedRole == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? Colors.blueAccent.withOpacity(0.2)
                : const Color(0xFF2D3748),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? Colors.blueAccent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? Colors.blueAccent : Colors.white54,
                  size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.blueAccent : Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}