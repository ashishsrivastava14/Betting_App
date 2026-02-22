import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();

  // State
  DateTime? _selectedDob;
  String? _selectedGender;

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  static const _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── DOB picker ──────────────────────────────────────────────────────────────
  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      helpText: 'SELECT DATE OF BIRTH',
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: AppColors.background,
              surface: AppColors.card,
              onSurface: AppColors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  String get _dobDisplay {
    if (_selectedDob == null) return 'DD / MM / YYYY';
    final d = _selectedDob!;
    return '${d.day.toString().padLeft(2, '0')} / '
        '${d.month.toString().padLeft(2, '0')} / '
        '${d.year}';
  }

  // ── Form submit ──────────────────────────────────────────────────────────────
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDob == null) {
      _showSnack('Please select your date of birth');
      return;
    }

    final auth = context.read<AuthProvider>();
    final dob =
        '${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}';

    auth.startRegistration(
      phone: _phoneController.text.trim(),
      name: _nameController.text.trim(),
      dob: dob,
      location: _locationController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      gender: _selectedGender,
    );

    context.push('/otp');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Reusable label widget ────────────────────────────────────────────────────
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
            letterSpacing: 1.2,
          ),
        ),
      );

  // ── Shared input decoration ──────────────────────────────────────────────────
  InputDecoration _inputDec({
    required String hint,
    Widget? prefix,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: AppColors.textMuted.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        prefixIcon: prefix,
        suffixIcon: suffix,
        counterText: '',
        filled: true,
        fillColor: AppColors.surface.withValues(alpha: 0.7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red, width: 2),
        ),
      );

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/cricket_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.background),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.55),
                    AppColors.background.withValues(alpha: 0.92),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.3, 0.55, 0.7],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.card.withValues(alpha: 0.7),
                            border: Border.all(
                              color: AppColors.cardBorder
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Icon(Icons.arrow_back, size: 18),
                        ),
                        onPressed: () => context.go('/login'),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideUp,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(height: screenHeight * 0.02),

                              // ── Logo ──
                              Image.asset(
                                'assets/images/bt_logo.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.sports_cricket,
                                  size: 34,
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(height: 14),

                              Text(
                                'BetZone',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white,
                                  letterSpacing: 3,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.accent
                                          .withValues(alpha: 0.5),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'CREATE YOUR ACCOUNT',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      AppColors.accent.withValues(alpha: 0.85),
                                  letterSpacing: 3,
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.03),

                              // ── Registration Card ──
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.card.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.cardBorder
                                        .withValues(alpha: 0.6),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── Section header: Contact ──
                                    _SectionHeader(
                                      icon: Icons.phone_android_rounded,
                                      label: 'Contact',
                                    ),
                                    const SizedBox(height: 16),

                                    // Mobile Number
                                    _label('MOBILE NUMBER *'),
                                    TextFormField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 10,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: _inputDec(
                                        hint: '9876543210',
                                        prefix: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('🇮🇳',
                                                  style: TextStyle(
                                                      fontSize: 18)),
                                              const SizedBox(width: 6),
                                              Text('+91',
                                                  style: GoogleFonts.poppins(
                                                    color: AppColors.white,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    fontSize: 15,
                                                  )),
                                              const SizedBox(width: 8),
                                              Container(
                                                width: 1,
                                                height: 22,
                                                color: AppColors.cardBorder,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Enter mobile number';
                                        }
                                        if (v.length != 10) {
                                          return 'Enter valid 10-digit number';
                                        }
                                        if (!RegExp(r'^[6-9]\d{9}$')
                                            .hasMatch(v)) {
                                          return 'Enter a valid Indian mobile number';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 20),
                                    const _Divider(),
                                    const SizedBox(height: 20),

                                    // ── Section header: Basic KYC ──
                                    _SectionHeader(
                                      icon: Icons.badge_rounded,
                                      label: 'Basic KYC',
                                    ),
                                    const SizedBox(height: 16),

                                    // Full Name
                                    _label('FULL NAME *'),
                                    TextFormField(
                                      controller: _nameController,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.white,
                                        fontSize: 14,
                                      ),
                                      decoration: _inputDec(
                                        hint: 'e.g. Rahul Sharma',
                                        prefix: const Padding(
                                          padding: EdgeInsets.only(
                                              left: 14, right: 10),
                                          child: Icon(Icons.person_outline,
                                              size: 20,
                                              color: AppColors.accent),
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Enter your full name';
                                        }
                                        if (v.trim().length < 3) {
                                          return 'Name must be at least 3 characters';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // Date of Birth
                                    _label('DATE OF BIRTH *'),
                                    GestureDetector(
                                      onTap: _pickDob,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface
                                              .withValues(alpha: 0.7),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: _selectedDob == null
                                                ? AppColors.cardBorder
                                                    .withValues(alpha: 0.5)
                                                : AppColors.accent,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                                Icons.calendar_today_rounded,
                                                size: 20,
                                                color: AppColors.accent),
                                            const SizedBox(width: 12),
                                            Text(
                                              _dobDisplay,
                                              style: GoogleFonts.poppins(
                                                color: _selectedDob == null
                                                    ? AppColors.textMuted
                                                        .withValues(alpha: 0.5)
                                                    : AppColors.white,
                                                fontSize: 14,
                                                fontWeight: _selectedDob ==
                                                        null
                                                    ? FontWeight.w400
                                                    : FontWeight.w500,
                                              ),
                                            ),
                                            const Spacer(),
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              color: AppColors.textMuted
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Location
                                    _label('CITY / STATE *'),
                                    TextFormField(
                                      controller: _locationController,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.white,
                                        fontSize: 14,
                                      ),
                                      decoration: _inputDec(
                                        hint: 'e.g. Mumbai, Maharashtra',
                                        prefix: const Padding(
                                          padding: EdgeInsets.only(
                                              left: 14, right: 10),
                                          child: Icon(
                                              Icons.location_on_outlined,
                                              size: 20,
                                              color: AppColors.accent),
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Enter your city / state';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // Gender (optional)
                                    _label('GENDER (OPTIONAL)'),
                                    DropdownButtonFormField<String>(
                                      value: _selectedGender,
                                      dropdownColor: AppColors.card,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.white,
                                        fontSize: 14,
                                      ),
                                      icon: const Icon(
                                        Icons.expand_more_rounded,
                                        color: AppColors.accent,
                                      ),
                                      decoration: _inputDec(
                                        hint: 'Select gender',
                                        prefix: const Padding(
                                          padding: EdgeInsets.only(
                                              left: 14, right: 10),
                                          child: Icon(Icons.wc_rounded,
                                              size: 20,
                                              color: AppColors.accent),
                                        ),
                                      ),
                                      items: _genders
                                          .map((g) => DropdownMenuItem(
                                                value: g,
                                                child: Text(g),
                                              ))
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _selectedGender = v),
                                    ),

                                    const SizedBox(height: 16),

                                    // Email (optional)
                                    _label('EMAIL ADDRESS (OPTIONAL)'),
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.white,
                                        fontSize: 14,
                                      ),
                                      decoration: _inputDec(
                                        hint: 'e.g. rahul@email.com',
                                        prefix: const Padding(
                                          padding: EdgeInsets.only(
                                              left: 14, right: 10),
                                          child: Icon(Icons.mail_outline,
                                              size: 20,
                                              color: AppColors.accent),
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v != null &&
                                            v.isNotEmpty &&
                                            !RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                                .hasMatch(v)) {
                                          return 'Enter a valid email address';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 28),

                                    // ── OTP Banner ──
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.accent
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.verified_user_rounded,
                                              size: 18,
                                              color: AppColors.accent),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'An OTP will be sent to verify your mobile number',
                                              style: GoogleFonts.poppins(
                                                color: AppColors.accent,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // ── Register + Send OTP button ──
                                    SizedBox(
                                      width: double.infinity,
                                      height: 54,
                                      child: Consumer<AuthProvider>(
                                        builder: (context, auth, _) {
                                          return ElevatedButton(
                                            onPressed:
                                                auth.isLoading ? null : _submit,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.accent,
                                              foregroundColor:
                                                  AppColors.background,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: auth.isLoading
                                                ? const SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      color:
                                                          AppColors.background,
                                                    ),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                          Icons.bolt,
                                                          size: 20),
                                                      const SizedBox(
                                                          width: 8),
                                                      Text(
                                                        'SEND OTP & REGISTER',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          letterSpacing: 1.2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Already have account?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account?  ',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.go('/login'),
                                    child: Text(
                                      'Login',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.accent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.accent
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Terms
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'By registering, you confirm that you are 18 years or older and agree to our Terms & Privacy Policy.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color:
                                        AppColors.textMuted.withValues(alpha: 0.7),
                                    fontSize: 10.5,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Powered by
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Powered by ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppColors.textMuted
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/QuickPrepAI_Logo.png',
                                    height: 18,
                                    errorBuilder: (_, __, ___) => Text(
                                      'QuickPrepAI',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textMuted
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.accent),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.cardBorder.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
