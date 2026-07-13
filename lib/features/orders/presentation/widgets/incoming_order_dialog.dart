import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/json_helpers.dart';
import '../../domain/entities/incoming_order.dart';

Future<bool?> showIncomingOrderDialog({
  required BuildContext context,
  required IncomingOrder order,
  required Future<void> Function() onAccept,
  required Future<void> Function() onDecline,
}) {
  return showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    isDismissible: false,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _IncomingOrderSheet(
      order: order,
      onAccept: onAccept,
      onDecline: onDecline,
    ),
  );
}

class _IncomingOrderSheet extends StatefulWidget {
  const _IncomingOrderSheet({
    required this.order,
    required this.onAccept,
    required this.onDecline,
  });

  final IncomingOrder order;
  final Future<void> Function() onAccept;
  final Future<void> Function() onDecline;

  @override
  State<_IncomingOrderSheet> createState() => _IncomingOrderSheetState();
}

class _IncomingOrderSheetState extends State<_IncomingOrderSheet> {
  bool _submitting = false;
  bool _accepted = false;
  bool _loadingLocation = true;
  String? _error;
  String? _locationError;
  LatLng? _partnerPoint;

  LatLng? get _patientPoint {
    if (widget.order.latitude == 0 || widget.order.longitude == 0) return null;
    return LatLng(widget.order.latitude, widget.order.longitude);
  }

  @override
  void initState() {
    super.initState();
    _loadPartnerLocation();
  }

  Future<void> _loadPartnerLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() {
          _loadingLocation = false;
          _locationError = 'GPS belum aktif';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _loadingLocation = false;
          _locationError = 'Izin lokasi belum diberikan';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      if (!mounted) return;
      setState(() {
        _partnerPoint = LatLng(position.latitude, position.longitude);
        _loadingLocation = false;
        _locationError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingLocation = false;
        _locationError = 'Lokasi mitra belum tersedia';
      });
    }
  }

  Future<void> _handle(bool accept) async {
    setState(() {
      _submitting = true;
      _accepted = accept;
      _error = null;
    });

    try {
      if (accept) {
        await widget.onAccept();
      } else {
        await widget.onDecline();
      }
      if (!mounted) return;
      Navigator.of(context).pop(accept);
    } on Failure catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Gagal memproses pesanan.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: FractionallySizedBox(
        heightFactor: 0.92,
        alignment: Alignment.bottomCenter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: AppRadius.chip,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.mobileMargin,
                    0,
                    AppSpacing.mobileMargin,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(order: widget.order),
                      const SizedBox(height: AppSpacing.md),
                      _MapPreview(
                        order: widget.order,
                        partnerPoint: _partnerPoint,
                        patientPoint: _patientPoint,
                        loadingLocation: _loadingLocation,
                        locationError: _locationError,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _OrderSummary(
                        order: widget.order,
                        partnerPoint: _partnerPoint,
                        patientPoint: _patientPoint,
                      ),
                      if (!widget.order.isPaid) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Tombol Terima aktif setelah pasien menyelesaikan pembayaran.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              _Actions(
                isPaid: widget.order.isPaid,
                submitting: _submitting,
                accepted: _accepted,
                onAccept: () => _handle(true),
                onDecline: () => _handle(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.order});

  final IncomingOrder order;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: AppRadius.control,
          ),
          child: const Icon(Icons.local_hospital_rounded, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Baru Masuk',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                order.code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        _PaymentPill(isPaid: order.isPaid),
      ],
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({
    required this.order,
    required this.partnerPoint,
    required this.patientPoint,
    required this.loadingLocation,
    required this.locationError,
  });

  final IncomingOrder order;
  final LatLng? partnerPoint;
  final LatLng? patientPoint;
  final bool loadingLocation;
  final String? locationError;

  @override
  Widget build(BuildContext context) {
    final center = _centerPoint;
    final markers = <Marker>[
      if (partnerPoint != null)
        Marker(
          point: partnerPoint!,
          width: 44,
          height: 44,
          child: const _MapMarker(
            icon: Icons.medical_services_outlined,
            color: AppColors.primary,
          ),
        ),
      if (patientPoint != null)
        Marker(
          point: patientPoint!,
          width: 44,
          height: 44,
          child: const _MapMarker(
            icon: Icons.person_pin_circle_outlined,
            color: AppColors.error,
          ),
        ),
    ];

    return ClipRRect(
      borderRadius: AppRadius.card,
      child: SizedBox(
        height: 250,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 14),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mitra_perawatku',
                ),
                if (partnerPoint != null && patientPoint != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [partnerPoint!, patientPoint!],
                        color: AppColors.secondary,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                MarkerLayer(markers: markers),
              ],
            ),
            Positioned(
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: _MapCaption(
                text: loadingLocation
                    ? 'Mengambil lokasi Anda...'
                    : locationError ??
                        (order.addressText == '-'
                            ? 'Alamat pasien belum tersedia'
                            : order.addressText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LatLng get _centerPoint {
    if (partnerPoint != null && patientPoint != null) {
      return LatLng(
        (partnerPoint!.latitude + patientPoint!.latitude) / 2,
        (partnerPoint!.longitude + patientPoint!.longitude) / 2,
      );
    }

    return patientPoint ??
        partnerPoint ??
        const LatLng(-6.200000, 106.816666);
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.order,
    required this.partnerPoint,
    required this.patientPoint,
  });

  final IncomingOrder order;
  final LatLng? partnerPoint;
  final LatLng? patientPoint;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _SummaryRow(label: 'Layanan', value: order.serviceName),
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(label: 'Pasien', value: order.patientName),
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(label: 'Jadwal', value: order.scheduledAt),
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(label: 'Alamat', value: order.addressText),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    icon: Icons.route_outlined,
                    label: 'Jarak',
                    value: _distanceText,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MetricTile(
                    icon: Icons.payments_outlined,
                    label: 'Total',
                    value: formatCurrency(order.totalAmount),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _distanceText {
    if (order.distanceKm > 0) {
      return '${order.distanceKm.toStringAsFixed(1)} km';
    }

    if (partnerPoint != null && patientPoint != null) {
      final meters = Geolocator.distanceBetween(
        partnerPoint!.latitude,
        partnerPoint!.longitude,
        patientPoint!.latitude,
        patientPoint!.longitude,
      );
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }

    return '-';
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.isPaid,
    required this.submitting,
    required this.accepted,
    required this.onAccept,
    required this.onDecline,
  });

  final bool isPaid;
  final bool submitting;
  final bool accepted;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.mobileMargin,
          AppSpacing.sm,
          AppSpacing.mobileMargin,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: submitting ? null : onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(color: Theme.of(context).colorScheme.error),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.control,
                    ),
                  ),
                  child: submitting && !accepted
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Tolak'),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SizedBox(
                height: 46,
                child: FilledButton(
                  onPressed: isPaid && !submitting ? onAccept : null,
                  style: FilledButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.control,
                    ),
                  ),
                  child: submitting && accepted
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Terima'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.control,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelLarge),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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

class _PaymentPill extends StatelessWidget {
  const _PaymentPill({required this.isPaid});

  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    final color = isPaid ? AppColors.primary : Theme.of(context).colorScheme.error;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.chip,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          isPaid ? 'LUNAS' : 'UNPAID',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _MapCaption extends StatelessWidget {
  const _MapCaption({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: AppRadius.control,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
