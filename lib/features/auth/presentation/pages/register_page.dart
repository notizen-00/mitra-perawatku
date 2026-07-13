import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/cards/medical_card.dart';
import '../cubit/auth_cubit.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _workLocationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _feeController = TextEditingController();
  final _bioController = TextEditingController();
  String _profession = 'perawat';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _specializationController.dispose();
    _licenseNumberController.dispose();
    _workLocationController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pendaftaran berhasil. Akun menunggu verifikasi admin.'),
            ),
          );
          context.go('/dashboard');
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: colors.error),
          );
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Daftar Mitra'),
            leading: IconButton(
              onPressed: loading ? null : () => context.go('/login'),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: AppSpacing.screen,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: MedicalCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profil Profesional',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Data ini dikirim ke endpoint pendaftaran mitra dan akan diverifikasi admin.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            _SectionLabel(label: 'Akun'),
                            const SizedBox(height: AppSpacing.md),
                            _TextField(
                              controller: _nameController,
                              label: 'Nama lengkap',
                              icon: Icons.person_outline_rounded,
                              enabled: !loading,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _TextField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !loading,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _TextField(
                              controller: _phoneController,
                              label: 'Nomor HP',
                              icon: Icons.call_outlined,
                              keyboardType: TextInputType.phone,
                              enabled: !loading,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _PasswordField(
                              controller: _passwordController,
                              label: 'Password',
                              enabled: !loading,
                              obscure: _obscurePassword,
                              onToggle: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _PasswordField(
                              controller: _passwordConfirmationController,
                              label: 'Konfirmasi password',
                              enabled: !loading,
                              obscure: _obscurePassword,
                              validator: _passwordConfirmationValidator,
                              onToggle: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            _SectionLabel(label: 'Data Mitra'),
                            const SizedBox(height: AppSpacing.md),
                            DropdownButtonFormField<String>(
                              initialValue: _profession,
                              decoration: const InputDecoration(
                                labelText: 'Profesi',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'perawat',
                                  child: Text('Perawat'),
                                ),
                                DropdownMenuItem(
                                  value: 'dokter',
                                  child: Text('Dokter'),
                                ),
                                DropdownMenuItem(
                                  value: 'bidan',
                                  child: Text('Bidan'),
                                ),
                              ],
                              onChanged: loading
                                  ? null
                                  : (value) {
                                      if (value == null) return;
                                      setState(() => _profession = value);
                                    },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _TextField(
                              controller: _specializationController,
                              label: 'Spesialisasi',
                              icon: Icons.medical_information_outlined,
                              enabled: !loading,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _TextField(
                              controller: _licenseNumberController,
                              label: 'Nomor STR/SIP',
                              icon: Icons.verified_user_outlined,
                              enabled: !loading,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _TextField(
                              controller: _workLocationController,
                              label: 'Lokasi kerja',
                              icon: Icons.location_on_outlined,
                              enabled: !loading,
                              required: false,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _TextField(
                                    controller: _experienceController,
                                    label: 'Pengalaman',
                                    icon: Icons.timeline_outlined,
                                    keyboardType: TextInputType.number,
                                    enabled: !loading,
                                    required: false,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: _TextField(
                                    controller: _feeController,
                                    label: 'Tarif konsultasi',
                                    icon: Icons.payments_outlined,
                                    keyboardType: TextInputType.number,
                                    enabled: !loading,
                                    required: false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _TextField(
                              controller: _bioController,
                              label: 'Bio singkat',
                              icon: Icons.notes_outlined,
                              enabled: !loading,
                              required: false,
                              maxLines: 3,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: loading ? null : () => _submit(context),
                                icon: loading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.app_registration_rounded),
                                label: Text(
                                  loading ? 'Mengirim...' : 'Daftar Mitra',
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Center(
                              child: TextButton(
                                onPressed: loading
                                    ? null
                                    : () => context.go('/login'),
                                child: const Text('Sudah punya akun? Login'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _passwordConfirmationController.text,
      profession: _profession,
      specialization: _specializationController.text.trim(),
      licenseNumber: _licenseNumberController.text.trim(),
      workLocation: _emptyToNull(_workLocationController.text),
      yearsOfExperience: int.tryParse(_experienceController.text.trim()),
      consultationFee: double.tryParse(_feeController.text.trim()),
      bio: _emptyToNull(_bioController.text),
    );
  }

  String? _passwordConfirmationValidator(String? value) {
    final requiredError = _requiredValidator(value);
    if (requiredError != null) return requiredError;

    if (value != _passwordController.text) {
      return 'Konfirmasi password tidak sama';
    }

    return null;
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.enabled,
    this.keyboardType,
    this.required = true,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final bool required;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: required ? _requiredValidator : null,
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.enabled,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          onPressed: enabled ? onToggle : null,
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
        ),
      ),
      validator: validator ?? _requiredValidator,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleLarge);
  }
}

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Wajib diisi';
  }
  return null;
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
