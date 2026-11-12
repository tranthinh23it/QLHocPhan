import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool obscurePassword = true;
  bool isLoading = false;

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
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackBar('Please fill in all fields', Colors.red);
      return;
    }
    print('🔍 Debug: ${ApiConfig.debugInfo}');
    print('🔍 Login URL: ${AuthService.baseUrl}/auth/login');
    setState(() => isLoading = true);
    try {
      final result = await AuthService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (!mounted) return;
      if (result['success']) {
        _showSnackBar('Login successful!', Colors.green);
        if (mounted) Navigator.of(context).pushReplacementNamed('/user-list');
      } else {
        _showSnackBar(result['message'] ?? 'Login failed', Colors.red);
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
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
      {Widget? prefixIcon, Widget? suffixIcon}) {
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  // ─── Shared form widgets ───────────────────────────────────────────────────

  /// [showLogo]: hiện logo ổ khoá phía trên tiêu đề.
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
            child: const Icon(Icons.lock_outline_rounded,
                color: _primaryColor, size: 36),
          ),
          const SizedBox(height: 28),
        ],
        Text(
          'Sign In',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: _primaryDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Start your journey with thousands of\ndevelopers around the world.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: _subtitleColor,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 36),

        // Email
        TextField(
          controller: emailController,
          enabled: !isLoading,
          style: GoogleFonts.inter(fontSize: 15, color: _textColor),
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
            'Email',
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(Icons.email_outlined, color: _subtitleColor, size: 20),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Password
        TextField(
          controller: passwordController,
          enabled: !isLoading,
          obscureText: obscurePassword,
          style: GoogleFonts.inter(fontSize: 15, color: _textColor),
          decoration: _inputDecoration(
            'Password',
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(Icons.lock_outline, color: _subtitleColor, size: 20),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                onPressed: !isLoading
                    ? () => setState(() => obscurePassword = !obscurePassword)
                    : null,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _subtitleColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Forgot password
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: isLoading
                ? null
                : () => _showSnackBar(
                    'Forgot password feature coming soon', Colors.blue),
            child: Text(
              'Forgot Password?',
              style: GoogleFonts.inter(
                color: _primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Login button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: isLoading ? null : _handleLogin,
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                : Text(
                    'Login',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
        const SizedBox(height: 24),

        // Sign Up link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280), fontSize: 14),
            ),
            GestureDetector(
              onTap: isLoading
                  ? null
                  : () => Navigator.of(context).pushNamed('/register'),
              child: Text(
                'Sign Up',
                style: GoogleFonts.inter(
                    color: _primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Divider
        Row(
          children: [
            const Expanded(child: Divider(color: _borderColor, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or continue with',
                style: GoogleFonts.inter(
                    color: _subtitleColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const Expanded(child: Divider(color: _borderColor, thickness: 1)),
          ],
        ),
        const SizedBox(height: 20),

        // Social buttons
        _buildSocialButton(FontAwesomeIcons.facebook,
            'Continue with Facebook', const Color(0xFF1877F2)),
        const SizedBox(height: 12),
        _buildSocialButton(FontAwesomeIcons.google, 'Continue with Google',
            const Color(0xFFDB4437)),
        const SizedBox(height: 12),
        _buildSocialButton(
            FontAwesomeIcons.apple, 'Continue with Apple', Colors.black),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: _borderColor, width: 1.5),
          backgroundColor: Colors.white,
        ),
        onPressed: isLoading
            ? null
            : () => _showSnackBar('Social login coming soon', Colors.blue),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 19, color: color),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.inter(
                    color: _textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.09),
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
                        child: const Icon(Icons.lock_outline_rounded,
                            color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Welcome\nBack!',
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
                        'Sign in to continue building\namazing things with thousands\nof developers worldwide.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 56),
                      // Feature pills
                      ...[
                        ('🚀', 'Fast & Reliable'),
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