import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  final String? initialRole;
  const RegisterScreen({super.key, this.initialRole});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _contactController = TextEditingController();
  late String _selectedRole;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? 'Tenant';
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        var user = await _auth.registerWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _fullNameController.text.trim(),
          _selectedRole,
          _contactController.text.trim(),
        );
        
        if (!mounted) return;
        if (user != null) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed')),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join EasyRent PH today',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildFieldLabel('Full Name'),
                    _buildTextField(
                      controller: _fullNameController,
                      hintText: 'Enter your full name',
                      icon: Icons.person_outline,
                      validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildFieldLabel('Email'),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Enter your email',
                      icon: Icons.email_outlined,
                      validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildFieldLabel('I am a:'),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Tenant')),
                            selected: _selectedRole == 'Tenant',
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedRole = 'Tenant');
                            },
                            selectedColor: const Color(0xFF1E88E5),
                            labelStyle: TextStyle(
                              color: _selectedRole == 'Tenant' ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Landlord')),
                            selected: _selectedRole == 'Landlord',
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedRole = 'Landlord');
                            },
                            selectedColor: const Color(0xFF1E88E5),
                            labelStyle: TextStyle(
                              color: _selectedRole == 'Landlord' ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildFieldLabel('Password'),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Create a password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                      validator: (val) => val!.length < 6 ? 'Enter 6+ chars' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildFieldLabel('Confirm Password'),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm your password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      validator: (val) => val!.isEmpty ? 'Confirm your password' : null,
                    ),
                    const SizedBox(height: 15),
                    _buildFieldLabel('Contact Number'),
                    _buildTextField(
                      controller: _contactController,
                      hintText: 'Enter contact number',
                      icon: Icons.phone_outlined,
                      validator: (val) => val!.isEmpty ? 'Enter contact number' : null,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _register,
                        child: const Text('Register', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Login', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText ?? false,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscureText! ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 20),
                onPressed: onToggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      validator: validator,
    );
  }
}
