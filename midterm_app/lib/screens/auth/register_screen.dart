import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController fullNameController;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  // Design constants
  static const _primaryColor = Color(0xFF2563EB);
  static const _primaryDark = Color(0xFF1E40AF);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _hintColor = Color(0xFFD1D5DB);
  static const _subtitleColor = Color(0xFF9CA3AF);
  static const _textColor = Color(0xFF374151);
  static const double _kWebBreakpoint = 900.0;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    fullNameController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showSnackBar('Please fill in all fields', Colors.red);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', Colors.red);
      return;
    }

    if (passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters', Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthService.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        hoten: fullNameController.text.trim(),
      );

      if (!mounted) return;

      if (result['success']) {
        _showSnackBar('Registration successful!', Colors.green);
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        _showSnackBar(result['message'] ?? 'Registration failed', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint,
      {Widget? prefix, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: _hintColor, fontSize: 15),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      prefixIcon: prefix,
      suffixIcon: suffix,
    );
  }

  // ─── Shared form widgets ───────────────────────────────────────────────────

  Widget _prefixIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Icon(icon, color: _subtitleColor, size: 20),
    );
  }

  Widget _eyeButton(bool obscure, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        onPressed: !isLoading ? onToggle : null,
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: _subtitleColor,
          size: 20,
        ),
      ),
    );
  }

  /// [showLogo]: hiện logo phía trên tiêu đề.
  /// Mobile = true, Web = false (vì panel trái đã có logo).
  Widget _buildForm({required bool showLogo}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLogo) ...[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person_add_outlined,
              color: _primaryColor,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Title
        Text(
          'Create Account',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: _primaryDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),

        // Subtitle
        Text(
          'Join thousands of developers building\namazing things together.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: _subtitleColor,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 36),

        // Full Name
        TextField(
          controller: fullNameController,
          enabled: !isLoading,
          style: GoogleFonts.inter(fontSize: 15, color: _textColor),
          decoration: _inputDecoration(
            'Full Name',
            prefix: _prefixIcon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 14),

        // Email
        TextField(
          controller: emailController,
          enabled: !isLoading,
          style: GoogleFonts.inter(fontSize: 15, color: _textColor),
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
            'Email',
            prefix: _prefixIcon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 14),

        // Password
        TextField(
          controller: passwordController,
          enabled: !isLoading,
          obscureText: obscurePassword,
          style: GoogleFonts.inter(fontSize: 15, color: _textColor),
          decoration: _inputDecoration(
            'Password',
            prefix: _prefixIcon(Icons.lock_outline),
            suffix: _eyeButton(
              obscurePassword,
              () => setState(() => obscurePassword = !obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Confirm Password
        TextField(
          controller: confirmPasswordController,
          enabled: !isLoading,
          obscureText: obscureConfirmPassword,
          style: GoogleFonts.inter(fontSize: 15, color: _textColor),
          decoration: _inputDecoration(
            'Confirm Password',
            prefix: _prefixIcon(Icons.lock_outline),
            suffix: _eyeButton(
              obscureConfirmPassword,
              () => setState(
                  () => obscureConfirmPassword = !obscureConfirmPassword),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Register button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            onPressed: isLoading ? null : _handleRegister,
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Create Account',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),

        // Login link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: GoogleFonts.inter(
                color: const Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),
            GestureDetector(
              onTap: isLoading
                  ? null
                  : () => Navigator.of(context).pushNamed('/login'),
              child: Text(
                'Sign In',
                style: GoogleFonts.inter(
                  color: _primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Mobile layout ─────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.07),
              _buildForm(showLogo: true),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Web layout ────────────────────────────────────────────────────────────

  Widget _buildWebLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Row(
        children: [
          // Left branding panel (cuộn được khi cửa sổ thấp)
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 56, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.person_add_outlined,
                            color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Join\nUs Today!',
                        style: GoogleFonts.inter(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Create your account and start\nbuilding amazing things with\nthousands of developers worldwide.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 56),
                      // Feature pills
                      ...[
                        ('⚡', 'Quick Setup in Minutes'),
                        ('🔒', 'Secure Authentication'),
                        ('🌍', 'Global Community'),
                      ].map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              children: [
                                Text(item.$1,
                                    style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 12),
                                Text(
                                  item.$2,
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Right form panel
          Expanded(
            flex: 6,
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 40,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: _buildForm(showLogo: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _kWebBreakpoint) {
          return _buildWebLayout();
        }
        return _buildMobileLayout();
      },
    );
  }
}