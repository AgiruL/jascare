import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  // 👇 1. ADDED THESE LOGIC VARIABLES TO HOLD THE WEATHER STATE
  final String currentWeather;
  final bool isFullscreen;
  final Function(String) onWeatherChanged;
  final VoidCallback onToggleFullscreen;

  // 👇 2. UPDATED CONSTRUCTOR TO REQUIRE THEM
  const LoginScreen({
    super.key,
    required this.currentWeather,
    required this.isFullscreen,
    required this.onWeatherChanged,
    required this.onToggleFullscreen,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all email and password fields."), backgroundColor: Colors.redAccent)
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = await _authService.loginWithEmail(email, password);
    setState(() => _isLoading = false);

    if (user != null) {
      if (!mounted) return;
      
      // 👇 3. HANDLES PASSING THE ACTIVE STATE CLEANLY INTO THE DASHBOARD SHELL
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return MainNavigationScreen(
                currentWeather: widget.currentWeather,
                isFullscreen: widget.isFullscreen,
                onWeatherChanged: widget.onWeatherChanged,
                onToggleFullscreen: () {
                  // 1. Triggers the actual screen switch function at the root (main.dart)
                  widget.onToggleFullscreen();
                  // 2. Forces this view layout layer to refresh instantly
                  setModalState(() {});
                },
              );
            },
          ),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication failed. Invalid login credentials."), backgroundColor: Colors.red)
      );
    }
  }

  // ... rest of your build method stays exactly the same as before!

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF243B7A), Color(0xFF141B2B)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                // Custom Icon Shield Box Block
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.shield_outlined, size: 52, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text("Welcome Back", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                const Text("Login to your account", style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 40),

                // Email Inputs row
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                    hintText: "Email address",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withAlpha(20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Input row
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                    hintText: "Password",
                    hintStyle: const TextStyle(color: Colors.white38),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white70),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.white.withAlpha(20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: const Color(0xFF6366F1),
                          checkColor: Colors.white,
                          onChanged: (val) => setState(() => _rememberMe = val ?? false),
                        ),
                        const Text("Remember me", style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Forgot Password?", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF141B2B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF141B2B))
                      : const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                
                const SizedBox(height: 24),
                // Demo Autofill Option Block directly matching your UI asset reference layout
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: Colors.white70)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                      },
                      child: const Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}