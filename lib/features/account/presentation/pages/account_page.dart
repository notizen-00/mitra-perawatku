import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/json_helpers.dart';
import '../../domain/entities/account_profile_update.dart';
import '../../domain/entities/account_summary.dart';
import '../bloc/account_bloc.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountBloc>()..add(const AccountStarted()),
      child: const _AccountView(),
    );
  }
}

class _AccountView extends StatelessWidget {
  const _AccountView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountBloc, AccountState>(
      listener: (context, state) {
        if (state is AccountLoggedOut) context.go('/login');
        if (state is AccountLoaded && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) context.go('/dashboard');
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F8FE),
          body: SafeArea(
            child: BlocBuilder<AccountBloc, AccountState>(
              builder: (context, state) {
                if (state is AccountLoading || state is AccountInitial) {
                  return const _LoadingView();
                }

                if (state is AccountFailure) {
                  return _ErrorView(message: state.message);
                }

                final summary = switch (state) {
                  AccountLoaded(:final summary) => summary,
                  AccountSaving(:final summary) => summary,
                  AccountLogoutInProgress(:final summary) => summary,
                  _ => null,
                };

                if (summary == null) {
                  return const _ErrorView(message: 'State akun tidak dikenali.');
                }

                return RefreshIndicator(
                  onRefresh: () async => context
                      .read<AccountBloc>()
                      .add(const AccountRefreshRequested()),
                  child: _AccountContent(
                    summary: summary,
                    isSaving: state is AccountSaving,
                    isLoggingOut: state is AccountLogoutInProgress,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountContent extends StatelessWidget {
  const _AccountContent({
    required this.summary,
    required this.isSaving,
    required this.isLoggingOut,
  });

  final AccountSummary summary;
  final bool isSaving;
  final bool isLoggingOut;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          children: [
            const _AccountTopBar(),
            if (isSaving) ...[
              const LinearProgressIndicator(minHeight: 3),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            _ProfileHeader(summary: summary),
            const SizedBox(height: 18),
            _StatsRow(summary: summary),
            const SizedBox(height: 18),
            _SectionTitle('Professional Info'),
            const SizedBox(height: 8),
            _MenuGroup(items: _professionalItems(summary)),
            const SizedBox(height: 18),
            _SectionTitle('Account Settings'),
            const SizedBox(height: 8),
            _MenuGroup(items: _settingsItems(summary)),
            const SizedBox(height: 18),
            const _SectionTitle('Support'),
            const SizedBox(height: 8),
            _MenuGroup(items: _supportItems),
            const SizedBox(height: 28),
            _LogoutButton(
              isLoading: isLoggingOut,
              onPressed: () => context
                  .read<AccountBloc>()
                  .add(const AccountLogoutPressed()),
            ),
            const SizedBox(height: 18),
            const _VersionFooter(),
          ],
        ),
      ),
    );
  }
}

class _AccountTopBar extends StatelessWidget {
  const _AccountTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Home',
        ),
        const Spacer(),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.summary});

  final AccountSummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8F5F1),
                image: summary.profilePhotoUrl.isEmpty
                    ? null
                    : DecorationImage(
                        image: NetworkImage(summary.profilePhotoUrl),
                        fit: BoxFit.cover,
                      ),
                border: Border.all(color: Colors.white, width: 5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F0B1C30),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: summary.profilePhotoUrl.isEmpty
                  ? const Icon(
                      Icons.medical_services_rounded,
                      color: AppColors.primary,
                      size: 44,
                    )
                  : null,
            ),
            Positioned(
              left: 5,
              bottom: 7,
              child: InkWell(
                onTap: () => _showPhotoActions(context, summary),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 5,
              bottom: 7,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: summary.isAvailable
                      ? const Color(0xFF00B978)
                      : const Color(0xFF98A2B3),
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          summary.name,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0B1C30),
          ),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: _professionLabel(summary)),
              const TextSpan(text: '  |  '),
              TextSpan(text: 'STR: ${summary.licenseNumber}'),
            ],
          ),
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: const Color(0xFF667085),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.summary});

  final AccountSummary summary;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatData(
        value: summary.isVerified ? 'Verified' : 'Pending',
        label: 'Status',
      ),
      _StatData(
        value: '${summary.yearsOfExperience} Yrs',
        label: 'Experience',
      ),
      _StatData(value: summary.joinedYear, label: 'Joined'),
    ];

    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          Expanded(child: _StatCard(stat: stats[i])),
          if (i != stats.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _StatData {
  const _StatData({required this.value, required this.label});

  final String value;
  final String label;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _StatData stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF9FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD7ECF8)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              stat.value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            stat.label.toUpperCase(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF0B1C30),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF344054),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.items});

  final List<_MenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7ECF3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0B1C30),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _MenuTile(item: items[i]),
            if (i != items.length - 1)
              const Divider(height: 1, indent: 56, color: Color(0xFFE7ECF3)),
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item});

  final _MenuItemData item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _handleMenuTap(context, item.title),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7FB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(item.icon, size: 16, color: AppColors.secondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF0B1C30),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF667085),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF98A2B3),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemData {
  const _MenuItemData({
    required this.title,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final String? subtitle;
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.logout_rounded, size: 18),
      label: Text(isLoading ? 'Logging out...' : 'Logout'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFE53935),
        side: const BorderSide(color: Color(0xFFFFB4B4)),
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () =>
                  context.read<AccountBloc>().add(const AccountStarted()),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionFooter extends StatelessWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Homecare Pro v2.4.1\n(C) 2024 Health Systems Inc.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFFB8C0CC),
            height: 1.45,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

List<_MenuItemData> _professionalItems(AccountSummary summary) {
  return [
    const _MenuItemData(
      title: 'Edit Profile',
      icon: Icons.edit_outlined,
      subtitle: 'Update profil layanan mitra',
    ),
    _MenuItemData(
      title: 'Legal Documents (STR/SIP)',
      icon: Icons.description_outlined,
      subtitle: summary.hasStrDocument || summary.hasKtpDocument
          ? 'Dokumen sudah tersimpan'
          : 'Belum ada dokumen',
    ),
    _MenuItemData(
      title: 'Specializations',
      icon: Icons.medical_services_outlined,
      subtitle: summary.specialization,
    ),
    _MenuItemData(
      title: 'Practice Address',
      icon: Icons.location_on_outlined,
      subtitle: summary.workLocation,
    ),
  ];
}

List<_MenuItemData> _settingsItems(AccountSummary summary) {
  return [
    _MenuItemData(
      title: 'Service & Pricing Settings',
      icon: Icons.payments_outlined,
      subtitle:
          '${summary.activeServices}/${summary.totalServices} aktif - ${formatCurrency(summary.consultationFee)}',
    ),
    const _MenuItemData(
      title: 'Bank Account & Payouts',
      icon: Icons.account_balance_outlined,
      subtitle: 'Data payout belum tersedia dari API',
    ),
    _MenuItemData(
      title: 'Notifications',
      icon: Icons.notifications_active_outlined,
      subtitle: summary.isAvailable ? 'Online menerima order' : 'Sedang offline',
    ),
    const _MenuItemData(
      title: 'Security & Password',
      icon: Icons.lock_reset_outlined,
    ),
  ];
}

const _supportItems = [
  _MenuItemData(title: 'Help Center', icon: Icons.help_outline_rounded),
  _MenuItemData(title: 'Terms of Service', icon: Icons.article_outlined),
  _MenuItemData(title: 'Privacy Policy', icon: Icons.shield_outlined),
];

String _professionLabel(AccountSummary summary) {
  if (summary.specialization != '-') return summary.specialization;

  return switch (summary.profession) {
    'dokter' => 'Doctor',
    'perawat' => 'Nurse',
    'bidan' => 'Midwife',
    _ => 'Mitra',
  };
}

void _handleMenuTap(BuildContext context, String title) {
  context.read<AccountBloc>().add(AccountMenuSelected(title));

  if (title == 'Edit Profile' ||
      title == 'Specializations' ||
      title == 'Practice Address' ||
      title == 'Service & Pricing Settings') {
    final state = context.read<AccountBloc>().state;
    final summary = state is AccountLoaded ? state.summary : null;
    if (summary != null) _showEditProfileSheet(context, summary);
    return;
  }

  if (title == 'Security & Password') {
    _showPasswordSheet(context);
  }
}

Future<void> _showPhotoActions(
  BuildContext context,
  AccountSummary summary,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih foto profil'),
                subtitle: const Text('JPG, PNG, atau WebP maksimal 2MB'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final picker = ImagePicker();
                  final file = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    imageQuality: 82,
                  );
                  if (file == null || !context.mounted) return;
                  context
                      .read<AccountBloc>()
                      .add(AccountProfilePhotoSelected(file.path));
                },
              ),
              if (summary.profilePhotoUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  title: const Text('Hapus foto profil'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context
                        .read<AccountBloc>()
                        .add(const AccountProfilePhotoDeleted());
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _showEditProfileSheet(
  BuildContext context,
  AccountSummary summary,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _EditProfileSheet(summary: summary),
  );
}

void _showPasswordSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Security & Password',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Endpoint update password belum tercantum di BACKEND_INTEGRATION.md, jadi fitur ini belum dikirim ke server agar tidak memakai kontrak API yang salah.',
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Mengerti'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.summary});

  final AccountSummary summary;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _specialization;
  late final TextEditingController _licenseNumber;
  late final TextEditingController _workLocation;
  late final TextEditingController _yearsOfExperience;
  late final TextEditingController _consultationFee;
  late final TextEditingController _bio;
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    final summary = widget.summary;
    _specialization = TextEditingController(text: _clean(summary.specialization));
    _licenseNumber = TextEditingController(text: _clean(summary.licenseNumber));
    _workLocation = TextEditingController(text: _clean(summary.workLocation));
    _yearsOfExperience = TextEditingController(
      text: summary.yearsOfExperience.toString(),
    );
    _consultationFee = TextEditingController(
      text: summary.consultationFee.round().toString(),
    );
    _bio = TextEditingController(text: summary.bio);
    _isAvailable = summary.isAvailable;
  }

  @override
  void dispose() {
    _specialization.dispose();
    _licenseNumber.dispose();
    _workLocation.dispose();
    _yearsOfExperience.dispose();
    _consultationFee.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Profile',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 16),
                _TextField(
                  controller: _specialization,
                  label: 'Specialization',
                  icon: Icons.medical_services_outlined,
                ),
                const SizedBox(height: 12),
                _TextField(
                  controller: _licenseNumber,
                  label: 'License Number / STR',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 12),
                _TextField(
                  controller: _workLocation,
                  label: 'Practice Address',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TextField(
                        controller: _yearsOfExperience,
                        label: 'Experience',
                        icon: Icons.work_history_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TextField(
                        controller: _consultationFee,
                        label: 'Fee',
                        icon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _TextField(
                  controller: _bio,
                  label: 'Bio',
                  icon: Icons.notes_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isAvailable,
                  title: const Text('Available for orders'),
                  subtitle: const Text('Update is_available di profil mitra'),
                  onChanged: (value) => setState(() => _isAvailable = value),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Simpan Profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AccountBloc>().add(
          AccountProfileSubmitted(
            AccountProfileUpdate(
              specialization: _specialization.text.trim(),
              licenseNumber: _licenseNumber.text.trim(),
              workLocation: _workLocation.text.trim(),
              yearsOfExperience:
                  int.tryParse(_yearsOfExperience.text.trim()) ?? 0,
              consultationFee:
                  double.tryParse(_consultationFee.text.trim()) ?? 0,
              bio: _bio.text.trim(),
              isAvailable: _isAvailable,
            ),
          ),
        );
    Navigator.of(context).pop();
  }

  String _clean(String value) {
    return value == '-' ? '' : value;
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if ((value ?? '').trim().isEmpty && label != 'Bio') {
          return '$label wajib diisi';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
